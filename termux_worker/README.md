# JARVIS Termux Worker

This worker is separate from the Android APK. Install and launch it manually in Termux:

    bash termux_worker/install_termux.sh
    export JARVIS_MODEL_PATH="$HOME/models/your-model.gguf"
    export LLAMA_SERVER_BIN="$HOME/src/llama.cpp/build/bin/llama-server"
    export WHISPER_BIN="$HOME/src/whisper.cpp/build/bin/whisper-cli"
    export WHISPER_MODEL_PATH="$HOME/models/ggml-base.en.bin"
    export SD_CLI_BIN="$HOME/src/stable-diffusion.cpp/build/bin/sd-cli"
    export SD_MODEL_PATH="$HOME/models/your-stable-diffusion-model.safetensors"
    python3 termux_worker/jarvis_worker.py

Download compatible model files yourself. The APK does not contain or silently fetch multi-gigabyte model weights. Select quantized models appropriate to available RAM. The worker binds only to 127.0.0.1:9000 and has no API-key authentication because it is loopback-only.

The worker exposes GET /health, POST /v1/chat/completions, POST /browse, POST /generate-image, POST /edit-video and POST /generate-storyboard-video. Image and video tasks stop the llama.cpp server before running to reduce memory pressure; the next chat request starts it again if sufficient RAM is available. Video editing uses auto-editor, FFmpeg, optional whisper.cpp captions, vertical 9:16 crop and audio loudness normalization.
