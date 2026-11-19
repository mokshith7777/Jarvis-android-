#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
pkg update -y
pkg upgrade -y
pkg install -y python git cmake clang make pkg-config ffmpeg rust wget coreutils findutils
python -m pip install --upgrade pip
python -m pip install fastapi uvicorn

mkdir -p "$HOME/src" "$HOME/models" "$HOME/jarvis-output"
cd "$HOME/src"
if [ ! -d llama.cpp ]; then git clone --depth 1 https://github.com/ggml-org/llama.cpp.git; fi
cmake -S llama.cpp -B llama.cpp/build -DCMAKE_BUILD_TYPE=Release -DGGML_OPENMP=OFF
cmake --build llama.cpp/build --config Release --target llama-server -j2

if [ ! -d whisper.cpp ]; then git clone --depth 1 https://github.com/ggml-org/whisper.cpp.git; fi
cmake -S whisper.cpp -B whisper.cpp/build -DCMAKE_BUILD_TYPE=Release
cmake --build whisper.cpp/build --config Release --target whisper-cli -j2

if [ ! -d stable-diffusion.cpp ]; then git clone --depth 1 https://github.com/leejet/stable-diffusion.cpp.git; fi
cmake -S stable-diffusion.cpp -B stable-diffusion.cpp/build -DCMAKE_BUILD_TYPE=Release -DSD_BUILD_EXAMPLES=ON
cmake --build stable-diffusion.cpp/build --config Release --target sd-cli -j2

install_engine() {
  local name="$1"
  local binary
  binary="$(find "$HOME/src" -type f -name "$name" -perm -u+x -print -quit)"
  if [ -z "$binary" ]; then
    echo "ERROR: compiled $name binary was not found under $HOME/src" >&2
    return 1
  fi
  install -m 755 "$binary" "$PREFIX/bin/$name"
  echo "Installed $name -> $PREFIX/bin/$name"
}
install_engine llama-server
install_engine whisper-cli
install_engine sd-cli

python -m pip install --upgrade auto-editor
echo "Worker engines installed. Download model files separately."
echo "Example:"
echo "export JARVIS_MODEL_PATH=\$HOME/models/model.gguf"
echo "export SD_MODEL_PATH=\$HOME/models/sd-model.safetensors"
echo "export WHISPER_MODEL_PATH=\$HOME/models/ggml-base.en.bin"
echo "python3 termux_worker/jarvis_worker.py"
