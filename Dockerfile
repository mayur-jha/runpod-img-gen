FROM runpod/worker-comfyui:5.4.1-flux1-dev

COPY . /workspace/repo

COPY scripts/comfy-node-install.sh /usr/local/bin/comfy-node-install
COPY scripts/comfy-manager-set-mode.sh /usr/local/bin/comfy-manager-set-mode
RUN chmod +x /usr/local/bin/comfy-node-install /usr/local/bin/comfy-manager-set-mode

COPY handler.py /handler.py
COPY src/start.sh /start.sh
COPY src/restore_snapshot.sh /restore_snapshot.sh
RUN chmod +x /start.sh /restore_snapshot.sh

COPY src/extra_model_paths.yaml /comfyui/extra_model_paths.yaml

RUN pip install boto3 piexif ffmpeg-python

RUN comfy-node-install ComfyLiterals \
  ComfyUI-Crystools \
  ComfyUI-Custom-Scripts \
  ComfyUI-GGUF \
  ComfyUI-HunyuanVideoMultiLora \
  ComfyUI-ImageMotionGuider \
  ComfyUI-JoyCaption \
  ComfyUI-Manager \
  ComfyUI-MediaMixer \
  ComfyUI-WanMoeKSampler \
  ComfyUI-WanVideoWrapper \
  ComfyUI-nunchaku \
  ComfyUI-segment-anything-2 \
  ComfyUI_JPS-Nodes \
  ComfyUI_essentials \
  Comfyui-ergouzi-Nodes \
  Comfyui_joy-caption-alpha-two \
  RES4LYF \
  cg-use-everywhere \
  comfy-image-saver \
  comfyui-denoisechooser \
  comfyui-detail-daemon \
  comfyui-dream-project \
  comfyui-easy-use \
  comfyui-frame-interpolation \
  ComfyUI-Impact-Pack \
  ComfyUI-Inspire-Pack \
  comfyui-kjnodes \
  ComfyUI-mxToolkit \
  comfyui-reactor \
  comfyui-various \
  ComfyUI-VideoHelperSuite \
  comfyui_controlnet_aux \
  comfyui_slk_joy_caption_two \
  comfyui_ttp_toolset \
  ComfyUI_UltimateSDUpscale \
  ControlAltAI-Nodes \
  ea-nodes \
  jovimetrix \
  rgthree-comfy \
  was-ns

RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_pussy_spread.safetensors -O /comfyui/models/loras/flux_pussy_spread.safetensors
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_dildo_riding.safetensors -O /comfyui/models/loras/flux_dildo_riding.safetensors
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_dildo_insertion.safetensors -O /comfyui/models/loras/flux_dildo_insertion.safetensors
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_fingering.safetensors -O /comfyui/models/loras/flux_fingering.safetensors
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_nsfw.safetensors -O /comfyui/models/loras/flux_nsfw.safetensors
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_real.safetensors -O /comfyui/models/loras/flux_real.safetensors

WORKDIR /comfyui