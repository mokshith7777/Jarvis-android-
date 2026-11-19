#!/usr/bin/env python3
"""Loopback-only JARVIS worker for Termux. No API keys or cloud inference."""
import html
import json
import os
import re
import shutil
import subprocess
import threading
import time
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import quote_plus, urlparse, parse_qs
from urllib.request import Request, urlopen

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

HOST = "127.0.0.1"
PORT = int(os.getenv("JARVIS_WORKER_PORT", "9000"))
LLAMA_PORT = int(os.getenv("JARVIS_LLAMA_PORT", "9001"))
MODEL = os.getenv("JARVIS_MODEL_PATH", "")
LLAMA = os.getenv("LLAMA_SERVER_BIN", shutil.which("llama-server") or "llama-server")
SD = os.getenv("SD_CLI_BIN", shutil.which("sd-cli") or "sd-cli")
SD_MODEL = os.getenv("SD_MODEL_PATH", "")
WHISPER = os.getenv("WHISPER_BIN", shutil.which("whisper-cli") or "whisper-cli")
WHISPER_MODEL = os.getenv("WHISPER_MODEL_PATH", "")
AUTO_EDITOR = os.getenv("AUTO_EDITOR_BIN", shutil.which("auto-editor") or "auto-editor")
FFMPEG = shutil.which("ffmpeg") or "ffmpeg"
OUT = Path(os.getenv("JARVIS_WORKER_OUTPUT", str(Path.home() / "jarvis-output"))).expanduser()
OUT.mkdir(parents=True, exist_ok=True)
app = FastAPI(title="JARVIS Local Worker", version="3.0.0")
lock = threading.RLock()
llama_process = None

class ChatBody(BaseModel):
    model: str = "local-vision"
    messages: list[dict]
    max_tokens: int = 1024
    temperature: float = 0.2
    stream: bool = False
class BrowseBody(BaseModel):
    query: str
class ImageBody(BaseModel):
    prompt: str
    output_path: str | None = None
class VideoBody(BaseModel):
    input_path: str
    output_path: str | None = None
class StoryBody(BaseModel):
    prompt: str
    scenes: int = 4

def available_ram_mb():
    try:
        for line in Path("/proc/meminfo").read_text().splitlines():
            if line.startswith("MemAvailable:"):
                return int(line.split()[1]) // 1024
    except Exception:
        pass
    return 0

def safe_output_path(requested, default_name):
    root = OUT.resolve()
    output = (Path(requested).expanduser() if requested else OUT / default_name).resolve()
    if not output.is_relative_to(root) or output == root:
        raise HTTPException(400, "Output path must remain inside the JARVIS worker output directory.")
    return output

def run_cmd(args, timeout=3600):
    try:
        return subprocess.run(args, check=True, capture_output=True, text=True, timeout=timeout)
    except FileNotFoundError as exc:
        raise HTTPException(503, "Missing local executable: " + args[0]) from exc
    except subprocess.CalledProcessError as exc:
        raise HTTPException(500, (exc.stderr or exc.stdout or str(exc))[-3000:]) from exc
    except subprocess.TimeoutExpired as exc:
        raise HTTPException(504, "Timed out running " + args[0]) from exc

def stop_llama():
    global llama_process
    if llama_process is not None and llama_process.poll() is None:
        llama_process.terminate()
        try:
            llama_process.wait(timeout=15)
        except subprocess.TimeoutExpired:
            llama_process.kill()
            llama_process.wait(timeout=5)
    llama_process = None

def ensure_llama():
    global llama_process
    with lock:
        if llama_process is not None and llama_process.poll() is None:
            return
        if not MODEL or not Path(MODEL).is_file():
            raise HTTPException(503, "Set JARVIS_MODEL_PATH to a local GGUF model.")
        ram = available_ram_mb()
        if ram and ram < int(os.getenv("JARVIS_MIN_FREE_RAM_MB", "1200")):
            raise HTTPException(503, "Insufficient free RAM to load the model safely.")
        llama_process = subprocess.Popen([
            LLAMA, "-m", MODEL, "--host", "127.0.0.1", "--port", str(LLAMA_PORT),
            "-c", os.getenv("JARVIS_CONTEXT_SIZE", "2048"),
            "-ngl", os.getenv("JARVIS_GPU_LAYERS", "0")
        ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        for _ in range(60):
            if llama_process.poll() is not None:
                raise HTTPException(503, "llama-server exited during model startup.")
            try:
                with urlopen("http://127.0.0.1:" + str(LLAMA_PORT) + "/health", timeout=1):
                    return
            except Exception:
                time.sleep(1)
        raise HTTPException(504, "llama-server did not become ready.")

class PageText(HTMLParser):
    def __init__(self):
        super().__init__()
        self.parts = []
        self.hidden = 0
    def handle_starttag(self, tag, attrs):
        if tag in ("script", "style", "noscript", "svg"):
            self.hidden += 1
    def handle_endtag(self, tag):
        if tag in ("script", "style", "noscript", "svg") and self.hidden:
            self.hidden -= 1
    def handle_data(self, data):
        if not self.hidden:
            value = re.sub(r"\s+", " ", data).strip()
            if value:
                self.parts.append(value)

def extract_page(url):
    if urlparse(url).scheme not in ("http", "https"):
        raise HTTPException(400, "Only HTTP and HTTPS pages can be fetched.")
    req = Request(url, headers={"User-Agent": "Mozilla/5.0 JARVISLocal/3.0"})
    try:
        with urlopen(req, timeout=15) as response:
            raw = response.read(1800000).decode(response.headers.get_content_charset() or "utf-8", "replace")
    except Exception as exc:
        raise HTTPException(502, "Page fetch failed: " + str(exc)) from exc
    parser = PageText()
    parser.feed(raw)
    return " ".join(parser.parts)[:12000]

@app.get("/health")
def health():
    return {"ok": True, "worker": "jarvis-local", "version": "3.0.0",
            "llama_running": bool(llama_process is not None and llama_process.poll() is None),
            "model_configured": bool(MODEL and Path(MODEL).is_file()),
            "available_ram_mb": available_ram_mb(), "output_dir": str(OUT)}

@app.post("/v1/chat/completions")
def chat(body: ChatBody):
    ensure_llama()
    req = Request("http://127.0.0.1:" + str(LLAMA_PORT) + "/v1/chat/completions",
        data=json.dumps({**body.model_dump(), "stream": False}).encode(),
        headers={"Content-Type": "application/json"}, method="POST")
    try:
        with urlopen(req, timeout=300) as response:
            return json.loads(response.read().decode())
    except Exception as exc:
        raise HTTPException(502, "llama.cpp request failed: " + str(exc)) from exc

@app.post("/browse")
def browse(body: BrowseBody):
    query = body.query.strip()
    if not query:
        raise HTTPException(400, "Search query is required.")
    req = Request("https://html.duckduckgo.com/html/?q=" + quote_plus(query),
                  headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urlopen(req, timeout=20) as response:
            page = response.read(1500000).decode("utf-8", "replace")
    except Exception as exc:
        raise HTTPException(502, "Search failed: " + str(exc)) from exc
    anchors = re.findall(r'<a[^>]*class="result__a"[^>]*href="([^"]+)"[^>]*>(.*?)</a>', page, re.I | re.S)
    results = []
    for href, title in anchors[:8]:
        target = html.unescape(href)
        if target.startswith("//duckduckgo.com/l/?"):
            target = parse_qs(urlparse("https:" + target).query).get("uddg", [target])[0]
        label = html.unescape(re.sub(r"<[^>]+>", "", title))
        results.append({"title": re.sub(r"\s+", " ", label).strip(), "url": target})
    pages = []
    for item in results[:3]:
        try:
            pages.append({"url": item["url"], "text": extract_page(item["url"])[:5000]})
        except HTTPException:
            continue
    return {"query": query, "results": results, "extracted_pages": pages}

@app.post("/generate-image")
def generate_image(body: ImageBody):
    if not SD_MODEL or not Path(SD_MODEL).is_file():
        raise HTTPException(503, "Set SD_MODEL_PATH to a local Stable Diffusion model.")
    output = safe_output_path(body.output_path, "image-" + str(time.time_ns()) + ".png")
    with lock:
        stop_llama()
        output.parent.mkdir(parents=True, exist_ok=True)
        run_cmd([SD, "-m", SD_MODEL, "-p", body.prompt, "-o", str(output)], timeout=2400)
    return {"ok": True, "output_path": str(output)}

@app.post("/edit-video")
def edit_video(body: VideoBody):
    source = Path(body.input_path).expanduser()
    if not source.is_file():
        raise HTTPException(404, "Input video does not exist. Use a Termux-visible file path.")
    output = safe_output_path(body.output_path, "edited-" + str(time.time_ns()) + ".mp4")
    output.parent.mkdir(parents=True, exist_ok=True)
    stamp = str(time.time_ns())
    temp = OUT / ("trimmed-" + stamp + ".mp4")
    wav = OUT / ("trimmed-" + stamp + ".wav")
    subtitle = OUT / ("trimmed-" + stamp + ".srt")
    captions = False
    with lock:
        stop_llama()
        try:
            run_cmd([AUTO_EDITOR, str(source), "--edit", "audio:threshold=4%", "-o", str(temp)], timeout=3600)
            if WHISPER_MODEL and Path(WHISPER_MODEL).is_file():
                run_cmd([
                    FFMPEG, "-y", "-i", str(temp), "-vn", "-ac", "1",
                    "-ar", "16000", "-c:a", "pcm_s16le", str(wav)
                ], timeout=1800)
                run_cmd([WHISPER, "-m", WHISPER_MODEL, "-f", str(wav), "-osrt"], timeout=1800)
                captions = subtitle.is_file()
            vf = "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920"
            af = "loudnorm=I=-16:TP=-1.5:LRA=11"
            if captions:
                vf += ",subtitles=" + str(subtitle).replace(":", r"\:")
            run_cmd([FFMPEG, "-y", "-i", str(temp), "-vf", vf, "-af", af, "-c:v", "libx264",
                     "-preset", "ultrafast", "-c:a", "aac", "-b:a", "128k", str(output)], timeout=3600)
        finally:
            for temporary in (temp, wav, subtitle):
                try:
                    temporary.unlink(missing_ok=True)
                except OSError:
                    pass
    return {"ok": True, "output_path": str(output), "captions_burned": captions,
            "aspect_ratio": "9:16", "audio_normalization": "EBU R128"}

@app.post("/generate-storyboard-video")
def storyboard(body: StoryBody):
    if not SD_MODEL or not Path(SD_MODEL).is_file():
        raise HTTPException(503, "Set SD_MODEL_PATH to a local Stable Diffusion model.")
    count = max(2, min(8, body.scenes))
    with lock:
        stop_llama()
        frames = []
        stamp = str(int(time.time()))
        for i in range(count):
            frame = OUT / ("story-" + stamp + "-" + str(i) + ".png")
            prompt = body.prompt + ", cinematic storyboard keyframe " + str(i + 1) + " of " + str(count)
            run_cmd([SD, "-m", SD_MODEL, "-p", prompt, "-o", str(frame)], timeout=2400)
            frames.append(frame)
        output = OUT / ("storyboard-" + stamp + ".mp4")
        args = [FFMPEG, "-y"]
        for frame in frames:
            args.extend(["-loop", "1", "-t", "4", "-i", str(frame)])
        filters, labels = [], []
        for i in range(len(frames)):
            filters.append("[" + str(i) + ":v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,zoompan=z='min(zoom+0.0008,1.08)':d=96:s=1080x1920:fps=24,setsar=1[v" + str(i) + "]")
            labels.append("[v" + str(i) + "]")
        filters.append("".join(labels) + "concat=n=" + str(len(frames)) + ":v=1:a=0[outv]")
        args.extend(["-filter_complex", ";".join(filters), "-map", "[outv]", "-pix_fmt", "yuv420p",
                     "-c:v", "libx264", str(output)])
        run_cmd(args, timeout=3600)
    return {"ok": True, "output_path": str(output), "scenes": count, "motion": "Ken Burns"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=HOST, port=PORT, log_level="info")
