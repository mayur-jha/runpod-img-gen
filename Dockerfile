# Build argument for base image selection
# ARG BASE_IMAGE=nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04
FROM runpod/worker-comfyui:5.4.1-flux1-dev
RUN comfy-node-install ComfyUI-Custom-Scripts ComfyUI-Impact-Pack ComfyUI_essentials cg-use-everywhere ComfyUI-Inspire-Pack
WORKDIR /comfyui
RUN wget --content-disposition https://civitai.com/api/download/models/1092656?token=d26939efec71d18cb3e1ffe1d7c8cff7 -O models/loras/flux_pussy_spread.safetensors
RUN wget --content-disposition https://civitai.com/api/download/models/1176213?token=d26939efec71d18cb3e1ffe1d7c8cff7 -O models/loras/flux_dildo_riding.safetensors
RUN wget --content-disposition https://civitai.com/api/download/models/1539734?token=d26939efec71d18cb3e1ffe1d7c8cff7 -O models/loras/flux_dildo_insertion.safetensors
RUN wget --content-disposition https://civitai.com/api/download/models/928767?token=d26939efec71d18cb3e1ffe1d7c8cff7 -O models/loras/flux_fingering.safetensors
RUN wget --content-disposition https://civitai.com/api/download/models/746602?token=d26939efec71d18cb3e1ffe1d7c8cff7 -O models/loras/flux_nsfw.safetensors
RUN wget --content-disposition https://civitai.com/api/download/models/804967?token=d26939efec71d18cb3e1ffe1d7c8cff7 -O models/loras/flux_hands.safetensors