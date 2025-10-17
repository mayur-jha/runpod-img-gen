# Build argument for base image selection
# ARG BASE_IMAGE=nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04
FROM runpod/worker-comfyui:5.4.1-flux1-dev

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


# Existing LoRAs
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_pussy_spread.safetensors -O /comfyui/models/loras/flux_pussy_spread.safetensors
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_dildo_riding.safetensors -O /comfyui/models/loras/flux_dildo_riding.safetensors
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_dildo_insertion.safetensors -O /comfyui/models/loras/flux_dildo_insertion.safetensors
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_fingering.safetensors -O /comfyui/models/loras/flux_fingering.safetensors
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_nsfw.safetensors -O /comfyui/models/loras/flux_nsfw.safetensors
RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/flux_real.safetensors -O /comfyui/models/loras/flux_real.safetensors

# New LoRAs
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1755968594823_skxuq6755_model_1755968642477_nKta.safetensors -O 1755968594823_skxuq6755_model_1755968642477_nKta.safetensors
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1755494543682_r46djhxya_model_1755507107159_n3jr.safetensors -O 1755494543682_r46djhxya_model_1755507107159_n3jr.safetensors
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1755494543682_r46djhxya_model_1755494695820_vniS.safetensors -O 1755494543682_r46djhxya_model_1755494695820_vniS.safetensors
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1755300817615_m5bmqedq2_model_1755300871103_Rg0q.safetensors -O 1755300817615_m5bmqedq2_model_1755300871103_Rg0q.safetensors
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1755296166201_998bp3p6t_model_1755358001390_ATwm.safetensors -O 1755296166201_998bp3p6t_model_1755358001390_ATwm.safetensors
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1753002382801_1ty4w3r1d_model_1756027323_emma.safetensors -O 1753002382801_1ty4w3r1d_model_1756027323_emma.safetensors
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1753002382801_1ty4w3r1d_model_1755442417891_CD2q.safetensors -O 1753002382801_1ty4w3r1d_model_1755442417891_CD2q.safetensors
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1753002382801_1ty4w3r1d_model_1755437117567_wDl7.safetensors -O 1753002382801_1ty4w3r1d_model_1755437117567_wDl7.safetensors
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1753002382801_1ty4w3r1d_model_1755431401251_xhhV.safetensors -O 1753002382801_1ty4w3r1d_model_1755431401251_xhhV.safetensors
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1753002382801_1ty4w3r1d_model_1755408499686_whxS.safetensors -O 1753002382801_1ty4w3r1d_model_1755408499686_whxS.safetensors
# RUN wget --content-disposition https://fluxloraimage.s3.us-east-1.amazonaws.com/1753002382801_1ty4w3r1d_model_1754930238194_AuDZ_bck.safetensors -O 1753002382801_1ty4w3r1d_model_1754930238194_AuDZ_bck.safetensors



