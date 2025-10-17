
=============================================== File: .runpod/README.md ================================================

![ComfyUI Worker Banner](https://cpjrphpz3t5wbwfe.public.blob.vercel-storage.com/worker-comfyui_banner-CDZ6JIEByEePozCT1ZrmeVOsN5NX3U.jpeg)

---

Run [ComfyUI](https://github.com/comfyanonymous/ComfyUI) workflows as a serverless endpoint.

---

[![RunPod](https://api.runpod.io/badge/runpod-workers/worker-comfyui)](https://www.runpod.io/console/hub/runpod-workers/worker-comfyui)

---

## What is included?

This worker comes with the **FLUX.1-dev-fp8** (`flux1-dev-fp8.safetensors`) model pre-installed and works only with this model when deployed from the hub. If you want to use a different model, you have to [deploy the endpoint](https://github.com/runpod-workers/worker-comfyui/blob/main/docs/deployment.md) using one of these pre-defined Docker images:

- `runpod/worker-comfyui:<version>-base` - Clean ComfyUI install with no models
- `runpod/worker-comfyui:<version>-flux1-schnell` - FLUX.1 schnell model
- `runpod/worker-comfyui:<version>-flux1-dev` - FLUX.1 dev model
- `runpod/worker-comfyui:<version>-sdxl` - Stable Diffusion XL model
- `runpod/worker-comfyui:<version>-sd3` - Stable Diffusion 3 medium model

Replace `<version>` with the latest release version from [GitHub Releases](https://github.com/runpod-workers/worker-comfyui/releases)

If you need a different model or you have a LoRA or need custom nodes, then please follow our [Customization Guide](https://github.com/runpod-workers/worker-comfyui/blob/main/docs/customization.md) to create your own custom worker.

## Usage

The worker accepts the following input parameters:

| Parameter  | Type     | Default | Required | Description                                                                                                                                                                                                                                    |
| :--------- | :------- | :------ | :------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `workflow` | `object` | `None`  | **Yes**  | The entire ComfyUI workflow in the API JSON format. See the main project [README.md](https://github.com/runpod-workers/worker-comfyui#how-to-get-the-workflow-from-comfyui) for instructions on how to export this from the ComfyUI interface. |
| `images`   | `array`  | `[]`    | No       | An optional array of input images. Each image object should contain `name` (string, required, filename to reference in the workflow) and `image` (string, required, base64-encoded image data).                                                |

> [!NOTE]
> The `input.images` array has specific size constraints based on RunPod API limits (10MB for `/run`, 20MB for `/runsync`). See the main [README.md](https://github.com/runpod-workers/worker-comfyui#inputimages) for details.

### Example Request

This example uses a simplified workflow (replace with your actual workflow JSON).

```json
{
  "input": {
    "workflow": {
      "6": {
        "inputs": {
          "text": "anime cat with massive fluffy fennec ears and a big fluffy tail blonde messy long hair blue eyes wearing a construction outfit placing a fancy black forest cake with candles on top of a dinner table of an old dark Victorian mansion lit by candlelight with a bright window to the foggy forest and very expensive stuff everywhere there are paintings on the walls",
          "clip": ["30", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Positive Prompt)"
        }
      },
      "8": {
        "inputs": {
          "samples": ["31", 0],
          "vae": ["30", 2]
        },
        "class_type": "VAEDecode",
        "_meta": {
          "title": "VAE Decode"
        }
      },
      "9": {
        "inputs": {
          "filename_prefix": "ComfyUI",
          "images": ["8", 0]
        },
        "class_type": "SaveImage",
        "_meta": {
          "title": "Save Image"
        }
      },
      "27": {
        "inputs": {
          "width": 512,
          "height": 512,
          "batch_size": 1
        },
        "class_type": "EmptySD3LatentImage",
        "_meta": {
          "title": "EmptySD3LatentImage"
        }
      },
      "30": {
        "inputs": {
          "ckpt_name": "flux1-dev-fp8.safetensors"
        },
        "class_type": "CheckpointLoaderSimple",
        "_meta": {
          "title": "Load Checkpoint"
        }
      },
      "31": {
        "inputs": {
          "seed": 243057879077961,
          "steps": 10,
          "cfg": 1,
          "sampler_name": "euler",
          "scheduler": "simple",
          "denoise": 1,
          "model": ["30", 0],
          "positive": ["35", 0],
          "negative": ["33", 0],
          "latent_image": ["27", 0]
        },
        "class_type": "KSampler",
        "_meta": {
          "title": "KSampler"
        }
      },
      "33": {
        "inputs": {
          "text": "",
          "clip": ["30", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Negative Prompt)"
        }
      },
      "35": {
        "inputs": {
          "guidance": 3.5,
          "conditioning": ["6", 0]
        },
        "class_type": "FluxGuidance",
        "_meta": {
          "title": "FluxGuidance"
        }
      },
      "38": {
        "inputs": {
          "images": ["8", 0]
        },
        "class_type": "PreviewImage",
        "_meta": {
          "title": "Preview Image"
        }
      },
      "40": {
        "inputs": {
          "filename_prefix": "ComfyUI",
          "images": ["8", 0]
        },
        "class_type": "SaveImage",
        "_meta": {
          "title": "Save Image"
        }
      }
    }
  }
}
```

### Example Response

```json
{
  "delayTime": 2188,
  "executionTime": 2297,
  "id": "sync-c0cd1eb2-068f-4ecf-a99a-55770fc77391-e1",
  "output": {
    "message": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAABAAAAAQACAIAAADwf7zU...",
    "status": "success"
  },
  "status": "COMPLETED"
}
```


================================================ File: .runpod/hub.json ================================================

{
  "title": "ComfyUI",
  "description": "Generate images with ComfyUI using FLUX.1-dev (fp8)",
  "type": "serverless",
  "category": "image",
  "iconUrl": "https://cpjrphpz3t5wbwfe.public.blob.vercel-storage.com/comfyui-logo-zpFUpCZoYMn5L0Ea9hfYOKX6F9gYqx.png",
  "config": {
    "runsOn": "GPU",
    "containerDiskInGb": 20,
    "gpuIds": "ADA_24",
    "gpuCount": 1,
    "allowedCudaVersions": ["12.7", "12.6"],
    "env": [
      {
        "key": "REFRESH_WORKER",
        "input": {
          "name": "Refresh Worker",
          "type": "boolean",
          "description": "When enabled, the worker will stop after each finished job to have a clean state",
          "default": false
        }
      }
    ]
  }
}


=============================================== File: .runpod/tests.json ===============================================

{
  "tests": [
    {
      "name": "basic_test",
      "input": {
        "images": [
          {
            "name": "test.png",
            "image": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAAMklEQVR4nGI5ZdXAQEvARFPTRy0YtWDUglELRi0YtWDUglELRi0YtWDUAioCQAAAAP//E24Bx3jUKuYAAAAASUVORK5CYII="
          }
        ],
        "workflow": {
          "6": {
            "inputs": {
              "text": "anime cat with massive fluffy fennec ears and a big fluffy tail blonde messy long hair blue eyes wearing a construction outfit placing a fancy black forest cake with candles on top of a dinner table of an old dark Victorian mansion lit by candlelight with a bright window to the foggy forest and very expensive stuff everywhere there are paintings on the walls",
              "clip": ["30", 1]
            },
            "class_type": "CLIPTextEncode",
            "_meta": {
              "title": "CLIP Text Encode (Positive Prompt)"
            }
          },
          "8": {
            "inputs": {
              "samples": ["31", 0],
              "vae": ["30", 2]
            },
            "class_type": "VAEDecode",
            "_meta": {
              "title": "VAE Decode"
            }
          },
          "9": {
            "inputs": {
              "filename_prefix": "ComfyUI",
              "images": ["8", 0]
            },
            "class_type": "SaveImage",
            "_meta": {
              "title": "Save Image"
            }
          },
          "27": {
            "inputs": {
              "width": 512,
              "height": 512,
              "batch_size": 1
            },
            "class_type": "EmptySD3LatentImage",
            "_meta": {
              "title": "EmptySD3LatentImage"
            }
          },
          "30": {
            "inputs": {
              "ckpt_name": "flux1-dev-fp8.safetensors"
            },
            "class_type": "CheckpointLoaderSimple",
            "_meta": {
              "title": "Load Checkpoint"
            }
          },
          "31": {
            "inputs": {
              "seed": 243057879077961,
              "steps": 10,
              "cfg": 1,
              "sampler_name": "euler",
              "scheduler": "simple",
              "denoise": 1,
              "model": ["30", 0],
              "positive": ["35", 0],
              "negative": ["33", 0],
              "latent_image": ["27", 0]
            },
            "class_type": "KSampler",
            "_meta": {
              "title": "KSampler"
            }
          },
          "33": {
            "inputs": {
              "text": "",
              "clip": ["30", 1]
            },
            "class_type": "CLIPTextEncode",
            "_meta": {
              "title": "CLIP Text Encode (Negative Prompt)"
            }
          },
          "35": {
            "inputs": {
              "guidance": 3.5,
              "conditioning": ["6", 0]
            },
            "class_type": "FluxGuidance",
            "_meta": {
              "title": "FluxGuidance"
            }
          },
          "38": {
            "inputs": {
              "images": ["8", 0]
            },
            "class_type": "PreviewImage",
            "_meta": {
              "title": "Preview Image"
            }
          },
          "40": {
            "inputs": {
              "filename_prefix": "ComfyUI",
              "images": ["8", 0]
            },
            "class_type": "SaveImage",
            "_meta": {
              "title": "Save Image"
            }
          }
        }
      },
      "timeout": 300000
    }
  ],
  "config": {
    "gpuTypeId": "NVIDIA GeForce RTX 4090",
    "gpuCount": 1,
    "env": [
      {
        "key": "REFRESH_WORKER",
        "value": "false"
      }
    ],
    "allowedCudaVersions": ["12.7", "12.6"]
  }
}


================================================== File: CHANGELOG.md ==================================================

# [5.3.0](https://github.com/runpod-workers/worker-comfyui/compare/5.2.0...5.3.0) (2025-07-22)


### Features

* add support for 5090/B200 ([#150](https://github.com/runpod-workers/worker-comfyui/issues/150)) ([7492513](https://github.com/runpod-workers/worker-comfyui/commit/7492513490bc1723503dded682ee2c313a1c8ea6))

# [5.2.0](https://github.com/runpod-workers/worker-comfyui/compare/5.1.1...5.2.0) (2025-07-02)


### Features

* update comfyui to 0.3.43 ([#145](https://github.com/runpod-workers/worker-comfyui/issues/145)) ([32c2395](https://github.com/runpod-workers/worker-comfyui/commit/32c23956a44dae4cd3800d6de9491539065a200a))

## [5.1.1](https://github.com/runpod-workers/worker-comfyui/compare/5.1.0...5.1.1) (2025-07-01)


### Bug Fixes

* update runpod to 1.7.12 ([#144](https://github.com/runpod-workers/worker-comfyui/issues/144)) ([c689eda](https://github.com/runpod-workers/worker-comfyui/commit/c689eda26b8d9505a0a63d6d4af6f8cab997e24f))

# [5.1.0](https://github.com/runpod-workers/worker-comfyui/compare/5.0.4...5.1.0) (2025-05-28)


### Bug Fixes

* add missing libs needed for "opencv" to work ([33cd5d3](https://github.com/runpod-workers/worker-comfyui/commit/33cd5d349f76e4a393a3a4f3e99f954989b2c683))
* use proper example that actually can be copied & pasted ([506fac1](https://github.com/runpod-workers/worker-comfyui/commit/506fac10480ec238110ae0dcb59b0b6865879471))


### Features

* added COMFY_LOG_LEVEL to control the logs from ComfyUI ([183de1c](https://github.com/runpod-workers/worker-comfyui/commit/183de1cdececa217abcbec30545e24c5820eba97))
* added script "comfy-manager-set-mode" to set the "network mode" ([4d5425f](https://github.com/runpod-workers/worker-comfyui/commit/4d5425f211b85b95e4953f6c0ddf27ed92e3cfa1))
* added script "comfy-node-install" as a wrapper to "comfy-cli" to proivde a proper exit code when something is not corret ([6605506](https://github.com/runpod-workers/worker-comfyui/commit/660550637bceb72052ef7c1dec9d6f36035a2fd2))
* improved logging & provide actual reason why the workflow validation might fail ([7582999](https://github.com/runpod-workers/worker-comfyui/commit/7582999209d9683c198aa1c6d3793a16fe059416))
* updated to ubuntu 24.04 & python 3.12 to support ffmpeg 6 ([eb8dd26](https://github.com/runpod-workers/worker-comfyui/commit/eb8dd265e0823b39974dc91bbb489b54ac92c8d3))

# [5.0.0](https://github.com/runpod-workers/worker-comfyui/compare/4.0.1...5.0.0) (2025-05-02)


### Features

* multiple output images; replace http polling with websocket to check when a workflow is done ([#118](https://github.com/runpod-workers/worker-comfyui/issues/118)) ([b14068f](https://github.com/runpod-workers/worker-comfyui/commit/b14068f8e7da4790d2de5d4b710a08d26d0c131f))


### BREAKING CHANGES

* api output is not compatible anymore

* docs: added all possible comfyui folders; simplified guide of method 1

* fix(model): flux.1-schnell is gated

* feat: update to 0.3.30

* test: don't run "snapshot_restoration" tests

* chore: force local images

* docs: lowercase for code comments

* ci: run release for changes in "main"

* fix: workflow trigger

* ci: build only base for now

# [4.1.0](https://github.com/runpod-workers/worker-comfyui/compare/4.0.1...4.1.0) (2025-05-02)


### Bug Fixes

* moved code back into stage 1 ([d9ed145](https://github.com/runpod-workers/worker-comfyui/commit/d9ed14571308ad27481ae2dda4762d32b73b5d20))


### Features

* move stuff around ([2b2bc12](https://github.com/runpod-workers/worker-comfyui/commit/2b2bc1238dec5715092fa4b3e1418b8a443a409b))
* removed polling; added websocket; allow multiple output images; ([79a560f](https://github.com/runpod-workers/worker-comfyui/commit/79a560f46fbd303828175d138098faebd4baa97e))

# [3.6.0](https://github.com/blib-la/runpod-worker-comfy/compare/3.5.0...3.6.0) (2025-03-12)


### Features

* update comfyui to 0.3.26 ([ac0269e](https://github.com/blib-la/runpod-worker-comfy/commit/ac0269e683a0bcba43fafad40d4b56f51cad2588))

# [3.5.0](https://github.com/blib-la/runpod-worker-comfy/compare/3.4.0...3.5.0) (2025-03-12)


### Features

* added support for hub ([c8dd49c](https://github.com/blib-la/runpod-worker-comfy/commit/c8dd49cc2d8c23d58b48b1823bdecc3267f9accd))

# [3.4.0](https://github.com/blib-la/runpod-worker-comfy/compare/3.3.0...3.4.0) (2024-11-19)


### Bug Fixes

* start the container in all cases ([413707b](https://github.com/blib-la/runpod-worker-comfy/commit/413707bf130eb736afd682adac8b37fa64a5c9a4))


### Features

* simplified and added compatibility with Windows ([9f41231](https://github.com/blib-la/runpod-worker-comfy/commit/9f412316a743f0539981b408c1ccd0692cff5c82))

# [3.3.0](https://github.com/blib-la/runpod-worker-comfy/compare/3.2.1...3.3.0) (2024-11-18)


### Bug Fixes

* added missing start command ([9a7ffdb](https://github.com/blib-la/runpod-worker-comfy/commit/9a7ffdb078d2f75194c86ed0b8c2d027592e52c3))


### Features

* added sensible defaults and default platform ([3f5162a](https://github.com/blib-la/runpod-worker-comfy/commit/3f5162af85ee7d0002ad65a7e324c3850e00a229))

## [3.2.1](https://github.com/blib-la/runpod-worker-comfy/compare/3.2.0...3.2.1) (2024-11-18)


### Bug Fixes

* update the version inside of semanticrelease ([d93e991](https://github.com/blib-la/runpod-worker-comfy/commit/d93e991b82251d62500e20c367a087d22d58b20a))

# [3.2.0](https://github.com/blib-la/runpod-worker-comfy/compare/3.1.2...3.2.0) (2024-11-18)


### Features

* automatically update latest version ([7d846e8](https://github.com/blib-la/runpod-worker-comfy/commit/7d846e8ca3edcea869db3e680f0b423b8a98cc4c))

## [3.1.2](https://github.com/blib-la/runpod-worker-comfy/compare/3.1.1...3.1.2) (2024-11-10)


### Bug Fixes

* convert environment variables to int ([#70](https://github.com/blib-la/runpod-worker-comfy/issues/70)) ([7ab3d2a](https://github.com/blib-la/runpod-worker-comfy/commit/7ab3d2a234325c2a502002ea7bdee7df3e0c8dfe))

## [3.1.1](https://github.com/blib-la/runpod-worker-comfy/compare/3.1.0...3.1.1) (2024-11-10)


### Bug Fixes

* create directories which are required to run ComfyUI ([#58](https://github.com/blib-la/runpod-worker-comfy/issues/58)) ([6edf62b](https://github.com/blib-la/runpod-worker-comfy/commit/6edf62b0f4cd99dba5c22dd76f51c886f57a28ed))

# [3.1.0](https://github.com/blib-la/runpod-worker-comfy/compare/3.0.0...3.1.0) (2024-08-19)


### Features

* added FLUX.1 schnell & dev ([9170191](https://github.com/blib-la/runpod-worker-comfy/commit/9170191eccb65de2f17009f68952a18fc008fa6a))

# [3.0.0](https://github.com/blib-la/runpod-worker-comfy/compare/2.2.0...3.0.0) (2024-07-26)

### Features

- support sd3 ([#46](https://github.com/blib-la/runpod-worker-comfy/issues/46)) ([dde69d6](https://github.com/blib-la/runpod-worker-comfy/commit/dde69d6ca75eb7e4c5f01fd17e6da5b62f8a401f))
- provide a base image (#41)

### BREAKING CHANGES

- we have 3 different images now instead of just one:
  - `timpietruskyblibla/runpod-worker-comfy:3.0.0-base`: doesn't contain any checkpoints, just a clean ComfyUI image
  - `timpietruskyblibla/runpod-worker-comfy:3.0.0-sdxl`: contains the checkpoints and VAE for Stable Diffusion XL
    - Checkpoint: [sd_xl_base_1.0.safetensors](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0)
    - VAEs:
      - [sdxl_vae.safetensors](https://huggingface.co/stabilityai/sdxl-vae/)
      - [sdxl-vae-fp16-fix](https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/)
  - `timpietruskyblibla/runpod-worker-comfy:3.0.0-sd3`: contains the [sd3_medium_incl_clips_t5xxlfp8.safetensors](https://huggingface.co/stabilityai/stable-diffusion-3-medium) checkpoint for Stable Diffusion 3
- `latest` will not be updated anymore
- every branch gets their own 3 images deployed automatically to Docker Hub

# [2.2.0](https://github.com/blib-la/runpod-worker-comfy/compare/2.1.3...2.2.0) (2024-06-04)

### Bug Fixes

- don’t persist credentials ([1546420](https://github.com/blib-la/runpod-worker-comfy/commit/15464201b24de0746fe365e7635540330887a393))
- use custom GITHUB_TOKEN to bypass branch protection ([9b6468a](https://github.com/blib-la/runpod-worker-comfy/commit/9b6468a40b8a476d7812423ff6fe7b73f5f91f1d))

### Features

- network-volume; execution time config; skip default images; access ComfyUI via web ([#35](https://github.com/blib-la/runpod-worker-comfy/issues/35)) ([070cde5](https://github.com/blib-la/runpod-worker-comfy/commit/070cde5460203e24e3fbf68c4ff6c9a9b7910f3f)), closes [#16](https://github.com/blib-la/runpod-worker-comfy/issues/16)

## [2.1.3](https://github.com/blib-la/runpod-worker-comfy/compare/2.1.2...2.1.3) (2024-05-28)

### Bug Fixes

- images in subfolders are not working, fixes [#12](https://github.com/blib-la/runpod-worker-comfy/issues/12) ([37480c2](https://github.com/blib-la/runpod-worker-comfy/commit/37480c2d217698f799f6388ff311b9f8c6c38804))

## [2.1.2](https://github.com/blib-la/runpod-worker-comfy/compare/2.1.1...2.1.2) (2024-05-27)

### Bug Fixes

- removed xl_more_art-full_v1 because civitai requires login now ([2e8e638](https://github.com/blib-la/runpod-worker-comfy/commit/2e8e63801a7672e4923eaad0c18a4b3e2c14d79c))

## [2.1.1](https://github.com/blib-la/runpod-worker-comfy/compare/2.1.0...2.1.1) (2024-05-27)

### Bug Fixes

- check_server default values for delay and check-interval ([4945a9d](https://github.com/blib-la/runpod-worker-comfy/commit/4945a9d65b55aae9117591c8d64f9882d200478e))

# [2.1.0](https://github.com/blib-la/runpod-worker-comfy/compare/2.0.0...2.1.0) (2024-02-12)

### Bug Fixes

- **semantic-release:** added .releaserc ([#21](https://github.com/blib-la/runpod-worker-comfy/issues/21)) ([12b763d](https://github.com/blib-la/runpod-worker-comfy/commit/12b763d8703ce07331a16d4013975f9edc4be3ff))

### Features

- run the worker locally ([#19](https://github.com/blib-la/runpod-worker-comfy/issues/19)) ([34eb32b](https://github.com/blib-la/runpod-worker-comfy/commit/34eb32b72455e6e628849e50405ed172d846d2d9))

# (2023-11-18)

## [1.1.1](https://github.com/blib-la/runpod-worker-comfy/compare/1.1.0...1.1.1) (2023-11-17)

### Bug Fixes

- return the output of "process_output_image" and access jobId correctly ([#11](https://github.com/blib-la/runpod-worker-comfy/issues/11)) ([dc655ea](https://github.com/blib-la/runpod-worker-comfy/commit/dc655ea0dd0b294703f52f6017ce095c3b411527))

# [1.1.0](https://github.com/blib-la/runpod-worker-comfy/compare/1.0.0...1.1.0) (2023-11-17)

### Bug Fixes

- path should be "loras" and not "lora" ([8e579f6](https://github.com/blib-la/runpod-worker-comfy/commit/8e579f63e18851b0be67bff7a42a8e8a46223f2b))

### Features

- added unit tests for everthing, refactored the code to make it better testable, added test images ([a7492ec](https://github.com/blib-la/runpod-worker-comfy/commit/a7492ec8f289fc64b8e54c319f47804c0a15ae54))
- added xl_more_art-full_v1, improved comments ([9aea8ab](https://github.com/blib-la/runpod-worker-comfy/commit/9aea8abe1375f3d48aa9742c444b5242111e3121))
- base64 image output ([#8](https://github.com/blib-la/runpod-worker-comfy/issues/8)) ([76bf0b1](https://github.com/blib-la/runpod-worker-comfy/commit/76bf0b166b992a208c53f5cb98bd20a7e3c7f933))

# [1.0.0](https://github.com/blib-la/runpod-worker-comfy/compare/ecfec1349da0d04ea5f21c82d8903e1a5bd3c923...1.0.0) (2023-10-12)

### Bug Fixes

- don't run ntpdate as this is not working in GitHub Actions ([2f7bd3f](https://github.com/blib-la/runpod-worker-comfy/commit/2f7bd3f71f24dd3b6ecc56f3a4c27bbc2d140eca))
- got rid of syntax error ([c04de4d](https://github.com/blib-la/runpod-worker-comfy/commit/c04de4dea93dbe586a9a887e04907b33597ff73e))
- updated path to "comfyui" ([37f66d0](https://github.com/blib-la/runpod-worker-comfy/commit/37f66d04b8c98810714ffbc761412f3fcdb1d861))

### Features

- added default ComfyUI workflow ([fa6c385](https://github.com/blib-la/runpod-worker-comfy/commit/fa6c385e0dc9487655b42772bb6f3a5f5218864e))
- added runpod as local dependency ([9deae9f](https://github.com/blib-la/runpod-worker-comfy/commit/9deae9f5ec723b93540e6e2deac04b8650cf872a))
- example on how to configure the .env ([4ed5296](https://github.com/blib-la/runpod-worker-comfy/commit/4ed529601394e8a105d171ab1274737392da7df5))
- logs should be written to stdout so that we can see them inside the worker ([fc731ff](https://github.com/blib-la/runpod-worker-comfy/commit/fc731fffcd79af67cf6fcdf6a6d3df6b8e30c7b5))
- simplified input ([35c2341](https://github.com/blib-la/runpod-worker-comfy/commit/35c2341deca346d4e6df82c36e101b7495f3fc03))
- simplified input to just have "prompt", removed unused code ([0c3ccda](https://github.com/blib-la/runpod-worker-comfy/commit/0c3ccda9c5c8cdc56eae829bb358ceb532b36371))
- updated path to "comfyui", added "ntpdate" to have the time of the container in sync with AWS ([2fda578](https://github.com/blib-la/runpod-worker-comfy/commit/2fda578d62460275abec11d6b2fbe5123d621d5f))
- use local ".env" to load env variables, mount "comfyui/output" to localhost so that people can see the generated images ([aa645a2](https://github.com/blib-la/runpod-worker-comfy/commit/aa645a233cd6951d296d68f7ddcf41b14b3f4cf9))
- use models from huggingface, not from local folder ([b1af369](https://github.com/blib-la/runpod-worker-comfy/commit/b1af369bb577c0aaba8875d8b2076e1888356929))
- wait until server is ready, wait until image generation is done, upload to s3 ([ecfec13](https://github.com/blib-la/runpod-worker-comfy/commit/ecfec1349da0d04ea5f21c82d8903e1a5bd3c923))


=================================================== File: Dockerfile ===================================================

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


==================================================== File: LICENSE =====================================================

GNU AFFERO GENERAL PUBLIC LICENSE
                       Version 3, 19 November 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The GNU Affero General Public License is a free, copyleft license for
software and other kinds of works, specifically designed to ensure
cooperation with the community in the case of network server software.

  The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
our General Public Licenses are intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

  Developers that use our General Public Licenses protect your rights
with two steps: (1) assert copyright on the software, and (2) offer
you this License which gives you legal permission to copy, distribute
and/or modify the software.

  A secondary benefit of defending all users' freedom is that
improvements made in alternate versions of the program, if they
receive widespread use, become available for other developers to
incorporate.  Many developers of free software are heartened and
encouraged by the resulting cooperation.  However, in the case of
software used on network servers, this result may fail to come about.
The GNU General Public License permits making a modified version and
letting the public access it on a server without ever releasing its
source code to the public.

  The GNU Affero General Public License is designed specifically to
ensure that, in such cases, the modified source code becomes available
to the community.  It requires the operator of a network server to
provide the source code of the modified version running there to the
users of that server.  Therefore, public use of a modified version, on
a publicly accessible server, gives the public access to the source
code of the modified version.

  An older license, called the Affero General Public License and
published by Affero, was designed to accomplish similar goals.  This is
a different license, not a version of the Affero GPL, but Affero has
released a new version of the Affero GPL which permits relicensing under
this license.

  The precise terms and conditions for copying, distribution and
modification follow.

                       TERMS AND CONDITIONS

  0. Definitions.

  "This License" refers to version 3 of the GNU Affero General Public License.

  "Copyright" also means copyright-like laws that apply to other kinds of
works, such as semiconductor masks.

  "The Program" refers to any copyrightable work licensed under this
License.  Each licensee is addressed as "you".  "Licensees" and
"recipients" may be individuals or organizations.

  To "modify" a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of an
exact copy.  The resulting work is called a "modified version" of the
earlier work or a work "based on" the earlier work.

  A "covered work" means either the unmodified Program or a work based
on the Program.

  To "propagate" a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy.  Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

  To "convey" a work means any kind of propagation that enables other
parties to make or receive copies.  Mere interaction with a user through
a computer network, with no transfer of a copy, is not conveying.

  An interactive user interface displays "Appropriate Legal Notices"
to the extent that it includes a convenient and prominently visible
feature that (1) displays an appropriate copyright notice, and (2)
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License.  If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

  1. Source Code.

  The "source code" for a work means the preferred form of the work
for making modifications to it.  "Object code" means any non-source
form of a work.

  A "Standard Interface" means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

  The "System Libraries" of an executable work include anything, other
than the work as a whole, that (a) is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and (b) serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form.  A
"Major Component", in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

  The "Corresponding Source" for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities.  However, it does not include the work's
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work.  For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

  The Corresponding Source need not include anything that users
can regenerate automatically from other parts of the Corresponding
Source.

  The Corresponding Source for a work in source code form is that
same work.

  2. Basic Permissions.

  All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met.  This License explicitly affirms your unlimited
permission to run the unmodified Program.  The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work.  This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

  You may make, run and propagate covered works that you do not
convey, without conditions so long as your license otherwise remains
in force.  You may convey covered works to others for the sole purpose
of having them make modifications exclusively for you, or provide you
with facilities for running those works, provided that you comply with
the terms of this License in conveying all material for which you do
not control copyright.  Those thus making or running the covered works
for you must do so exclusively on your behalf, under your direction
and control, on terms that prohibit them from making any copies of
your copyrighted material outside their relationship with you.

  Conveying under any other circumstances is permitted solely under
the conditions stated below.  Sublicensing is not allowed; section 10
makes it unnecessary.

  3. Protecting Users' Legal Rights From Anti-Circumvention Law.

  No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

  When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such circumvention
is effected by exercising rights under this License with respect to
the covered work, and you disclaim any intention to limit operation or
modification of the work as a means of enforcing, against the work's
users, your or third parties' legal rights to forbid circumvention of
technological measures.

  4. Conveying Verbatim Copies.

  You may convey verbatim copies of the Program's source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

  You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

  5. Conveying Modified Source Versions.

  You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these conditions:

    a) The work must carry prominent notices stating that you modified
    it, and giving a relevant date.

    b) The work must carry prominent notices stating that it is
    released under this License and any conditions added under section
    7.  This requirement modifies the requirement in section 4 to
    "keep intact all notices".

    c) You must license the entire work, as a whole, under this
    License to anyone who comes into possession of a copy.  This
    License will therefore apply, along with any applicable section 7
    additional terms, to the whole of the work, and all its parts,
    regardless of how they are packaged.  This License gives no
    permission to license the work in any other way, but it does not
    invalidate such permission if you have separately received it.

    d) If the work has interactive user interfaces, each must display
    Appropriate Legal Notices; however, if the Program has interactive
    interfaces that do not display Appropriate Legal Notices, your
    work need not make them do so.

  A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
"aggregate" if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation's users
beyond what the individual works permit.  Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

  6. Conveying Non-Source Forms.

  You may convey a covered work in object code form under the terms
of sections 4 and 5, provided that you also convey the
machine-readable Corresponding Source under the terms of this License,
in one of these ways:

    a) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by the
    Corresponding Source fixed on a durable physical medium
    customarily used for software interchange.

    b) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by a
    written offer, valid for at least three years and valid for as
    long as you offer spare parts or customer support for that product
    model, to give anyone who possesses the object code either (1) a
    copy of the Corresponding Source for all the software in the
    product that is covered by this License, on a durable physical
    medium customarily used for software interchange, for a price no
    more than your reasonable cost of physically performing this
    conveying of source, or (2) access to copy the
    Corresponding Source from a network server at no charge.

    c) Convey individual copies of the object code with a copy of the
    written offer to provide the Corresponding Source.  This
    alternative is allowed only occasionally and noncommercially, and
    only if you received the object code with such an offer, in accord
    with subsection 6b.

    d) Convey the object code by offering access from a designated
    place (gratis or for a charge), and offer equivalent access to the
    Corresponding Source in the same way through the same place at no
    further charge.  You need not require recipients to copy the
    Corresponding Source along with the object code.  If the place to
    copy the object code is a network server, the Corresponding Source
    may be on a different server (operated by you or a third party)
    that supports equivalent copying facilities, provided you maintain
    clear directions next to the object code saying where to find the
    Corresponding Source.  Regardless of what server hosts the
    Corresponding Source, you remain obligated to ensure that it is
    available for as long as needed to satisfy these requirements.

    e) Convey the object code using peer-to-peer transmission, provided
    you inform other peers where the object code and Corresponding
    Source of the work are being offered to the general public at no
    charge under subsection 6d.

  A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

  A "User Product" is either (1) a "consumer product", which means any
tangible personal property which is normally used for personal, family,
or household purposes, or (2) anything designed or sold for incorporation
into a dwelling.  In determining whether a product is a consumer product,
doubtful cases shall be resolved in favor of coverage.  For a particular
product received by a particular user, "normally used" refers to a
typical or common use of that class of product, regardless of the status
of the particular user or of the way in which the particular user
actually uses, or expects or is expected to use, the product.  A product
is a consumer product regardless of whether the product has substantial
commercial, industrial or non-consumer uses, unless such uses represent
the only significant mode of use of the product.

  "Installation Information" for a User Product means any methods,
procedures, authorization keys, or other information required to install
and execute modified versions of a covered work in that User Product from
a modified version of its Corresponding Source.  The information must
suffice to ensure that the continued functioning of the modified object
code is in no case prevented or interfered with solely because
modification has been made.

  If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information.  But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

  The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or updates
for a work that has been modified or installed by the recipient, or for
the User Product in which it has been modified or installed.  Access to a
network may be denied when the modification itself materially and
adversely affects the operation of the network or violates the rules and
protocols for communication across the network.

  Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

  7. Additional Terms.

  "Additional permissions" are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law.  If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

  When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it.  (Additional permissions may be written to require their own
removal in certain cases when you modify the work.)  You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

  Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders of
that material) supplement the terms of this License with terms:

    a) Disclaiming warranty or limiting liability differently from the
    terms of sections 15 and 16 of this License; or

    b) Requiring preservation of specified reasonable legal notices or
    author attributions in that material or in the Appropriate Legal
    Notices displayed by works containing it; or

    c) Prohibiting misrepresentation of the origin of that material, or
    requiring that modified versions of such material be marked in
    reasonable ways as different from the original version; or

    d) Limiting the use for publicity purposes of names of licensors or
    authors of the material; or

    e) Declining to grant rights under trademark law for use of some
    trade names, trademarks, or service marks; or

    f) Requiring indemnification of licensors and authors of that
    material by anyone who conveys the material (or modified versions of
    it) with contractual assumptions of liability to the recipient, for
    any liability that these contractual assumptions directly impose on
    those licensors and authors.

  All other non-permissive additional terms are considered "further
restrictions" within the meaning of section 10.  If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term.  If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

  If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

  Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions;
the above requirements apply either way.

  8. Termination.

  You may not propagate or modify a covered work except as expressly
provided under this License.  Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

  However, if you cease all violation of this License, then your
license from a particular copyright holder is reinstated (a)
provisionally, unless and until the copyright holder explicitly and
finally terminates your license, and (b) permanently, if the copyright
holder fails to notify you of the violation by some reasonable means
prior to 60 days after the cessation.

  Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

  Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

  9. Acceptance Not Required for Having Copies.

  You are not required to accept this License in order to receive or
run a copy of the Program.  Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance.  However,
nothing other than this License grants you permission to propagate or
modify any covered work.  These actions infringe copyright if you do
not accept this License.  Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

  10. Automatic Licensing of Downstream Recipients.

  Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License.  You are not responsible
for enforcing compliance by third parties with this License.

  An "entity transaction" is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations.  If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party's predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

  You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License.  For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

  11. Patents.

  A "contributor" is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based.  The
work thus licensed is called the contributor's "contributor version".

  A contributor's "essential patent claims" are all patent claims
owned or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version.  For
purposes of this definition, "control" includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

  Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor's essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

  In the following three paragraphs, a "patent license" is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement).  To "grant" such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

  If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either (1) cause the Corresponding Source to be so
available, or (2) arrange to deprive yourself of the benefit of the
patent license for this particular work, or (3) arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients.  "Knowingly relying" means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient's use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

  If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

  A patent license is "discriminatory" if it does not include within
the scope of its coverage, prohibits the exercise of, or is
conditioned on the non-exercise of one or more of the rights that are
specifically granted under this License.  You may not convey a covered
work if you are a party to an arrangement with a third party that is
in the business of distributing software, under which you make payment
to the third party based on the extent of your activity of conveying
the work, and under which the third party grants, to any of the
parties who would receive the covered work from you, a discriminatory
patent license (a) in connection with copies of the covered work
conveyed by you (or copies made from those copies), or (b) primarily
for and in connection with specific products or compilations that
contain the covered work, unless you entered into that arrangement,
or that patent license was granted, prior to 28 March 2007.

  Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

  12. No Surrender of Others' Freedom.

  If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot convey a
covered work so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you may
not convey it at all.  For example, if you agree to terms that obligate you
to collect a royalty for further conveying from those to whom you convey
the Program, the only way you could satisfy both those terms and this
License would be to refrain entirely from conveying the Program.

  13. Remote Network Interaction; Use with the GNU General Public License.

  Notwithstanding any other provision of this License, if you modify the
Program, your modified version must prominently offer all users
interacting with it remotely through a computer network (if your version
supports such interaction) an opportunity to receive the Corresponding
Source of your version by providing access to the Corresponding Source
from a network server at no charge, through some standard or customary
means of facilitating copying of software.  This Corresponding Source
shall include the Corresponding Source for any work covered by version 3
of the GNU General Public License that is incorporated pursuant to the
following paragraph.

  Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU General Public License into a single
combined work, and to convey the resulting work.  The terms of this
License will continue to apply to the part which is the covered work,
but the work with which it is combined will remain governed by version
3 of the GNU General Public License.

  14. Revised Versions of this License.

  The Free Software Foundation may publish revised and/or new versions of
the GNU Affero General Public License from time to time.  Such new versions
will be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

  Each version is given a distinguishing version number.  If the
Program specifies that a certain numbered version of the GNU Affero General
Public License "or any later version" applies to it, you have the
option of following the terms and conditions either of that numbered
version or of any later version published by the Free Software
Foundation.  If the Program does not specify a version number of the
GNU Affero General Public License, you may choose any version ever published
by the Free Software Foundation.

  If the Program specifies that a proxy can decide which future
versions of the GNU Affero General Public License can be used, that proxy's
public statement of acceptance of a version permanently authorizes you
to choose that version for the Program.

  Later license versions may give you additional or different
permissions.  However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

  15. Disclaimer of Warranty.

  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

  16. Limitation of Liability.

  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

  17. Interpretation of Sections 15 and 16.

  If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

                     END OF TERMS AND CONDITIONS

            How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
state the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

Also add information on how to contact you by electronic and paper mail.

  If your software can interact with users remotely through a computer
network, you should also make sure that it provides a way for users to
get its source.  For example, if your program is a web application, its
interface could display a "Source" link that leads users to an archive
of the code.  There are many ways you could offer source, and different
solutions will be better for different programs; see section 13 for the
specific requirements.

  You should also get your employer (if you work as a programmer) or school,
if any, to sign a "copyright disclaimer" for the program, if necessary.
For more information on this, and how to apply and follow the GNU AGPL, see
<https://www.gnu.org/licenses/>.


=================================================== File: README.md ====================================================

[![Runpod](https://api.runpod.io/badge/themayurjha/serverless)](https://console.runpod.io/hub/themayurjha/serverless)

# worker-comfyui

> [ComfyUI](https://github.com/comfyanonymous/ComfyUI) as a serverless API on [RunPod](https://www.runpod.io/)

<p align="center">
  <img src="assets/worker_sitting_in_comfy_chair.jpg" title="Worker sitting in comfy chair" />
</p>

[![RunPod](https://api.runpod.io/badge/runpod-workers/worker-comfyui)](https://www.runpod.io/console/hub/runpod-workers/worker-comfyui)

---

This project allows you to run ComfyUI workflows as a serverless API endpoint on the RunPod platform. Submit workflows via API calls and receive generated images as base64 strings or S3 URLs.

## Table of Contents

- [Quickstart](#quickstart)
- [Available Docker Images](#available-docker-images)
- [API Specification](#api-specification)
- [Usage](#usage)
- [Getting the Workflow JSON](#getting-the-workflow-json)
- [Further Documentation](#further-documentation)

---

## Quickstart

1.  🐳 Choose one of the [available Docker images](#available-docker-images) for your serverless endpoint (e.g., `runpod/worker-comfyui:<version>-sd3`).
2.  📄 Follow the [Deployment Guide](docs/deployment.md) to set up your RunPod template and endpoint.
3.  ⚙️ Optionally configure the worker (e.g., for S3 upload) using environment variables - see the full [Configuration Guide](docs/configuration.md).
4.  🧪 Pick an example workflow from [`test_resources/workflows/`](./test_resources/workflows/) or [get your own](#getting-the-workflow-json).
5.  🚀 Follow the [Usage](#usage) steps below to interact with your deployed endpoint.

## Available Docker Images

These images are available on Docker Hub under `runpod/worker-comfyui`:

- **`runpod/worker-comfyui:<version>-base`**: Clean ComfyUI install with no models.
- **`runpod/worker-comfyui:<version>-flux1-schnell`**: Includes checkpoint, text encoders, and VAE for [FLUX.1 schnell](https://huggingface.co/black-forest-labs/FLUX.1-schnell).
- **`runpod/worker-comfyui:<version>-flux1-dev`**: Includes checkpoint, text encoders, and VAE for [FLUX.1 dev](https://huggingface.co/black-forest-labs/FLUX.1-dev).
- **`runpod/worker-comfyui:<version>-sdxl`**: Includes checkpoint and VAEs for [Stable Diffusion XL](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0).
- **`runpod/worker-comfyui:<version>-sd3`**: Includes checkpoint for [Stable Diffusion 3 medium](https://huggingface.co/stabilityai/stable-diffusion-3-medium).

Replace `<version>` with the current release tag, check the [releases page](https://github.com/runpod-workers/worker-comfyui/releases) for the latest version.

## API Specification

The worker exposes standard RunPod serverless endpoints (`/run`, `/runsync`, `/health`). By default, images are returned as base64 strings. You can configure the worker to upload images to an S3 bucket instead by setting specific environment variables (see [Configuration Guide](docs/configuration.md)).

Use the `/runsync` endpoint for synchronous requests that wait for the job to complete and return the result directly. Use the `/run` endpoint for asynchronous requests that return immediately with a job ID; you'll need to poll the `/status` endpoint separately to get the result.

### Input

```json
{
  "input": {
    "workflow": {
      "6": {
        "inputs": {
          "text": "a ball on the table",
          "clip": ["30", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Positive Prompt)"
        }
      }
    },
    "images": [
      {
        "name": "input_image_1.png",
        "image": "data:image/png;base64,iVBOR..."
      }
    ]
  }
}
```

The following tables describe the fields within the `input` object:

| Field Path       | Type   | Required | Description                                                                                                                                |
| ---------------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `input`          | Object | Yes      | Top-level object containing request data.                                                                                                  |
| `input.workflow` | Object | Yes      | The ComfyUI workflow exported in the [required format](#getting-the-workflow-json).                                                        |
| `input.images`   | Array  | No       | Optional array of input images. Each image is uploaded to ComfyUI's `input` directory and can be referenced by its `name` in the workflow. |

#### `input.images` Object

Each object within the `input.images` array must contain:

| Field Name | Type   | Required | Description                                                                                                                       |
| ---------- | ------ | -------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `name`     | String | Yes      | Filename used to reference the image in the workflow (e.g., via a "Load Image" node). Must be unique within the array.            |
| `image`    | String | Yes      | Base64 encoded string of the image. A data URI prefix (e.g., `data:image/png;base64,`) is optional and will be handled correctly. |

> [!NOTE]
>
> **Size Limits:** RunPod endpoints have request size limits (e.g., 10MB for `/run`, 20MB for `/runsync`). Large base64 input images can exceed these limits. See [RunPod Docs](https://docs.runpod.io/docs/serverless-endpoint-urls).

### Output

> [!WARNING]
>
> **Breaking Change in Output Format (5.0.0+)**
>
> Versions `< 5.0.0` returned the primary image data (S3 URL or base64 string) directly within an `output.message` field.
> Starting with `5.0.0`, the output format has changed significantly, see below

```json
{
  "id": "sync-uuid-string",
  "status": "COMPLETED",
  "output": {
    "images": [
      {
        "filename": "ComfyUI_00001_.png",
        "type": "base64",
        "data": "iVBORw0KGgoAAAANSUhEUg..."
      }
    ]
  },
  "delayTime": 123,
  "executionTime": 4567
}
```

| Field Path      | Type             | Required | Description                                                                                                 |
| --------------- | ---------------- | -------- | ----------------------------------------------------------------------------------------------------------- |
| `output`        | Object           | Yes      | Top-level object containing the results of the job execution.                                               |
| `output.images` | Array of Objects | No       | Present if the workflow generated images. Contains a list of objects, each representing one output image.   |
| `output.errors` | Array of Strings | No       | Present if non-fatal errors or warnings occurred during processing (e.g., S3 upload failure, missing data). |

#### `output.images`

Each object in the `output.images` array has the following structure:

| Field Name | Type   | Description                                                                                     |
| ---------- | ------ | ----------------------------------------------------------------------------------------------- |
| `filename` | String | The original filename assigned by ComfyUI during generation.                                    |
| `type`     | String | Indicates the format of the data. Either `"base64"` or `"s3_url"` (if S3 upload is configured). |
| `data`     | String | Contains either the base64 encoded image string or the S3 URL for the uploaded image file.      |

> [!NOTE]
> The `output.images` field provides a list of all generated images (excluding temporary ones).
>
> - If S3 upload is **not** configured (default), `type` will be `"base64"` and `data` will contain the base64 encoded image string.
> - If S3 upload **is** configured, `type` will be `"s3_url"` and `data` will contain the S3 URL. See the [Configuration Guide](docs/configuration.md#example-s3-response) for an S3 example response.
> - Clients interacting with the API need to handle this list-based structure under `output.images`.

## Usage

To interact with your deployed RunPod endpoint:

1.  **Get API Key:** Generate a key in RunPod [User Settings](https://www.runpod.io/console/serverless/user/settings) (`API Keys` section).
2.  **Get Endpoint ID:** Find your endpoint ID on the [Serverless Endpoints](https://www.runpod.io/console/serverless/user/endpoints) page or on the `Overview` page of your endpoint.

### Generate Image (Sync Example)

Send a workflow to the `/runsync` endpoint (waits for completion). Replace `<api_key>` and `<endpoint_id>`. The `-d` value should contain the [JSON input described above](#input).

```bash
curl -X POST \
  -H "Authorization: Bearer <api_key>" \
  -H "Content-Type: application/json" \
  -d '{"input":{"workflow":{... your workflow JSON ...}}}' \
  https://api.runpod.ai/v2/<endpoint_id>/runsync
```

You can also use the `/run` endpoint for asynchronous jobs and then poll the `/status` to see when the job is done. Or you [add a `webhook` into your request](https://docs.runpod.io/serverless/endpoints/send-requests#webhook-notifications) to be notified when the job is done.

Refer to [`test_input.json`](./test_input.json) for a complete input example.

## Getting the Workflow JSON

To get the correct `workflow` JSON for the API:

1.  Open ComfyUI in your browser.
2.  In the top navigation, select `Workflow > Export (API)`
3.  A `workflow.json` file will be downloaded. Use the content of this file as the value for the `input.workflow` field in your API requests.

## Further Documentation

- **[Deployment Guide](docs/deployment.md):** Detailed steps for deploying on RunPod.
- **[Configuration Guide](docs/configuration.md):** Full list of environment variables (including S3 setup).
- **[Customization Guide](docs/customization.md):** Adding custom models and nodes (Network Volumes, Docker builds).
- **[Development Guide](docs/development.md):** Setting up a local environment for development & testing
- **[CI/CD Guide](docs/ci-cd.md):** Information about the automated Docker build and publish workflows.
- **[Acknowledgments](docs/acknowledgments.md):** Credits and thanks


================================================ File: docker-bake.hcl =================================================

variable "DOCKERHUB_REPO" {
  default = "runpod"
}

variable "DOCKERHUB_IMG" {
  default = "worker-comfyui"
}

variable "RELEASE_VERSION" {
  default = "latest"
}

variable "COMFYUI_VERSION" {
  default = "latest"
}

# Global defaults for standard CUDA 12.6.3 images
variable "BASE_IMAGE" {
  default = "nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04"
}

variable "CUDA_VERSION_FOR_COMFY" {
  default = "12.6"
}

variable "ENABLE_PYTORCH_UPGRADE" {
  default = "false"
}

variable "PYTORCH_INDEX_URL" {
  default = ""
}

variable "HUGGINGFACE_ACCESS_TOKEN" {
  default = ""
}

group "default" {
  targets = ["base", "sdxl", "sd3", "flux1-schnell", "flux1-dev", "flux1-dev-fp8", "base-cuda12-8-1"]
}

target "base" {
  context = "."
  dockerfile = "Dockerfile"
  target = "base"
  platforms = ["linux/amd64"]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "base"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-base"]
}

target "sdxl" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "sdxl"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-sdxl"]
  inherits = ["base"]
}

target "sd3" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "sd3"
    HUGGINGFACE_ACCESS_TOKEN = "${HUGGINGFACE_ACCESS_TOKEN}"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-sd3"]
  inherits = ["base"]
}

target "flux1-schnell" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "flux1-schnell"
    HUGGINGFACE_ACCESS_TOKEN = "${HUGGINGFACE_ACCESS_TOKEN}"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-flux1-schnell"]
  inherits = ["base"]
}

target "flux1-dev" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "flux1-dev"
    HUGGINGFACE_ACCESS_TOKEN = "${HUGGINGFACE_ACCESS_TOKEN}"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-flux1-dev"]
  inherits = ["base"]
}

target "flux1-dev-fp8" {
  context = "."
  dockerfile = "Dockerfile"
  target = "final"
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
    ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
    PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
    MODEL_TYPE = "flux1-dev-fp8"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-flux1-dev-fp8"]
  inherits = ["base"]
}

target "base-cuda12-8-1" {
  context = "."
  dockerfile = "Dockerfile"
  target = "base"
  platforms = ["linux/amd64"]
  args = {
    BASE_IMAGE = "nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04"
    COMFYUI_VERSION = "${COMFYUI_VERSION}"
    CUDA_VERSION_FOR_COMFY = ""
    ENABLE_PYTORCH_UPGRADE = "true"
    PYTORCH_INDEX_URL = "https://download.pytorch.org/whl/cu128"
    MODEL_TYPE = "base"
  }
  tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-base-cuda12.8.1"]
}


=============================================== File: docker-compose.yml ===============================================

services:
  comfyui-worker:
    image: runpod/worker-comfyui:dev
    pull_policy: never
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    environment:
      - SERVE_API_LOCALLY=true
    ports:
      - "8000:8000"
      - "8188:8188"
    volumes:
      - ./data/comfyui/output:/comfyui/output
      - ./data/runpod-volume:/runpod-volume


============================================ File: docs/acknowledgments.md =============================================

# Acknowledgments

- Thanks to [Blibla](https://github.com/blib-la) for providing the original repo (previously under `blib-la/runpod-worker-comfy`) to RunPod, to continue the open-source development of this worker.
- Thanks to [all contributors](https://github.com/runpod-workers/worker-comfyui/graphs/contributors) for your awesome work.
- Thanks to [Justin Merrell](https://github.com/justinmerrell) from RunPod for [worker-1111](https://github.com/runpod-workers/worker-a1111), which was used to get inspired on how to create this worker.
- Thanks to [Ashley Kleynhans](https://github.com/ashleykleynhans) for [runpod-worker-a1111](https://github.com/ashleykleynhans/runpod-worker-a1111), which was used to get inspired on how to create this worker.
- Thanks to [comfyanonymous](https://github.com/comfyanonymous) for creating [ComfyUI](https://github.com/comfyanonymous/ComfyUI), which provides such an awesome API to interact with Stable Diffusion and beyond.


================================================= File: docs/ci-cd.md ==================================================

# CI/CD

This project includes GitHub Actions workflows to automatically build and deploy Docker images to Docker Hub.

## Automatic Deployment to Docker Hub with GitHub Actions

The repository contains two workflows located in the `.github/workflows` directory:

- [`dev.yml`](../.github/workflows/dev.yml): Creates the images (base, sdxl, sd3, flux variants) and pushes them to Docker Hub tagged as `<image_name>:dev` on every push to the `main` branch.
- [`release.yml`](../.github/workflows/release.yml): Creates the images and pushes them to Docker Hub tagged as `<image_name>:latest` and `<image_name>:<release_version>` (e.g., `worker-comfyui:3.7.0`). This workflow is triggered only when a new release is created on GitHub.

### Configuration for Your Fork

If you have forked this repository and want to use these actions to publish images to your own Docker Hub account, you need to configure the following in your GitHub repository settings:

1.  **Secrets** (`Settings > Secrets and variables > Actions > New repository secret`):

    | Secret Name                | Description                                                                | Example Value       |
    | -------------------------- | -------------------------------------------------------------------------- | ------------------- |
    | `DOCKERHUB_USERNAME`       | Your Docker Hub username.                                                  | `your-dockerhub-id` |
    | `DOCKERHUB_TOKEN`          | Your Docker Hub access token with read/write permissions.                  | `dckr_pat_...`      |
    | `HUGGINGFACE_ACCESS_TOKEN` | Your READ access token from Hugging Face (required only for building SD3). | `hf_...`            |

2.  **Variables** (`Settings > Secrets and variables > Actions > New repository variable`):

    | Variable Name    | Description                                                                  | Example Value              |
    | ---------------- | ---------------------------------------------------------------------------- | -------------------------- |
    | `DOCKERHUB_REPO` | The target repository (namespace) on Docker Hub where images will be pushed. | `your-dockerhub-id`        |
    | `DOCKERHUB_IMG`  | The base name for the image to be pushed to Docker Hub.                      | `my-custom-worker-comfyui` |

With these secrets and variables configured, the actions will push the built images (e.g., `your-dockerhub-id/my-custom-worker-comfyui:dev`, `your-dockerhub-id/my-custom-worker-comfyui:1.0.0`, `your-dockerhub-id/my-custom-worker-comfyui:latest`) to your Docker Hub account when triggered.


============================================= File: docs/configuration.md ==============================================

# Configuration

This document outlines the environment variables available for configuring the `worker-comfyui`.

## General Configuration

| Environment Variable | Description                                                                                                                                                                                                                  | Default |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `REFRESH_WORKER`     | When `true`, the worker pod will stop after each completed job to ensure a clean state for the next job. See the [RunPod documentation](https://docs.runpod.io/docs/handler-additional-controls#refresh-worker) for details. | `false` |
| `SERVE_API_LOCALLY`  | When `true`, enables a local HTTP server simulating the RunPod environment for development and testing. See the [Development Guide](development.md#local-api) for more details.                                              | `false` |

## Logging Configuration

| Environment Variable | Description                                                                                                                                                      | Default |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `COMFY_LOG_LEVEL`    | Controls ComfyUI's internal logging verbosity. Options: `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`. Use `DEBUG` for troubleshooting, `INFO` for production. | `DEBUG` |

## Debugging Configuration

| Environment Variable           | Description                                                                                                            | Default |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------- | ------- |
| `WEBSOCKET_RECONNECT_ATTEMPTS` | Number of websocket reconnection attempts when connection drops during job execution.                                  | `5`     |
| `WEBSOCKET_RECONNECT_DELAY_S`  | Delay in seconds between websocket reconnection attempts.                                                              | `3`     |
| `WEBSOCKET_TRACE`              | Enable low-level websocket frame tracing for protocol debugging. Set to `true` only when diagnosing connection issues. | `false` |

> [!TIP] > **For troubleshooting:** Set `COMFY_LOG_LEVEL=DEBUG` to get detailed logs when ComfyUI crashes or behaves unexpectedly. This helps identify the exact point of failure in your workflows.

## AWS S3 Upload Configuration

Configure these variables **only** if you want the worker to upload generated images directly to an AWS S3 bucket. If these are not set, images will be returned as base64-encoded strings in the API response.

- **Prerequisites:**
  - An AWS S3 bucket in your desired region.
  - An AWS IAM user with programmatic access (Access Key ID and Secret Access Key).
  - Permissions attached to the IAM user allowing `s3:PutObject` (and potentially `s3:PutObjectAcl` if you need specific ACLs) on the target bucket.

| Environment Variable       | Description                                                                                                                             | Example                                                    |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| `BUCKET_ENDPOINT_URL`      | The full endpoint URL of your S3 bucket. **Must be set to enable S3 upload.**                                                           | `https://<your-bucket-name>.s3.<aws-region>.amazonaws.com` |
| `BUCKET_ACCESS_KEY_ID`     | Your AWS access key ID associated with the IAM user that has write permissions to the bucket. Required if `BUCKET_ENDPOINT_URL` is set. | `AKIAIOSFODNN7EXAMPLE`                                     |
| `BUCKET_SECRET_ACCESS_KEY` | Your AWS secret access key associated with the IAM user. Required if `BUCKET_ENDPOINT_URL` is set.                                      | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`                 |

**Note:** Upload uses the `runpod` Python library helper `rp_upload.upload_image`, which handles creating a unique path within the bucket based on the `job_id`.

### Example S3 Response

If the S3 environment variables (`BUCKET_ENDPOINT_URL`, `BUCKET_ACCESS_KEY_ID`, `BUCKET_SECRET_ACCESS_KEY`) are correctly configured, a successful job response will look similar to this:

```json
{
  "id": "sync-uuid-string",
  "status": "COMPLETED",
  "output": {
    "images": [
      {
        "filename": "ComfyUI_00001_.png",
        "type": "s3_url",
        "data": "https://your-bucket-name.s3.your-region.amazonaws.com/sync-uuid-string/ComfyUI_00001_.png"
      }
      // Additional images generated by the workflow would appear here
    ]
    // The "errors" key might be present here if non-fatal issues occurred
  },
  "delayTime": 123,
  "executionTime": 4567
}
```

The `data` field contains the presigned URL to the uploaded image file in your S3 bucket. The path usually includes the job ID.


============================================== File: docs/conventions.md ===============================================

# Introduction

This project (`worker-comfyui`) provides a way to run [ComfyUI](https://github.com/comfyanonymous/ComfyUI) as a serverless API worker on the [RunPod](https://www.runpod.io/) platform. Its main purpose is to allow users to submit ComfyUI image generation workflows via a simple API call and receive the resulting images, either directly as base64-encoded strings or via an upload to an AWS S3 bucket.

It packages ComfyUI into Docker images, manages job handling via the `runpod` SDK, uses websockets for efficient communication with ComfyUI, and facilitates configuration through environment variables.

# Project Conventions and Rules

This document outlines the key operational and structural conventions for the `worker-comfyui` project. While there are no strict code-style rules enforced by linters currently, following these conventions ensures consistency and smooth development/deployment.

## 1. Configuration

- **Environment Variables:** All external configurations (e.g., AWS S3 credentials, RunPod behavior modifications like `REFRESH_WORKER`) **must** be managed via environment variables.
- Refer to the main `README.md` sections "Config" and "Upload image to AWS S3" for details on available variables.

## 2. Docker Usage

- **Container-Centric:** Development, testing, and deployment are heavily reliant on Docker.
- **Platform:** When building Docker images intended for RunPod, **always** use the `--platform linux/amd64` flag to ensure compatibility.
  ```bash
  # Example build command
  docker build --platform linux/amd64 -t my-image:tag .
  ```
- **Development Builds:** For faster development iterations, use `MODEL_TYPE=base` to skip downloading external models:
  ```bash
  docker build --build-arg MODEL_TYPE=base -t runpod/worker-comfyui:dev .
  ```
- **Customization:** Follow the methods in the `README.md` for adding custom models/nodes (Network Volume or Dockerfile edits + snapshots).

## 3. API Interaction

- **Input Structure:** API calls to the `/run` or `/runsync` endpoints must adhere to the JSON structure specified in the `README.md` ("API specification"). The primary key is `input`, containing `workflow` (mandatory object) and `images` (optional array).
- **Image Encoding:** Input images provided in the `input.images` array must be base64 encoded strings (optionally including a `data:[<mediatype>];base64,` prefix).
- **Workflow Format:** The `input.workflow` object should contain the JSON exported from ComfyUI using the "Save (API Format)" option (requires enabling "Dev mode Options" in ComfyUI settings).
- **Output Structure:** Successful responses contain an `output.images` field, which is a **list of dictionaries**. Each dictionary includes `filename` (string), `type` (`"s3_url"` or `"base64"`), and `data` (string containing the URL or base64 data). Refer to the `README.md` API examples for the exact structure.
- **Internal Communication:** Job status monitoring uses the ComfyUI websocket API instead of HTTP polling for efficiency.

## 4. Error Handling

- **User-Friendly Errors:** Always surface meaningful error messages to users rather than generic HTTP errors or internal exceptions.
- **ComfyUI Integration:** When ComfyUI returns validation errors, parse the response body to extract detailed error information and present it in a structured, actionable format.
- **Helpful Context:** When possible, provide users with information about available options (e.g., available models, valid parameters) to help them correct their requests.
- **Graceful Fallbacks:** Error handling should degrade gracefully - if detailed error parsing fails, fall back to showing the raw response rather than hiding the error entirely.

## 5. Development Workflow

- **Code Changes:** After modifying handler code, always rebuild the Docker image before testing with `docker-compose`:
  ```bash
  docker-compose down
  docker build --build-arg MODEL_TYPE=base -t runpod/worker-comfyui:dev .
  docker-compose up -d
  ```
- **Debugging:** Use strategic logging/print statements to understand external API responses (like ComfyUI's error formats) before implementing error handling.
- **Testing:** Test error scenarios as thoroughly as success scenarios to ensure good user experience.

## 6. Testing

- **Unit Tests:** Automated tests are located in the `tests/` directory and should be run using `python -m unittest discover`. Add new tests for new functionality or bug fixes.
- **Local Environment:** Use `docker-compose up` for local end-to-end testing. This requires a correctly configured Docker environment with NVIDIA GPU support.

## 7. Dependencies

- **Python:** Manage Python dependencies using `pip` (or `uv`) and the `requirements.txt` file. Keep this file up-to-date.

## 8. Code Style (General Guidance)

- While not enforced by tooling, aim for code clarity and consistency. Follow general Python best practices (e.g., PEP 8).
- Use meaningful variable and function names.
- Add comments where the logic is non-obvious.

### **Model Type Detection**

Models are categorized based on node types using these mappings:

- `UpscaleModelLoader` → `upscale_models`
- `VAELoader` → `vae`
- `UNETLoader`, `UnetLoaderGGUF`, `Hy3DModelLoader` → `diffusion_models`
- `DualCLIPLoader`, `TripleCLIPLoader` → `text_encoders`
- `LoraLoader` → `loras`
- And additional specialized loaders for proper model categorization

## Custom Node Dependencies

When extending the base image with custom nodes, some nodes may require specific dependency versions to function correctly.

### **Known Compatibility Issues**

- **ComfyUI-BrushNet dependency issue:** Requires specific dependency versions: `diffusers>=0.29.0`, `accelerate>=0.29.0,<0.32.0`, and `peft>=0.7.0` to resolve import errors
- **Pattern for fixing:** When encountering import errors from custom nodes, check the dependency chain and ensure compatible versions are installed in the Dockerfile using `uv pip install`


============================================= File: docs/customization.md ==============================================

# Customization

This guide covers methods for adding your own models, custom nodes, and static input files into a custom `worker-comfyui`.

There are two primary methods for customizing your setup:

1.  **Custom Dockerfile (recommended):** Create your own `Dockerfile` starting `FROM` one of the official `worker-comfyui` base images. This allows you to bake specific custom nodes, models, and input files directly into your image using `comfy-cli` commands. **This method does not require forking the `worker-comfyui` repository.**
2.  **Network Volume:** Store models on a persistent network volume attached to your RunPod endpoint. This is useful if you frequently change models or have very large models you don't want to include in the image build process.

## Method 1: Custom Dockerfile

> [!NOTE]
>
> This method does NOT require forking the `worker-comfyui` repository.

This is the most flexible and recommended approach for creating reproducible, customized worker environments.

1.  **Create a `Dockerfile`:** In your own project directory, create a file named `Dockerfile`.
2.  **Start with a Base Image:** Begin your `Dockerfile` by referencing one of the official base images. Using the `-base` tag is recommended as it provides a clean ComfyUI install with necessary tools like `comfy-cli` but without pre-packaged models.
    ```Dockerfile
    # start from a clean base image (replace <version> with the desired [release](https://github.com/runpod-workers/worker-comfyui/releases))
    FROM runpod/worker-comfyui:<version>-base
    ```
3.  **Install Custom Nodes:** Use the `comfy-node-install` (we had introduce our own cli tool here, as there is a [problem with comfy-cli not showing errors during installation](https://github.com/Comfy-Org/comfy-cli/pull/275)) command to add custom nodes by their name or URL, see [Comfy Registry](https://registry.comfy.org) to find the correct name. You can list multiple nodes.
    ```Dockerfile
    # install custom nodes using comfy-cli
    RUN comfy-node-install comfyui-kjnodes comfyui-ic-light
    ```
4.  **Download Models:** Use the `comfy model download` command to fetch models and place them in the correct ComfyUI directories.

    ```Dockerfile
    # download models using comfy-cli
    RUN comfy model download --url https://huggingface.co/KamCastle/jugg/resolve/main/juggernaut_reborn.safetensors --relative-path models/checkpoints --filename juggernaut_reborn.safetensors
    ```

> [!NOTE]
>
> Ensure you use the correct `--relative-path` corresponding to ComfyUI's model directory structure (starting with `models/<folder>`):
>
> checkpoints, clip, clip_vision, configs, controlnet, diffusers, embeddings, gligen, hypernetworks, loras, style_models, unet, upscale_models, vae, vae_approx, animatediff_models, animatediff_motion_lora, ipadapter, photomaker, sams, insightface, facerestore_models, facedetection, mmdets, instantid

5.  **Add Static Input Files (Optional):** If your workflows consistently require specific input images, masks, videos, etc., you can copy them directly into the image.

- Create an `input/` directory in the same folder as your `Dockerfile`.
- Place your static files inside this `input/` directory.
- Add a `COPY` command to your `Dockerfile`:

  ```Dockerfile
  # Copy local static input files into the ComfyUI input directory
  COPY input/ /comfyui/input/
  ```

- These files can then be referenced in your workflow using a "Load Image" (or similar) node pointing to the filename (e.g.,`my_static_image.png`).

Once you have created your custom `Dockerfile`, refer to the [Deployment Guide](deployment.md#deploying-custom-setups) for instructions on how to build, push and deploy your custom image to RunPod.

### Complete Custom `Dockerfile` Example

```Dockerfile
# start from a clean base image (replace <version> with the desired release)
FROM runpod/worker-comfyui:5.1.0-base

# install custom nodes using comfy-cli
RUN comfy-node-install comfyui-kjnodes comfyui-ic-light comfyui_ipadapter_plus comfyui_essentials ComfyUI-Hangover-Nodes

# download models using comfy-cli
# the "--filename" is what you use in your ComfyUI workflow
RUN comfy model download --url https://huggingface.co/KamCastle/jugg/resolve/main/juggernaut_reborn.safetensors --relative-path models/checkpoints --filename juggernaut_reborn.safetensors
RUN comfy model download --url https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus_sd15.bin --relative-path models/ipadapter --filename ip-adapter-plus_sd15.bin
RUN comfy model download --url https://huggingface.co/shiertier/clip_vision/resolve/main/SD15/model.safetensors --relative-path models/clip_vision --filename models.safetensors
RUN comfy model download --url https://huggingface.co/lllyasviel/ic-light/resolve/main/iclight_sd15_fcon.safetensors --relative-path models/diffusion_models --filename iclight_sd15_fcon.safetensors

# Copy local static input files into the ComfyUI input directory (delete if not needed)
# Assumes you have an 'input' folder next to your Dockerfile
COPY input/ /comfyui/input/
```

## Method 2: Network Volume

Using a Network Volume is primarily useful if you want to manage **models** separately from your worker image, especially if they are large or change often.

1.  **Create a Network Volume**:
    - Follow the [RunPod Network Volumes guide](https://docs.runpod.io/pods/storage/create-network-volumes) to create a volume in the same region as your endpoint.
2.  **Populate the Volume with Models**:
    - Use one of the methods described in the RunPod guide (e.g., temporary Pod + `wget`, direct upload) to place your model files into the correct ComfyUI directory structure **within the volume**. The root of the volume corresponds to `/workspace` inside the container.
      ```bash
      # Example structure inside the Network Volume:
      # /models/checkpoints/your_model.safetensors
      # /models/loras/your_lora.pt
      # /models/vae/your_vae.safetensors
      ```
    - **Important:** Ensure models are placed in the correct subdirectories (e.g., checkpoints in `models/checkpoints`, LoRAs in `models/loras`).
3.  **Configure Your Endpoint**:
    - Use the Network Volume in your endpoint configuration:
      - Either create a new endpoint or update an existing one (see [Deployment Guide](deployment.md)).
      - In the endpoint configuration, under `Advanced > Select Network Volume`, select your Network Volume.

**Note:**

- When a Network Volume is correctly attached, ComfyUI running inside the worker container will automatically detect and load models from the standard directories (`/workspace/models/...`) within that volume.
- This method is **not suitable for installing custom nodes**; use the Custom Dockerfile method for that.


=============================================== File: docs/deployment.md ===============================================

# Deployment

This guide explains how to deploy the `worker-comfyui` as a serverless endpoint on RunPod, covering both pre-built official images and custom-built images.

## Deploying Pre-Built Official Images

This is the simplest method if the official images meet your needs.

### Create your template (optional)

- Create a [new template](https://runpod.io/console/serverless/user/templates) by clicking on `New Template`
- In the dialog, configure:
  - Template Name: `worker-comfyui` (or your preferred name)
  - Template Type: serverless (change template type to "serverless")
  - Container Image: Use one of the official tags, e.g., `runpod/worker-comfyui:<version>-sd3`. (Refer to the main [README.md](../README.md#available-docker-images) for available image tags and the current version).
  - Container Registry Credentials: Leave as default (images are public).
  - Container Disk: Adjust based on the chosen image tag, see [GPU Recommendations](#gpu-recommendations).
  - (optional) Environment Variables: Configure S3 or other settings (see [Configuration Guide](configuration.md)).
    - Note: If you don't configure S3, images are returned as base64. For persistent storage across jobs without S3, consider using a [Network Volume](customization.md#method-2-network-volume-alternative-for-models).
- Click on `Save Template`

### Create your endpoint

- Navigate to [`Serverless > Endpoints`](https://www.runpod.io/console/serverless/user/endpoints) and click on `New Endpoint`
- In the dialog, configure:

  - Endpoint Name: `comfy` (or your preferred name)
  - Worker configuration: Select a GPU that can run the model included in your chosen image (see [GPU recommendations](#gpu-recommendations)).
  - Active Workers: `0` (Scale as needed based on expected load).
  - Max Workers: `3` (Set a limit based on your budget and scaling needs).
  - GPUs/Worker: `1`
  - Idle Timeout: `5` (Default is usually fine, adjust if needed).
  - Flash Boot: `enabled` (Recommended for faster worker startup).
  - Select Template: `worker-comfyui` (or the name you gave your template).
  - (optional) Advanced: If you are using a Network Volume, select it under `Select Network Volume`. See the [Customization Guide](customization.md#method-2-network-volume-alternative-for-models).

- Click `deploy`
- Your endpoint will be created. You can click on it to view the dashboard and find its ID.

### GPU recommendations (for Official Images)

| Model                     | Image Tag Suffix | Minimum VRAM Required | Recommended Container Size |
| ------------------------- | ---------------- | --------------------- | -------------------------- |
| Stable Diffusion XL       | `sdxl`           | 8 GB                  | 15 GB                      |
| Stable Diffusion 3 Medium | `sd3`            | 5 GB                  | 20 GB                      |
| FLUX.1 Schnell            | `flux1-schnell`  | 24 GB                 | 30 GB                      |
| FLUX.1 dev                | `flux1-dev`      | 24 GB                 | 30 GB                      |
| Base (No models)          | `base`           | N/A                   | 5 GB                       |

_Note: Container sizes are approximate and might vary slightly. Custom images will vary based on included models/nodes._

## Deploying Custom Setups

If you have created a custom environment using the methods in the [Customization Guide](customization.md), here's how to deploy it.

### Method 1: Manual Build, Push, and Deploy

This method involves building your custom Docker image locally, pushing it to a registry, and then deploying that image on RunPod.

1.  **Write your Dockerfile:** Follow the instructions in the [Customization Guide](customization.md#method-1-custom-dockerfile-recommended) to create your `Dockerfile` specifying the base image, nodes, models, and any static files.
2.  **Build the Docker image:** Navigate to the directory containing your `Dockerfile` and run:
    ```bash
    # Replace <your-image-name>:<tag> with your desired name and tag
    docker build --platform linux/amd64 -t <your-image-name>:<tag> .
    ```
    - **Crucially**, always include `--platform linux/amd64` for RunPod compatibility.
3.  **Tag the image for your registry:** Replace `<your-registry-username>` and `<your-image-name>:<tag>` accordingly.
    ```bash
    # Example for Docker Hub:
    docker tag <your-image-name>:<tag> <your-registry-username>/<your-image-name>:<tag>
    ```
4.  **Log in to your container registry:**
    ```bash
    # Example for Docker Hub:
    docker login
    ```
5.  **Push the image:**
    ```bash
    # Example for Docker Hub:
    docker push <your-registry-username>/<your-image-name>:<tag>
    ```
6.  **Deploy on RunPod:**
    - Follow the steps in [Create your template](#create-your-template-optional) above, but for the `Container Image` field, enter the full name of the image you just pushed (e.g., `<your-registry-username>/<your-image-name>:<tag>`).
    - If your registry is private, you will need to provide [Container Registry Credentials](https://docs.runpod.io/serverless/templates#container-registry-credentials).
    - Adjust the `Container Disk` size based on your custom image contents.
    - Follow the steps in [Create your endpoint](#create-your-endpoint) using the template you just created.

### Method 2: Deploying via RunPod GitHub Integration

RunPod offers a seamless way to deploy directly from your GitHub repository containing the `Dockerfile`. RunPod handles the build and deployment.

1.  **Prepare your GitHub Repository:** Ensure your repository contains the custom `Dockerfile` (as described in the [Customization Guide](customization.md#method-1-custom-dockerfile-recommended)) at the root or a specified path.
2.  **Connect GitHub to RunPod:** Authorize RunPod to access your repository via your RunPod account settings or when creating a new endpoint.
3.  **Create a New Serverless Endpoint:** In RunPod, navigate to Serverless -> `+ New Endpoint` and select the **"Start from GitHub Repo"** option.
4.  **Configure:**
    - Select the GitHub repository and branch you want to deploy (e.g., `main`).
    - Specify the **Context Path** (usually `/` if the Dockerfile is at the root).
    - Specify the **Dockerfile Path** (usually `Dockerfile`).
    - Configure your desired compute resources (GPU type, workers, etc.).
    - Configure any necessary [Environment Variables](configuration.md).
5.  **Deploy:** RunPod will clone the repository, build the image from your specified branch and Dockerfile, push it to a temporary registry, and deploy the endpoint.

Every `git push` to the configured branch will automatically trigger a new build and update your RunPod endpoint. For more details, refer to the [RunPod GitHub Integration Documentation](https://docs.runpod.io/serverless/github-integration).


============================================== File: docs/development.md ===============================================

# Development and Local Testing

This guide covers setting up your local environment for developing and testing the `worker-comfyui`.

Both tests will use the data from [`test_input.json`](../test_input.json), so make your changes in there to test different workflow inputs properly.

## Setup

### Prerequisites

1.  Python >= 3.10
2.  `pip` (Python package installer)
3.  Virtual environment tool (like `venv`)

### Steps

1.  **Clone the repository** (if you haven't already):
    ```bash
    git clone https://github.com/runpod-workers/worker-comfyui.git
    cd worker-comfyui
    ```
2.  **Create a virtual environment**:
    ```bash
    python -m venv .venv
    ```
3.  **Activate the virtual environment**:
    - **Windows (Command Prompt/PowerShell)**:
      ```bash
      .\.venv\Scripts\activate
      ```
    - **macOS / Linux (Bash/Zsh)**:
      ```bash
      source ./.venv/bin/activate
      ```
4.  **Install dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

### Setup for Windows (using WSL2)

Running Docker with GPU acceleration on Windows typically requires WSL2 (Windows Subsystem for Linux).

1.  **Install WSL2 and a Linux distribution** (like Ubuntu) following [Microsoft's official guide](https://learn.microsoft.com/en-us/windows/wsl/install). You generally don't need the GUI support for this.
2.  **Open your Linux distribution's terminal** (e.g., open Ubuntu from the Start menu or type `wsl` in Command Prompt/PowerShell).
3.  **Update packages** inside WSL:
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```
4.  **Install Docker Engine in WSL**:
    - Follow the [official Docker installation guide for your chosen Linux distribution](https://docs.docker.com/engine/install/#server) (e.g., Ubuntu).
    - **Important:** Add your user to the `docker` group to avoid using `sudo` for every Docker command: `sudo usermod -aG docker $USER`. You might need to close and reopen the terminal for this to take effect.
5.  **Install Docker Compose** (if not included with Docker Engine):
    ```bash
    sudo apt-get update
    sudo apt-get install docker-compose-plugin # Or use the standalone binary method if preferred
    ```
6.  **Install NVIDIA Container Toolkit in WSL**:
    - Follow the [NVIDIA Container Toolkit installation guide](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html), ensuring you select the correct steps for your Linux distribution running inside WSL.
    - Configure Docker to use the NVIDIA runtime as default if desired, or specify it when running containers.
7.  **Enable GPU Acceleration in WSL**:
    - Ensure you have the latest NVIDIA drivers installed on your Windows host machine.
    - Follow the [NVIDIA guide for CUDA on WSL](https://docs.nvidia.com/cuda/wsl-user-guide/index.html).

After completing these steps, you should be able to run Docker commands, including `docker-compose`, from within your WSL terminal with GPU access.

> [!NOTE]
>
> - It is generally recommended to run the Docker commands (`docker build`, `docker-compose up`) from within the WSL environment terminal for consistency with the Linux-based container environment.
> - Accessing `localhost` URLs (like the local API or ComfyUI) from your Windows browser while the service runs inside WSL usually works, but network configurations can sometimes cause issues.

## Testing the RunPod Handler

Unit tests are provided to verify the core logic of the `handler.py`.

- **Run all tests**:
  ```bash
  python -m unittest discover tests/
  ```
- **Run a specific test file**:
  ```bash
  python -m unittest tests.test_handler
  ```
- **Run a specific test case or method**:

  ```bash
  # Example: Run all tests in the TestRunpodWorkerComfy class
  python -m unittest tests.test_handler.TestRunpodWorkerComfy

  # Example: Run a single test method
  python -m unittest tests.test_handler.TestRunpodWorkerComfy.test_s3_upload
  ```

## Local API Simulation (using Docker Compose)

For enhanced local development and end-to-end testing, you can start a local environment using Docker Compose that includes the worker and a ComfyUI instance.

> [!IMPORTANT]
>
> - This currently requires an **NVIDIA GPU** and correctly configured drivers + NVIDIA Container Toolkit (see Windows setup above if applicable).
> - Ensure Docker is running.

**Steps:**

1.  **Set Environment Variable (Optional but Recommended):**
    - While the `docker-compose.yml` sets `SERVE_API_LOCALLY=true` by default, you might manage environment variables externally (e.g., via a `.env` file).
    - Ensure the `SERVE_API_LOCALLY` environment variable is set to `true` for the `worker` service if you modify the compose file or use an `.env` file.
2.  **Start the services**:
    ```bash
    # From the project root directory
    docker-compose up --build
    ```
    - The `--build` flag ensures the image is built locally using the current state of the code and `Dockerfile`.
    - This will start two containers: `comfyui` and `worker`.

### Access the Local Worker API

- With the Docker Compose stack running, the worker's simulated RunPod API is accessible at: [http://localhost:8000](http://localhost:8000)
- You can send POST requests to `http://localhost:8000/run` or `http://localhost:8000/runsync` with the same JSON payload structure expected by the RunPod endpoint.
- Opening [http://localhost:8000/docs](http://localhost:8000/docs) in your browser will show the FastAPI auto-generated documentation (Swagger UI), allowing you to interact with the API directly.

### Access Local ComfyUI

- The underlying ComfyUI instance running in the `comfyui` container is accessible directly at: [http://localhost:8188](http://localhost:8188)
- This is useful for debugging workflows or observing the ComfyUI state while testing the worker.

### Stopping the Local Environment

- Press `Ctrl+C` in the terminal where `docker-compose up` is running.
- To ensure containers are removed, you can run: `docker-compose down`


========================================= File: docs/planning/001_websocket.md =========================================

# User Story: Implement Websocket API for ComfyUI Communication

**Goal:** Replace the current HTTP polling mechanism in `handler.py` with ComfyUI's websocket API to monitor prompt execution status and retrieve generated images more efficiently and reliably.

**Current State:**

- `handler.py` queues a prompt via HTTP POST to `/prompt`.
- It then repeatedly polls the `/history/{prompt_id}` endpoint with a delay (`COMFY_POLLING_INTERVAL_MS`) until the job outputs appear in the history.
- Once outputs are detected, `process_output_images` retrieves image filenames from the history, constructs local file paths (assuming images are saved to `/comfyui/output`), checks for file existence, and then either uploads the file from disk to S3 or reads the file from disk to encode it as base64. This reliance on filesystem access is fragile.

**Desired State:**

- Use the ComfyUI websocket API (`ws://<host>/ws?clientId=<clientId>`) for real-time status updates.
- Eliminate the HTTP polling loop and associated constants.
- Retrieve final image data directly using the `/view` API endpoint instead of relying on filesystem access within the container.
- Maintain existing functionality for uploading images to S3 or returning base64 encoded images.

**Tasks:**

1.  **Add Dependency:** Add `websocket-client` to the `requirements.txt` file.
2.  **Modify `handler.py`:**
    - Import `websocket` and `uuid`.
    - Generate a unique `client_id` (using `uuid.uuid4()`) for each job request within the `handler` function.
    - Modify `queue_workflow`: Update the function signature and implementation to accept the `client_id` and include it in the `/prompt` request payload (`{"prompt": workflow, "client_id": client_id}`).
    - **Websocket Connection & Monitoring:**
      - Establish a websocket connection before queuing the prompt: `ws = websocket.WebSocket()` followed by `ws.connect(f"ws://{COMFY_HOST}/ws?clientId={client_id}")`.
      - After queuing the prompt and getting the `prompt_id`, implement the websocket message receiving loop (`while True: out = ws.recv()...`). Listen for the specific `executing` message indicating the prompt is finished (where `message['data']['node'] is None` and `message['data']['prompt_id'] == prompt_id`).
      - Ensure the websocket connection is closed (`ws.close()`) after monitoring is complete or in case of errors (using a `try...finally` block).
    - **Image Retrieval & Handling:**
      - After the websocket indicates completion, call `get_history(prompt_id)` to get the final output structure (as done in the example).
      - Create a new function `get_image_data(filename, subfolder, image_type)` that uses `urllib.request` (or `requests`) to fetch image _bytes_ from the `http://{COMFY_HOST}/view` endpoint.
      - Replace the logic previously in `process_output_images` (or integrate into the main `handler` flow after getting history):
        - Iterate through the `outputs` in the fetched history.
        - For each image identified in the `outputs` dictionary:
          - Call `get_image_data` to retrieve the raw image bytes.
          - If S3 is configured (`BUCKET_ENDPOINT_URL` env var is set):
            - Save the image bytes to a temporary file (using Python's `tempfile` module).
            - Use `rp_upload.upload_image(job_id, temp_file_path)` to upload the temporary file to S3. Determine the correct file extension if possible, default to '.png'.
            - Ensure the temporary file is deleted after upload.
            - Store the returned S3 URL.
          - If S3 is not configured:
            - Base64 encode the image bytes directly.
            - Store the resulting base64 string.
        - Aggregate all resulting image URLs and/or base64 strings into a suitable format (e.g., a list or dictionary).
    - **Cleanup:**
      - Remove the old `process_output_images` function.
      - Remove the polling-related constants (`COMFY_POLLING_INTERVAL_MS`, `COMFY_POLLING_MAX_RETRIES`) and the polling `while` loop.
    - **Error Handling:** Add robust error handling for websocket connection establishment, message receiving/parsing, image data fetching (`/view`), temporary file operations, and S3 uploads.
3.  **Testing:**
    - Update unit tests in `tests/` to mock the websocket interactions and verify the new logic.
    - Perform local end-to-end testing using `docker-compose up` to ensure the integration with a live ComfyUI instance works as expected for both S3 and base64 output modes.

**Considerations:**

- **Websocket Reliability:** Implement try/except blocks around websocket operations. Consider if simple retries are needed for connection failures.
- **Temporary Files for S3:** Using temporary files adds minor overhead but fits the current `runpod` SDK (`rp_upload.upload_image`). Ensure proper cleanup using `try...finally` or context managers.
- **Runpod Lifecycle:** Creating a new websocket connection per `handler` invocation is standard for serverless function executions and ensures isolation.


===================================== File: docs/planning/002_restructure_docs.md ======================================

# User Story: Restructure Documentation for Clarity and Maintainability

**Goal:** Refactor the main `README.md` to focus on essential user information (deployment, configuration basics, API usage) and move detailed sections (customization, local development, CI/CD, etc.) into separate, focused documents within the `docs/` directory. Improve overall documentation structure and ease of navigation.

**Current State:**

- The `README.md` file is very large and covers a wide range of topics, from basic usage to advanced customization and development setup.
- It can be difficult for users to quickly find the specific information they need (e.g., just how to run the API vs. how to build a custom image).
- The release process (`.releaserc`) currently updates version numbers only within `README.md` using a `sed` command.

**Desired State:**

- A concise `README.md` serving as a landing page and quickstart guide, containing:
  - Brief introduction/purpose.
  - Quickstart guide (linking to detailed deployment).
  - List of available pre-built images (with current version tags).
  - Essential configuration (S3 setup, linking to full config).
  - API specification (endpoints, input/output formats).
  - Basic API interaction examples (linking to details if needed).
  - How to get the ComfyUI workflow JSON.
  - Clear links to more detailed documentation in the `docs/` directory.
- New documents created within `docs/` covering specific topics:
  - `docs/deployment.md`: Detailed RunPod template/endpoint creation, GPU recommendations.
  - `docs/configuration.md`: Comprehensive list and explanation of all environment variables.
  - `docs/customization.md`: In-depth guide on using Network Volumes and building custom Docker images (models, nodes, snapshots).
  - `docs/development.md`: Instructions for local setup (Python, WSL), running tests, using `docker-compose`, accessing local API/ComfyUI.
  - `docs/ci-cd.md`: Explanation of the GitHub Actions workflows for Docker Hub deployment (secrets, variables).
  - `docs/acknowledgments.md`: (Optional) Move acknowledgments here.
- Specific version numbers (e.g., `3.6.0` in image tags) should ideally only reside in the main `README.md` to avoid complicating the release script. If version numbers must exist in other files, the `.releaserc` `prepareCmd` will need modification.

**Tasks:**

1.  **Create New Files:** Create the following new markdown files within the `docs/` directory: `deployment.md`, `configuration.md`, `customization.md`, `development.md`, `ci-cd.md`, (optionally `acknowledgments.md`).
2.  **Migrate Content:** Carefully move relevant sections from the current `README.md` into the corresponding new files in `docs/`. Ensure content flows logically within each new document.
3.  **Refactor `README.md`:** Rewrite and condense `README.md` to focus on the core user information identified in the "Desired State". Remove migrated content.
4.  **Add Links:** Insert clear links within the refactored `README.md` pointing to the detailed information in the new `docs/` files (e.g., "For detailed deployment steps, see [Deployment Guide](docs/deployment.md)."). Also, ensure inter-linking between new docs where relevant.
5.  **Review Versioning:** Scrutinize all documentation files (`README.md` and `docs/*`) to ensure specific version numbers (like image tags) are confined to `README.md` where possible.
6.  **Verify Release Script:** Confirm that the existing `prepareCmd` in `.releaserc` is still sufficient (targets the right file and pattern for version replacement). If version numbers were unavoidably moved outside `README.md`, update the `sed` command accordingly to target the additional files.
7.  **Review and Test:** Read through the restructured documentation to ensure clarity, accuracy, and completeness. Verify all internal links work correctly.

**Considerations:**

- **Discoverability:** While splitting improves focus, ensure the main `README.md` provides good entry points/links so users can find detailed information.
- **Consistency:** Maintain consistent formatting and tone across all documentation files.
- **Versioning Maintenance:** Keeping version numbers primarily in `README.md` simplifies the release automation script.


=========================================== File: docs/planning/003_5090.md ============================================

# User Story: Consolidate Multi-CUDA Version Support Using Parameterized Dockerfile

**Goal:** Eliminate the duplicate `Dockerfile.blackwell` by implementing a parameterized single `Dockerfile` that supports both CUDA 12.6.3 and CUDA 12.8.1 through build arguments controlled by `docker-bake.hcl`. Provide only base images for CUDA 12.8.1 while maintaining all model variants for CUDA 12.6.3 to optimize build matrix and maintenance overhead.

**Current State:**

- `Dockerfile.blackwell` is a near-complete duplication of `Dockerfile` with only three key differences:
  - Base image: `nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04` vs `nvidia/cuda:12.6.3-cudnn-runtime-ubuntu24.04`
  - ComfyUI version: `0.3.44` vs `0.3.43` and removal of `--cuda-version 12.6` flag
  - Additional PyTorch upgrade with CUDA 12.8 support: `uv pip install --force-reinstall torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128`
- `docker-bake.hcl` contains a separate "blackwell" group with six targets (`base-blackwell`, `sdxl-blackwell`, `sd3-blackwell`, `flux1-schnell-blackwell`, `flux1-dev-blackwell`, `flux1-dev-fp8-blackwell`), duplicating the same model variants as the default group.
- This approach violates DRY principles and creates unnecessary maintenance burden.

**Desired State:**

- Single `Dockerfile` parameterized with build arguments to support both GPU architectures.
- `docker-bake.hcl` controls the build arguments to determine CUDA version, ComfyUI version, and PyTorch upgrade requirements.
- For CUDA 12.8.1 support: Only provide `base-cuda12.8.1` image (without pre-downloaded models) to reduce build complexity and image storage requirements.
- For CUDA 12.6.3 support: Maintain all existing model variants (`base`, `sdxl`, `sd3`, `flux1-schnell`, `flux1-dev`, `flux1-dev-fp8`).
- Clear naming convention: Replace "blackwell" terminology with CUDA version indicators for clarity and future-proofing.

**Tasks:**

1. **Parameterize Dockerfile:**

   - Add build arguments at the top of `Dockerfile`:
     ```dockerfile
     ARG CUDA_VERSION=12.6.3
     ARG UBUNTU_VERSION=24.04
     ARG COMFYUI_VERSION=0.3.43
     ARG CUDA_VERSION_FLAG=--cuda-version 12.6
     ARG ENABLE_PYTORCH_UPGRADE=false
     ARG PYTORCH_INDEX_URL=""
     ```
   - Update the base image line to use variables:
     ```dockerfile
     FROM nvidia/cuda:${CUDA_VERSION}-cudnn-runtime-ubuntu${UBUNTU_VERSION} AS base
     ```
   - Parameterize the ComfyUI installation:
     ```dockerfile
     RUN /usr/bin/yes | comfy --workspace /comfyui install --version ${COMFYUI_VERSION} ${CUDA_VERSION_FLAG} --nvidia
     ```
   - Add conditional PyTorch upgrade step:
     ```dockerfile
     RUN if [ "$ENABLE_PYTORCH_UPGRADE" = "true" ]; then \
           uv pip install --force-reinstall torch torchvision torchaudio --index-url ${PYTORCH_INDEX_URL}; \
         fi
     ```

2. **Update docker-bake.hcl:**

   - Add global variables for common configuration to eliminate duplication:
     - `COMFYUI_VERSION`: Ensures all images use the same ComfyUI version
     - `BASE_IMAGE`: Full base image name instead of separate CUDA + Ubuntu versions
     - `CUDA_VERSION_FOR_COMFY`, `ENABLE_PYTORCH_UPGRADE`, `PYTORCH_INDEX_URL`: Standard defaults
   - Remove the existing "blackwell" group entirely.
   - Add a single `base-cuda12.8.1` target that only overrides what's different:
     ```hcl
     target "base-cuda12.8.1" {
       context = "."
       dockerfile = "Dockerfile"
       target = "base"
       platforms = ["linux/amd64"]
       args = {
         BASE_IMAGE = "nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04"
         COMFYUI_VERSION = "${COMFYUI_VERSION}"
         CUDA_VERSION_FOR_COMFY = ""
         ENABLE_PYTORCH_UPGRADE = "true"
         PYTORCH_INDEX_URL = "https://download.pytorch.org/whl/cu128"
         MODEL_TYPE = "base"
       }
       tags = ["${DOCKERHUB_REPO}/${DOCKERHUB_IMG}:${RELEASE_VERSION}-base-cuda12.8.1"]
     }
     ```
   - Standard targets now use global defaults and only specify unique values:
     ```hcl
     args = {
       BASE_IMAGE = "${BASE_IMAGE}"
       COMFYUI_VERSION = "${COMFYUI_VERSION}"
       CUDA_VERSION_FOR_COMFY = "${CUDA_VERSION_FOR_COMFY}"
       ENABLE_PYTORCH_UPGRADE = "${ENABLE_PYTORCH_UPGRADE}"
       PYTORCH_INDEX_URL = "${PYTORCH_INDEX_URL}"
       MODEL_TYPE = "sdxl"  # or respective model type
     }
     ```

3. **Update Build Groups:**

   - Modify the "default" group to include the new `base-cuda12.8.1` target:
     ```hcl
     group "default" {
       targets = ["base", "sdxl", "sd3", "flux1-schnell", "flux1-dev", "flux1-dev-fp8", "base-cuda12.8.1"]
     }
     ```
   - Remove the "blackwell" group entirely.

4. **Remove Duplicate Files:**

   - Delete `Dockerfile.blackwell` entirely.
   - Update any documentation or scripts that reference the blackwell dockerfile.

5. **Testing and Validation:**

   - Build and test the `base-cuda12.8.1` image to ensure CUDA 12.8.1 compatibility (RTX 5090 and other newer GPUs).
   - Verify that all existing targets continue to build correctly with the parameterized approach.
   - Confirm that the resulting images maintain the same functionality as before.
   - Test with `docker-compose` using `MODEL_TYPE=base` for rapid development iteration.

6. **Documentation Updates:**
   - Update `README.md` to replace any "blackwell" references with CUDA version indicators.
   - Document the new `base-cuda12.8.1` image variant and its intended use case for newer GPUs requiring CUDA 12.8.1.
   - Update build instructions to reflect the simplified single-Dockerfile approach.

**Considerations:**

- **Build Argument Defaults:** Set defaults in the Dockerfile that maintain current behavior for standard builds, ensuring backward compatibility.
- **Image Size Optimization:** By providing only the base image for CUDA 12.8.1, we avoid the storage overhead of multiple large model variants while still supporting user customization via Network Volumes.
- **Naming Clarity:** Using full CUDA version indicators (e.g., "cuda12.8.1") is more descriptive and future-proof than architecture codenames, clearly indicating exact compatibility requirements and allowing tracking of patch-level updates.
- **CI/CD Impact:** Verify that existing GitHub Actions workflows handle the updated `docker-bake.hcl` structure correctly.
- **Future GPU Support:** This parameterized approach provides a template for supporting additional GPU architectures without further code duplication.


=================================================== File: handler.py ===================================================

import runpod
import boto3
import json
import urllib.request
import urllib.parse
import time
import os
import requests
import base64
import io
from io import BytesIO
import websocket
import uuid
import tempfile
import socket
import traceback
import piexif
import ffmpeg
import re, yaml, uuid
import tempfile, mime, mimetypes
from fastapi import FastAPI, HTTPException, Body
from pydantic import BaseModel
from pathlib import Path
from PIL import Image, PngImagePlugin

# Time to wait between API check attempts in milliseconds
COMFY_API_AVAILABLE_INTERVAL_MS = 50
# Maximum number of API check attempts
COMFY_API_AVAILABLE_MAX_RETRIES = 500
# Websocket reconnection behaviour (can be overridden through environment variables)
# NOTE: more attempts and diagnostics improve debuggability whenever ComfyUI crashes mid-job.
#   • WEBSOCKET_RECONNECT_ATTEMPTS sets how many times we will try to reconnect.
#   • WEBSOCKET_RECONNECT_DELAY_S sets the sleep in seconds between attempts.
#
# If the respective env-vars are not supplied we fall back to sensible defaults ("5" and "3").
WEBSOCKET_RECONNECT_ATTEMPTS = int(os.environ.get("WEBSOCKET_RECONNECT_ATTEMPTS", 5))
WEBSOCKET_RECONNECT_DELAY_S = int(os.environ.get("WEBSOCKET_RECONNECT_DELAY_S", 3))

# Extra verbose websocket trace logs (set WEBSOCKET_TRACE=true to enable)
if os.environ.get("WEBSOCKET_TRACE", "false").lower() == "true":
    # This prints low-level frame information to stdout which is invaluable for diagnosing
    # protocol errors but can be noisy in production – therefore gated behind an env-var.
    websocket.enableTrace(True)

# Host where ComfyUI is running
COMFY_HOST = "127.0.0.1:8188"
# Enforce a clean state after each job is done
# see https://docs.runpod.io/docs/handler-additional-controls#refresh-worker
REFRESH_WORKER = os.environ.get("REFRESH_WORKER", "false").lower() == "true"

# ---------------------------------------------------------------------------
# Helper: quick reachability probe of ComfyUI HTTP endpoint (port 8188)
# ---------------------------------------------------------------------------


def _comfy_server_status():
    """Return a dictionary with basic reachability info for the ComfyUI HTTP server."""
    try:
        resp = requests.get(f"http://{COMFY_HOST}/", timeout=5)
        return {
            "reachable": resp.status_code == 200,
            "status_code": resp.status_code,
        }
    except Exception as exc:
        return {"reachable": False, "error": str(exc)}


def _attempt_websocket_reconnect(ws_url, max_attempts, delay_s, initial_error):
    """
    Attempts to reconnect to the WebSocket server after a disconnect.

    Args:
        ws_url (str): The WebSocket URL (including client_id).
        max_attempts (int): Maximum number of reconnection attempts.
        delay_s (int): Delay in seconds between attempts.
        initial_error (Exception): The error that triggered the reconnect attempt.

    Returns:
        websocket.WebSocket: The newly connected WebSocket object.

    Raises:
        websocket.WebSocketConnectionClosedException: If reconnection fails after all attempts.
    """
    print(
        f"worker-comfyui - Websocket connection closed unexpectedly: {initial_error}. Attempting to reconnect..."
    )
    last_reconnect_error = initial_error
    for attempt in range(max_attempts):
        # Log current server status before each reconnect attempt so that we can
        # see whether ComfyUI is still alive (HTTP port 8188 responding) even if
        # the websocket dropped. This is extremely useful to differentiate
        # between a network glitch and an outright ComfyUI crash/OOM-kill.
        srv_status = _comfy_server_status()
        if not srv_status["reachable"]:
            # If ComfyUI itself is down there is no point in retrying the websocket –
            # bail out immediately so the caller gets a clear "ComfyUI crashed" error.
            print(
                f"worker-comfyui - ComfyUI HTTP unreachable – aborting websocket reconnect: {srv_status.get('error', 'status '+str(srv_status.get('status_code')))}"
            )
            raise websocket.WebSocketConnectionClosedException(
                "ComfyUI HTTP unreachable during websocket reconnect"
            )

        # Otherwise we proceed with reconnect attempts while server is up
        print(
            f"worker-comfyui - Reconnect attempt {attempt + 1}/{max_attempts}... (ComfyUI HTTP reachable, status {srv_status.get('status_code')})"
        )
        try:
            # Need to create a new socket object for reconnect
            new_ws = websocket.WebSocket()
            new_ws.connect(ws_url, timeout=10)  # Use existing ws_url
            print(f"worker-comfyui - Websocket reconnected successfully.")
            return new_ws  # Return the new connected socket
        except (
            websocket.WebSocketException,
            ConnectionRefusedError,
            socket.timeout,
            OSError,
        ) as reconn_err:
            last_reconnect_error = reconn_err
            print(
                f"worker-comfyui - Reconnect attempt {attempt + 1} failed: {reconn_err}"
            )
            if attempt < max_attempts - 1:
                print(
                    f"worker-comfyui - Waiting {delay_s} seconds before next attempt..."
                )
                time.sleep(delay_s)
            else:
                print(f"worker-comfyui - Max reconnection attempts reached.")

    # If loop completes without returning, raise an exception
    print("worker-comfyui - Failed to reconnect websocket after connection closed.")
    raise websocket.WebSocketConnectionClosedException(
        f"Connection closed and failed to reconnect. Last error: {last_reconnect_error}"
    )


def validate_input(job_input):
    """
    Validates the input for the handler function.

    Args:
        job_input (dict): The input data to validate.

    Returns:
        tuple: A tuple containing the validated data and an error message, if any.
               The structure is (validated_data, error_message).
    """
    # Validate if job_input is provided
    if job_input is None:
        return None, "Please provide input"

    # Check if input is a string and try to parse it as JSON
    if isinstance(job_input, str):
        try:
            job_input = json.loads(job_input)
        except json.JSONDecodeError:
            return None, "Invalid JSON format in input"

    # Validate 'workflow' in input
    workflow = job_input.get("workflow")
    if workflow is None:
        return None, "Missing 'workflow' parameter"

    # Validate 'images' in input, if provided
    images = job_input.get("images")
    if images is not None:
        if not isinstance(images, list) or not all(
            "name" in image and "image" in image for image in images
        ):
            return (
                None,
                "'images' must be a list of objects with 'name' and 'image' keys",
            )

    # Return validated data and no error
    return {"workflow": workflow, "images": images}, None


def check_server(url, retries=500, delay=50):
    """
    Check if a server is reachable via HTTP GET request

    Args:
    - url (str): The URL to check
    - retries (int, optional): The number of times to attempt connecting to the server. Default is 50
    - delay (int, optional): The time in milliseconds to wait between retries. Default is 500

    Returns:
    bool: True if the server is reachable within the given number of retries, otherwise False
    """

    print(f"worker-comfyui - Checking API server at {url}...")
    for i in range(retries):
        try:
            response = requests.get(url, timeout=5)

            # If the response status code is 200, the server is up and running
            if response.status_code == 200:
                print(f"worker-comfyui - API is reachable")
                return True
        except requests.Timeout:
            pass
        except requests.RequestException as e:
            pass

        # Wait for the specified delay before retrying
        time.sleep(delay / 1000)

    print(
        f"worker-comfyui - Failed to connect to server at {url} after {retries} attempts."
    )
    return False


def upload_images(images):
    """
    Upload a list of base64 encoded images to the ComfyUI server using the /upload/image endpoint.

    Args:
        images (list): A list of dictionaries, each containing the 'name' of the image and the 'image' as a base64 encoded string.

    Returns:
        dict: A dictionary indicating success or error.
    """
    if not images:
        return {"status": "success", "message": "No images to upload", "details": []}

    responses = []
    upload_errors = []

    print(f"worker-comfyui - Uploading {len(images)} image(s)...")

    for image in images:
        try:
            name = image["name"]
            image_data_uri = image["image"]  # Get the full string (might have prefix)

            # --- Strip Data URI prefix if present ---
            if "," in image_data_uri:
                # Find the comma and take everything after it
                base64_data = image_data_uri.split(",", 1)[1]
            else:
                # Assume it's already pure base64
                base64_data = image_data_uri
            # --- End strip ---

            blob = base64.b64decode(base64_data)  # Decode the cleaned data

            # Prepare the form data
            files = {
                "image": (name, BytesIO(blob), "image/png"),
                "overwrite": (None, "true"),
            }

            # POST request to upload the image
            response = requests.post(
                f"http://{COMFY_HOST}/upload/image", files=files, timeout=30
            )
            response.raise_for_status()

            responses.append(f"Successfully uploaded {name}")
            print(f"worker-comfyui - Successfully uploaded {name}")

        except base64.binascii.Error as e:
            error_msg = f"Error decoding base64 for {image.get('name', 'unknown')}: {e}"
            print(f"worker-comfyui - {error_msg}")
            upload_errors.append(error_msg)
        except requests.Timeout:
            error_msg = f"Timeout uploading {image.get('name', 'unknown')}"
            print(f"worker-comfyui - {error_msg}")
            upload_errors.append(error_msg)
        except requests.RequestException as e:
            error_msg = f"Error uploading {image.get('name', 'unknown')}: {e}"
            print(f"worker-comfyui - {error_msg}")
            upload_errors.append(error_msg)
        except Exception as e:
            error_msg = (
                f"Unexpected error uploading {image.get('name', 'unknown')}: {e}"
            )
            print(f"worker-comfyui - {error_msg}")
            upload_errors.append(error_msg)

    if upload_errors:
        print(f"worker-comfyui - image(s) upload finished with errors")
        return {
            "status": "error",
            "message": "Some images failed to upload",
            "details": upload_errors,
        }

    print(f"worker-comfyui - image(s) upload complete")
    return {
        "status": "success",
        "message": "All images uploaded successfully",
        "details": responses,
    }


def get_available_models():
    """
    Get list of available models from ComfyUI

    Returns:
        dict: Dictionary containing available models by type
    """
    try:
        response = requests.get(f"http://{COMFY_HOST}/object_info", timeout=10)
        response.raise_for_status()
        object_info = response.json()

        # Extract available checkpoints from CheckpointLoaderSimple
        available_models = {}
        if "CheckpointLoaderSimple" in object_info:
            checkpoint_info = object_info["CheckpointLoaderSimple"]
            if "input" in checkpoint_info and "required" in checkpoint_info["input"]:
                ckpt_options = checkpoint_info["input"]["required"].get("ckpt_name")
                if ckpt_options and len(ckpt_options) > 0:
                    available_models["checkpoints"] = (
                        ckpt_options[0] if isinstance(ckpt_options[0], list) else []
                    )

        return available_models
    except Exception as e:
        print(f"worker-comfyui - Warning: Could not fetch available models: {e}")
        return {}


def queue_workflow(workflow, client_id):
    """
    Queue a workflow to be processed by ComfyUI

    Args:
        workflow (dict): A dictionary containing the workflow to be processed
        client_id (str): The client ID for the websocket connection

    Returns:
        dict: The JSON response from ComfyUI after processing the workflow

    Raises:
        ValueError: If the workflow validation fails with detailed error information
    """
    # Include client_id in the prompt payload
    payload = {"prompt": workflow, "client_id": client_id}
    data = json.dumps(payload).encode("utf-8")

    # Use requests for consistency and timeout
    headers = {"Content-Type": "application/json"}
    response = requests.post(
        f"http://{COMFY_HOST}/prompt", data=data, headers=headers, timeout=30
    )

    # Handle validation errors with detailed information
    if response.status_code == 400:
        print(f"worker-comfyui - ComfyUI returned 400. Response body: {response.text}")
        try:
            error_data = response.json()
            print(f"worker-comfyui - Parsed error data: {error_data}")

            # Try to extract meaningful error information
            error_message = "Workflow validation failed"
            error_details = []

            # ComfyUI seems to return different error formats, let's handle them all
            if "error" in error_data:
                error_info = error_data["error"]
                if isinstance(error_info, dict):
                    error_message = error_info.get("message", error_message)
                    if error_info.get("type") == "prompt_outputs_failed_validation":
                        error_message = "Workflow validation failed"
                else:
                    error_message = str(error_info)

            # Check for node validation errors in the response
            if "node_errors" in error_data:
                for node_id, node_error in error_data["node_errors"].items():
                    if isinstance(node_error, dict):
                        for error_type, error_msg in node_error.items():
                            error_details.append(
                                f"Node {node_id} ({error_type}): {error_msg}"
                            )
                    else:
                        error_details.append(f"Node {node_id}: {node_error}")

            # Check if the error data itself contains validation info
            if error_data.get("type") == "prompt_outputs_failed_validation":
                error_message = error_data.get("message", "Workflow validation failed")
                # For this type of error, we need to parse the validation details from logs
                # Since ComfyUI doesn't seem to include detailed validation errors in the response
                # Let's provide a more helpful generic message
                available_models = get_available_models()
                if available_models.get("checkpoints"):
                    error_message += f"\n\nThis usually means a required model or parameter is not available."
                    error_message += f"\nAvailable checkpoint models: {', '.join(available_models['checkpoints'])}"
                else:
                    error_message += "\n\nThis usually means a required model or parameter is not available."
                    error_message += "\nNo checkpoint models appear to be available. Please check your model installation."

                raise ValueError(error_message)

            # If we have specific validation errors, format them nicely
            if error_details:
                detailed_message = f"{error_message}:\n" + "\n".join(
                    f"• {detail}" for detail in error_details
                )

                # Try to provide helpful suggestions for common errors
                if any(
                    "not in list" in detail and "ckpt_name" in detail
                    for detail in error_details
                ):
                    available_models = get_available_models()
                    if available_models.get("checkpoints"):
                        detailed_message += f"\n\nAvailable checkpoint models: {', '.join(available_models['checkpoints'])}"
                    else:
                        detailed_message += "\n\nNo checkpoint models appear to be available. Please check your model installation."

                raise ValueError(detailed_message)
            else:
                # Fallback to the raw response if we can't parse specific errors
                raise ValueError(f"{error_message}. Raw response: {response.text}")

        except (json.JSONDecodeError, KeyError) as e:
            # If we can't parse the error response, fall back to the raw text
            raise ValueError(
                f"ComfyUI validation failed (could not parse error response): {response.text}"
            )

    # For other HTTP errors, raise them normally
    response.raise_for_status()
    return response.json()


def get_history(prompt_id):
    """
    Retrieve the history of a given prompt using its ID

    Args:
        prompt_id (str): The ID of the prompt whose history is to be retrieved

    Returns:
        dict: The history of the prompt, containing all the processing steps and results
    """
    # Use requests for consistency and timeout
    response = requests.get(f"http://{COMFY_HOST}/history/{prompt_id}", timeout=30)
    response.raise_for_status()
    return response.json()


def get_image_data(filename, subfolder, image_type):
    """
    Fetch image bytes from the ComfyUI /view endpoint.

    Args:
        filename (str): The filename of the image.
        subfolder (str): The subfolder where the image is stored.
        image_type (str): The type of the image (e.g., 'output').

    Returns:
        bytes: The raw image data, or None if an error occurs.
    """
    print(
        f"worker-comfyui - Fetching image data: type={image_type}, subfolder={subfolder}, filename={filename}"
    )
    data = {"filename": filename, "subfolder": subfolder, "type": image_type}
    url_values = urllib.parse.urlencode(data)
    try:
        # Use requests for consistency and timeout
        response = requests.get(f"http://{COMFY_HOST}/view?{url_values}", timeout=60)
        response.raise_for_status()
        print(f"worker-comfyui - Successfully fetched image data for {filename}")
        return response.content
    except requests.Timeout:
        print(f"worker-comfyui - Timeout fetching image data for {filename}")
        return None
    except requests.RequestException as e:
        print(f"worker-comfyui - Error fetching image data for {filename}: {e}")
        return None
    except Exception as e:
        print(
            f"worker-comfyui - Unexpected error fetching image data for {filename}: {e}"
        )
        return None

def download_lora_from_s3(user_id, model_id):
    try:
        s3 = boto3.client('s3', aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'), aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'))
        key = f"{user_id}/{model_id}/loras/{user_id}_{model_id}.safetensors"
        s3.download_file("aiofm", key, "/workspace/ComfyUI/models/loras/{user_id}_{model_id}.safetensors")
    except Exception as e:
        raise RuntimeError(f"Preparing Training Data failed")
    
def b64_to_bytes(s: str) -> bytes:
    if s.startswith("data:"):
        s = s.split(",", 1)[1]
    s = "".join(s.split())
    try:
        return base64.b64decode(s, validate=True)
    except Exception:
        return base64.urlsafe_b64decode(s + "===")

def bytes_to_b64(b: bytes) -> str:
    return base64.b64encode(b).decode("utf-8")

def add_metadata_image(base64_image):
    raw = b64_to_bytes(base64_image)
    img = Image.open(io.BytesIO(raw))
    fmt = (img.format or "").upper()

    # PNG → write PNG tEXt chunks (keeps PNG, no conversion)
    if fmt == "PNG":
        png_info = PngImagePlugin.PngInfo()
        png_info.add_text("Author", "EMMA")

        buf = io.BytesIO()
        img.save(buf, format="PNG", pnginfo=png_info)
        buf.seek(0)
        return {"file_base64": bytes_to_b64(buf.read()), "format": "PNG", "metadata_type": "tEXt"}

    # JPEG/JPG/JFIF → write EXIF
    if fmt in {"JPEG", "JPG", "JFIF"}:
        # make sure EXIF dict exists
        exif_dict = {"0th": {}, "Exif": {}, "GPS": {}, "1st": {}, "thumbnail": None}
        exif_dict["0th"][piexif.ImageIFD.Artist] = "EMMA"

        # ensure compatible mode for JPEG
        if img.mode not in ("RGB", "L"):
            img = img.convert("RGB")

        buf = io.BytesIO()
        img.save(buf, format="JPEG", exif=exif_bytes, quality=95)
        buf.seek(0)
        return {"file_base64": bytes_to_b64(buf.read()), "format": "JPEG", "metadata_type": "EXIF"}

    # Other formats → return as-is (or convert to JPEG with EXIF if you want)
    out = io.BytesIO()
    img.save(out, format=fmt or "PNG")
    out.seek(0)
    return bytes_to_b64(out.read())

def upload_to_s3(user_id, model_id, base64_image, filename, gen_type):
    s3 = boto3.client('s3', aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'), aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'))
    bucket_name = os.getenv('S3_BUCKET_NAME')
    
    s3.upload_file(base64_image, bucket_name, f"{user_id}/{model_id}/images/{gen_type}/{filename}.png")
    image_s3_url = f"s3://{bucket_name}/{user_id}/{model_id}/images/{gen_type}/{filename}.png"
    return image_s3_url

def handler(job):
    """
    Handles a job using ComfyUI via websockets for status and image retrieval.

    Args:
        job (dict): A dictionary containing job details and input parameters.

    Returns:
        dict: A dictionary containing either an error message or a success status with generated images.
    """
    job_input = job["input"]
    gen_type = job["gen_type"]
    user_id = job["user_id"]
    model_id = job["model_id"]

    if gen_type not in ["sfw", "nsfw"]:
        return {"error": f"Invalid gen_type '{gen_type}'. Must be 'sfw' or 'nsfw'."}

    # Make sure that the input is valid
    validated_data, error_message = validate_input(job_input)
    if error_message:
        return {"error": error_message}

    # Extract validated data
    workflow = validated_data["workflow"]
    input_images = validated_data.get("images")

    # Make sure that the ComfyUI HTTP API is available before proceeding
    if not check_server(
        f"http://{COMFY_HOST}/",
        COMFY_API_AVAILABLE_MAX_RETRIES,
        COMFY_API_AVAILABLE_INTERVAL_MS,
    ):
        return {
            "error": f"ComfyUI server ({COMFY_HOST}) not reachable after multiple retries."
        }

    # Upload input images if they exist
    if input_images:
        upload_result = upload_images(input_images)
        if upload_result["status"] == "error":
            # Return upload errors
            return {
                "error": "Failed to upload one or more input images",
                "details": upload_result["details"],
            }

    ws = None
    client_id = str(uuid.uuid4())
    prompt_id = None
    output_data = []
    errors = []

    try:
        # Establish WebSocket connection
        ws_url = f"ws://{COMFY_HOST}/ws?clientId={client_id}"
        print(f"worker-comfyui - Connecting to websocket: {ws_url}")
        ws = websocket.WebSocket()
        ws.connect(ws_url, timeout=10)
        print(f"worker-comfyui - Websocket connected")
        download_lora_from_s3(user_id, model_id)
        # Queue the workflow
        try:
            queued_workflow = queue_workflow(workflow, client_id)
            prompt_id = queued_workflow.get("prompt_id")
            if not prompt_id:
                raise ValueError(
                    f"Missing 'prompt_id' in queue response: {queued_workflow}"
                )
            print(f"worker-comfyui - Queued workflow with ID: {prompt_id}")
        except requests.RequestException as e:
            print(f"worker-comfyui - Error queuing workflow: {e}")
            raise ValueError(f"Error queuing workflow: {e}")
        except Exception as e:
            print(f"worker-comfyui - Unexpected error queuing workflow: {e}")
            # For ValueError exceptions from queue_workflow, pass through the original message
            if isinstance(e, ValueError):
                raise e
            else:
                raise ValueError(f"Unexpected error queuing workflow: {e}")

        # Wait for execution completion via WebSocket
        print(f"worker-comfyui - Waiting for workflow execution ({prompt_id})...")
        execution_done = False
        while True:
            try:
                out = ws.recv()
                if isinstance(out, str):
                    message = json.loads(out)
                    if message.get("type") == "status":
                        status_data = message.get("data", {}).get("status", {})
                        print(
                            f"worker-comfyui - Status update: {status_data.get('exec_info', {}).get('queue_remaining', 'N/A')} items remaining in queue"
                        )
                    elif message.get("type") == "executing":
                        data = message.get("data", {})
                        if (
                            data.get("node") is None
                            and data.get("prompt_id") == prompt_id
                        ):
                            print(
                                f"worker-comfyui - Execution finished for prompt {prompt_id}"
                            )
                            execution_done = True
                            break
                    elif message.get("type") == "execution_error":
                        data = message.get("data", {})
                        if data.get("prompt_id") == prompt_id:
                            error_details = f"Node Type: {data.get('node_type')}, Node ID: {data.get('node_id')}, Message: {data.get('exception_message')}"
                            print(
                                f"worker-comfyui - Execution error received: {error_details}"
                            )
                            errors.append(f"Workflow execution error: {error_details}")
                            break
                else:
                    continue
            except websocket.WebSocketTimeoutException:
                print(f"worker-comfyui - Websocket receive timed out. Still waiting...")
                continue
            except websocket.WebSocketConnectionClosedException as closed_err:
                try:
                    # Attempt to reconnect
                    ws = _attempt_websocket_reconnect(
                        ws_url,
                        WEBSOCKET_RECONNECT_ATTEMPTS,
                        WEBSOCKET_RECONNECT_DELAY_S,
                        closed_err,
                    )

                    print(
                        "worker-comfyui - Resuming message listening after successful reconnect."
                    )
                    continue
                except (
                    websocket.WebSocketConnectionClosedException
                ) as reconn_failed_err:
                    # If _attempt_websocket_reconnect fails, it raises this exception
                    # Let this exception propagate to the outer handler's except block
                    raise reconn_failed_err

            except json.JSONDecodeError:
                print(f"worker-comfyui - Received invalid JSON message via websocket.")

        if not execution_done and not errors:
            raise ValueError(
                "Workflow monitoring loop exited without confirmation of completion or error."
            )

        # Fetch history even if there were execution errors, some outputs might exist
        print(f"worker-comfyui - Fetching history for prompt {prompt_id}...")
        history = get_history(prompt_id)

        if prompt_id not in history:
            error_msg = f"Prompt ID {prompt_id} not found in history after execution."
            print(f"worker-comfyui - {error_msg}")
            if not errors:
                return {"error": error_msg}
            else:
                errors.append(error_msg)
                return {
                    "error": "Job processing failed, prompt ID not found in history.",
                    "details": errors,
                }

        prompt_history = history.get(prompt_id, {})
        outputs = prompt_history.get("outputs", {})

        if not outputs:
            warning_msg = f"No outputs found in history for prompt {prompt_id}."
            print(f"worker-comfyui - {warning_msg}")
            if not errors:
                errors.append(warning_msg)

        print(f"worker-comfyui - Processing {len(outputs)} output nodes...")
        for node_id, node_output in outputs.items():
            if "images" in node_output:
                print(
                    f"worker-comfyui - Node {node_id} contains {len(node_output['images'])} image(s)"
                )
                for image_info in node_output["images"]:
                    filename = image_info.get("filename")
                    subfolder = image_info.get("subfolder", "")
                    img_type = image_info.get("type")

                    # skip temp images
                    if img_type == "temp":
                        print(
                            f"worker-comfyui - Skipping image {filename} because type is 'temp'"
                        )
                        continue

                    if not filename:
                        warn_msg = f"Skipping image in node {node_id} due to missing filename: {image_info}"
                        print(f"worker-comfyui - {warn_msg}")
                        errors.append(warn_msg)
                        continue

                    image_bytes = get_image_data(filename, subfolder, img_type)

                    if image_bytes:
                        file_extension = os.path.splitext(filename)[1] or ".png"
                        # Return as base64 string
                        try:
                            base64_image = base64.b64encode(image_bytes).decode(
                                "utf-8"
                            )
                            base64_image = add_metadata_image(base64_image)
                            s3_url = upload_to_s3(user_id, model_id, base64_image, filename, gen_type)
                            # Append dictionary with filename and base64 data
                            output_data.append(
                                {
                                    "filename": filename,
                                    "type": "base64",
                                    "data": s3_url,
                                }
                            )
                            print(f"worker-comfyui - Encoded {filename} as base64")
                        except Exception as e:
                            error_msg = f"Error encoding {filename} to base64: {e}"
                            print(f"worker-comfyui - {error_msg}")
                            errors.append(error_msg)
                    else:
                        error_msg = f"Failed to fetch image data for {filename} from /view endpoint."
                        errors.append(error_msg)

            # Check for other output types
            other_keys = [k for k in node_output.keys() if k != "images"]
            if other_keys:
                warn_msg = (
                    f"Node {node_id} produced unhandled output keys: {other_keys}."
                )
                print(f"worker-comfyui - WARNING: {warn_msg}")
                print(
                    f"worker-comfyui - --> If this output is useful, please consider opening an issue on GitHub to discuss adding support."
                )

    except websocket.WebSocketException as e:
        print(f"worker-comfyui - WebSocket Error: {e}")
        print(traceback.format_exc())
        return {"error": f"WebSocket communication error: {e}"}
    except requests.RequestException as e:
        print(f"worker-comfyui - HTTP Request Error: {e}")
        print(traceback.format_exc())
        return {"error": f"HTTP communication error with ComfyUI: {e}"}
    except ValueError as e:
        print(f"worker-comfyui - Value Error: {e}")
        print(traceback.format_exc())
        return {"error": str(e)}
    except Exception as e:
        print(f"worker-comfyui - Unexpected Handler Error: {e}")
        print(traceback.format_exc())
        return {"error": f"An unexpected error occurred: {e}"}
    finally:
        if ws and ws.connected:
            print(f"worker-comfyui - Closing websocket connection.")
            ws.close()

    final_result = {}

    if output_data:
        final_result["images"] = output_data

    if errors:
        final_result["errors"] = errors
        print(f"worker-comfyui - Job completed with errors/warnings: {errors}")

    if not output_data and errors:
        print(f"worker-comfyui - Job failed with no output images.")
        return {
            "error": "Job processing failed",
            "details": errors,
        }
    elif not output_data and not errors:
        print(
            f"worker-comfyui - Job completed successfully, but the workflow produced no images."
        )
        final_result["status"] = "success_no_images"
        final_result["images"] = []

    print(f"worker-comfyui - Job completed. Returning {len(output_data)} image(s).")
    return final_result


if __name__ == "__main__":
    print("worker-comfyui - Starting handler...")
    runpod.serverless.start({"handler": handler})


================================================ File: requirements.txt ================================================

# fix some problems with the queue
runpod~=1.7.12
websocket-client
requests


======================================= File: scripts/comfy-manager-set-mode.sh ========================================

#!/usr/bin/env bash
# comfy-manager-set-mode: Set ComfyUI-Manager network_mode in its config.ini.
# Usage: comfy-manager-set-mode <public|private|offline>
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: comfy-manager-set-mode <public|private|offline>" >&2
  exit 64
fi
MODE="$1"
if [[ "$MODE" != "public" && "$MODE" != "private" && "$MODE" != "offline" ]]; then
  echo "Invalid mode: $MODE. Must be public, private, or offline." >&2
  exit 64
fi

CFG_FILE="${COMFYUI_MANAGER_CONFIG:-/comfyui/user/default/ComfyUI-Manager/config.ini}"
mkdir -p "$(dirname "$CFG_FILE")"
if [[ -f "$CFG_FILE" ]]; then
  if grep -q "^network_mode" "$CFG_FILE"; then
    sed -i "s/^network_mode *=.*/network_mode = $MODE/" "$CFG_FILE"
  else
    # Ensure [default] section exists
    if ! grep -q "^\[default\]" "$CFG_FILE"; then
      printf "[default]\n" >> "$CFG_FILE"
    fi
    printf "network_mode = %s\n" "$MODE" >> "$CFG_FILE"
  fi
else
  printf "[default]\nnetwork_mode = %s\n" "$MODE" > "$CFG_FILE"
fi

echo "worker-comfyui - ComfyUI-Manager network_mode set to '$MODE' in $CFG_FILE"


========================================= File: scripts/comfy-node-install.sh ==========================================

#!/usr/bin/env bash
# comfy-node-install: install custom ComfyUI nodes and fail with non-zero
# exit code if any of them cannot be installed. On failure it prints the
# list of nodes that could not be installed and hints the user to consult
# https://registry.comfy.org/ for correct names.
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: comfy-node-install <node1> [<node2> …]" >&2
  exit 64  # EX_USAGE
fi

log=$(mktemp)

# run installation – some modes return non-zero even on success, so we
# ignore the exit status and rely on log parsing instead.
set +e
comfy node install --mode=remote "$@" 2>&1 | tee "$log"
cli_status=$?
set -e

# extract node names that failed to install (one per line, uniq-sorted)
failed_nodes=$(grep -oP "(?<=An error occurred while installing ')[^']+" "$log" | sort -u || true)

# Fallback: capture names from "Node '<name>@' not found" lines if previous grep found nothing
if [[ -z "$failed_nodes" ]]; then
  failed_nodes=$(grep -oP "(?<=Node ')[^@']+" "$log" | sort -u || true)
fi

if [[ -n "$failed_nodes" ]]; then
  echo "Comfy node installation failed for the following nodes:" >&2
  echo "$failed_nodes" | while read -r n; do echo "  • $n" >&2 ; done
  echo >&2
  echo "Please verify the node names at https://registry.comfy.org/ and try again." >&2
  exit 1
fi

# If we reach here no failed nodes were detected. Warn if CLI exit status
# was non-zero but treat it as success.
if [[ $cli_status -ne 0 ]]; then
  echo "Warning: comfy node install exited with status $cli_status but no errors were detected in the log — assuming success." >&2
fi

exit 0


================================================ File: src/__init__.py =================================================




=========================================== File: src/extra_model_paths.yaml ===========================================

runpod_worker_comfy:
  base_path: /runpod-volume
  checkpoints: models/checkpoints/
  clip: models/clip/
  clip_vision: models/clip_vision/
  configs: models/configs/
  controlnet: models/controlnet/
  embeddings: models/embeddings/
  loras: models/loras/
  upscale_models: models/upscale_models/
  vae: models/vae/
  unet: models/unet/


============================================ File: src/restore_snapshot.sh =============================================

#!/usr/bin/env bash

set -e

SNAPSHOT_FILE=$(ls /*snapshot*.json 2>/dev/null | head -n 1)

if [ -z "$SNAPSHOT_FILE" ]; then
    echo "worker-comfyui: No snapshot file found. Exiting..."
    exit 0
fi

echo "worker-comfyui: restoring snapshot: $SNAPSHOT_FILE"

comfy --workspace /comfyui node restore-snapshot "$SNAPSHOT_FILE" --pip-non-url

echo "worker-comfyui: restored snapshot file: $SNAPSHOT_FILE"


================================================== File: src/start.sh ==================================================

#!/usr/bin/env bash

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

# Ensure ComfyUI-Manager runs in offline network mode inside the container
comfy-manager-set-mode offline || echo "worker-comfyui - Could not set ComfyUI-Manager network_mode" >&2

echo "worker-comfyui: Starting ComfyUI"

# Allow operators to tweak verbosity; default is DEBUG.
: "${COMFY_LOG_LEVEL:=DEBUG}"

# Serve the API and don't shutdown the container
if [ "$SERVE_API_LOCALLY" == "true" ]; then
    python -u /comfyui/main.py --disable-auto-launch --disable-metadata --listen --verbose "${COMFY_LOG_LEVEL}" --log-stdout &

    echo "worker-comfyui: Starting RunPod Handler"
    python -u /handler.py --rp_serve_api --rp_api_host=0.0.0.0
else
    python -u /comfyui/main.py --disable-auto-launch --disable-metadata --verbose "${COMFY_LOG_LEVEL}" --log-stdout &

    echo "worker-comfyui: Starting RunPod Handler"
    python -u /handler.py
fi


================================================ File: test_input.json =================================================

{
  "input": {
    "images": [
      {
        "name": "test.png",
        "image": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAAMklEQVR4nGI5ZdXAQEvARFPTRy0YtWDUglELRi0YtWDUglELRi0YtWDUAioCQAAAAP//E24Bx3jUKuYAAAAASUVORK5CYII="
      }
    ],
    "workflow": {
      "6": {
        "inputs": {
          "text": "anime cat with massive fluffy fennec ears and a big fluffy tail blonde messy long hair blue eyes wearing a construction outfit placing a fancy black forest cake with candles on top of a dinner table of an old dark Victorian mansion lit by candlelight with a bright window to the foggy forest and very expensive stuff everywhere there are paintings on the walls",
          "clip": ["30", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Positive Prompt)"
        }
      },
      "8": {
        "inputs": {
          "samples": ["31", 0],
          "vae": ["30", 2]
        },
        "class_type": "VAEDecode",
        "_meta": {
          "title": "VAE Decode"
        }
      },
      "9": {
        "inputs": {
          "filename_prefix": "ComfyUI",
          "images": ["8", 0]
        },
        "class_type": "SaveImage",
        "_meta": {
          "title": "Save Image"
        }
      },
      "27": {
        "inputs": {
          "width": 512,
          "height": 512,
          "batch_size": 1
        },
        "class_type": "EmptySD3LatentImage",
        "_meta": {
          "title": "EmptySD3LatentImage"
        }
      },
      "30": {
        "inputs": {
          "ckpt_name": "flux1-dev-fp8.safetensors"
        },
        "class_type": "CheckpointLoaderSimple",
        "_meta": {
          "title": "Load Checkpoint"
        }
      },
      "31": {
        "inputs": {
          "seed": 243057879077961,
          "steps": 10,
          "cfg": 1,
          "sampler_name": "euler",
          "scheduler": "simple",
          "denoise": 1,
          "model": ["30", 0],
          "positive": ["35", 0],
          "negative": ["33", 0],
          "latent_image": ["27", 0]
        },
        "class_type": "KSampler",
        "_meta": {
          "title": "KSampler"
        }
      },
      "33": {
        "inputs": {
          "text": "",
          "clip": ["30", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Negative Prompt)"
        }
      },
      "35": {
        "inputs": {
          "guidance": 3.5,
          "conditioning": ["6", 0]
        },
        "class_type": "FluxGuidance",
        "_meta": {
          "title": "FluxGuidance"
        }
      },
      "38": {
        "inputs": {
          "images": ["8", 0]
        },
        "class_type": "PreviewImage",
        "_meta": {
          "title": "Preview Image"
        }
      },
      "40": {
        "inputs": {
          "filename_prefix": "ComfyUI",
          "images": ["8", 0]
        },
        "class_type": "SaveImage",
        "_meta": {
          "title": "Save Image"
        }
      }
    }
  }
}


====================================== File: test_resources/example_snapshot.json ======================================

{
  "comfyui": "4ac401af2b3962f7a669a6757a804f7773833c47",
  "git_custom_nodes": {
    "https://github.com/ltdrdata/ComfyUI-Manager": {
      "hash": "b6a8e6ba8147080a320b1b91c93a0b1cbdb93136",
      "disabled": false
    },
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack": {
      "hash": "24de5a846bb9b1c1830af0218f76266c375cc904",
      "disabled": false
    },
    "https://github.com/ltdrdata/ComfyUI-Inspire-Pack": {
      "hash": "3bcc1d43a033b3d4b3066c34c9fba2a952b54ad0",
      "disabled": false
    }
  },
  "file_custom_nodes": [
    {
      "filename": "websocket_image_save.py",
      "disabled": false
    }
  ],
  "pips": {
    "aiohappyeyeballs==2.4.3": "",
    "aiohttp==3.11.2": "",
    "aiosignal==1.3.1": "",
    "anyio==4.1.0": "",
    "argon2-cffi==23.1.0": "",
    "argon2-cffi-bindings==21.2.0": "",
    "arrow==1.3.0": "",
    "asttokens==2.4.1": "",
    "async-lru==2.0.4": "",
    "async-timeout==5.0.1": "",
    "attrs==23.1.0": "",
    "Babel==2.13.1": "",
    "beautifulsoup4==4.12.2": "",
    "bleach==6.1.0": "",
    "blinker==1.4": "",
    "cachetools==5.5.0": "",
    "certifi==2023.11.17": "",
    "cffi==1.16.0": "",
    "charset-normalizer==3.3.2": "",
    "click==8.1.7": "",
    "comfy-cli==1.3.1": "",
    "comm==0.2.0": "",
    "contourpy==1.3.1": "",
    "cryptography==3.4.8": "",
    "cycler==0.12.1": "",
    "dbus-python==1.2.18": "",
    "debugpy==1.8.0": "",
    "decorator==5.1.1": "",
    "defusedxml==0.7.1": "",
    "Deprecated==1.2.15": "",
    "dill==0.3.9": "",
    "distro==1.7.0": "",
    "einops==0.8.0": "",
    "entrypoints==0.4": "",
    "exceptiongroup==1.2.0": "",
    "executing==2.0.1": "",
    "fastjsonschema==2.19.0": "",
    "filelock==3.13.1": "",
    "fonttools==4.55.0": "",
    "fqdn==1.5.1": "",
    "frozenlist==1.5.0": "",
    "fsspec==2023.10.0": "",
    "gitdb==4.0.11": "",
    "GitPython==3.1.43": "",
    "h11==0.14.0": "",
    "httpcore==1.0.7": "",
    "httplib2==0.20.2": "",
    "httpx==0.27.2": "",
    "huggingface-hub==0.26.2": "",
    "idna==3.6": "",
    "imageio==2.36.0": "",
    "importlib-metadata==4.6.4": "",
    "ipykernel==6.26.0": "",
    "ipython==8.18.1": "",
    "ipython-genutils==0.2.0": "",
    "ipywidgets==8.1.1": "",
    "isoduration==20.11.0": "",
    "jedi==0.19.1": "",
    "jeepney==0.7.1": "",
    "Jinja2==3.1.2": "",
    "json5==0.9.14": "",
    "jsonpointer==2.4": "",
    "jsonschema==4.20.0": "",
    "jsonschema-specifications==2023.11.1": "",
    "jupyter-archive==3.4.0": "",
    "jupyter-contrib-core==0.4.2": "",
    "jupyter-contrib-nbextensions==0.7.0": "",
    "jupyter-events==0.9.0": "",
    "jupyter-highlight-selected-word==0.2.0": "",
    "jupyter-lsp==2.2.1": "",
    "jupyter-nbextensions-configurator==0.6.3": "",
    "jupyter_client==7.4.9": "",
    "jupyter_core==5.5.0": "",
    "jupyter_server==2.10.1": "",
    "jupyter_server_terminals==0.4.4": "",
    "jupyterlab==4.0.9": "",
    "jupyterlab-widgets==3.0.9": "",
    "jupyterlab_pygments==0.3.0": "",
    "jupyterlab_server==2.25.2": "",
    "keyring==23.5.0": "",
    "kiwisolver==1.4.7": "",
    "kornia==0.7.4": "",
    "kornia_rs==0.1.7": "",
    "launchpadlib==1.10.16": "",
    "lazr.restfulclient==0.14.4": "",
    "lazr.uri==1.0.6": "",
    "lazy_loader==0.4": "",
    "lxml==4.9.3": "",
    "markdown-it-py==3.0.0": "",
    "MarkupSafe==2.1.3": "",
    "matplotlib==3.9.2": "",
    "matplotlib-inline==0.1.6": "",
    "matrix-client==0.4.0": "",
    "mdurl==0.1.2": "",
    "mistune==3.0.2": "",
    "mixpanel==4.10.1": "",
    "more-itertools==8.10.0": "",
    "mpmath==1.3.0": "",
    "multidict==6.1.0": "",
    "nbclassic==1.0.0": "",
    "nbclient==0.9.0": "",
    "nbconvert==7.11.0": "",
    "nbformat==5.9.2": "",
    "nest-asyncio==1.5.8": "",
    "networkx==3.2.1": "",
    "notebook==6.5.5": "",
    "notebook_shim==0.2.3": "",
    "numpy==1.26.2": "",
    "nvidia-cublas-cu12==12.1.3.1": "",
    "nvidia-cuda-cupti-cu12==12.1.105": "",
    "nvidia-cuda-nvrtc-cu12==12.1.105": "",
    "nvidia-cuda-runtime-cu12==12.1.105": "",
    "nvidia-cudnn-cu12==8.9.2.26": "",
    "nvidia-cufft-cu12==11.0.2.54": "",
    "nvidia-curand-cu12==10.3.2.106": "",
    "nvidia-cusolver-cu12==11.4.5.107": "",
    "nvidia-cusparse-cu12==12.1.0.106": "",
    "nvidia-nccl-cu12==2.18.1": "",
    "nvidia-nvjitlink-cu12==12.3.101": "",
    "nvidia-nvtx-cu12==12.1.105": "",
    "oauthlib==3.2.0": "",
    "opencv-python==4.10.0.84": "",
    "opencv-python-headless==4.10.0.84": "",
    "overrides==7.4.0": "",
    "packaging==23.2": "",
    "pandas==2.2.3": "",
    "pandocfilters==1.5.0": "",
    "parso==0.8.3": "",
    "pathspec==0.12.1": "",
    "pexpect==4.9.0": "",
    "piexif==1.1.3": "",
    "Pillow==10.1.0": "",
    "platformdirs==4.0.0": "",
    "prometheus-client==0.19.0": "",
    "prompt-toolkit==3.0.36": "",
    "propcache==0.2.0": "",
    "psutil==5.9.6": "",
    "ptyprocess==0.7.0": "",
    "pure-eval==0.2.2": "",
    "py-cpuinfo==9.0.0": "",
    "pycparser==2.21": "",
    "PyGithub==2.5.0": "",
    "Pygments==2.17.2": "",
    "PyGObject==3.42.1": "",
    "PyJWT==2.9.0": "",
    "PyNaCl==1.5.0": "",
    "pyparsing==2.4.7": "",
    "python-apt==2.4.0+ubuntu2": "",
    "python-dateutil==2.8.2": "",
    "python-json-logger==2.0.7": "",
    "pytz==2024.2": "",
    "PyYAML==6.0.1": "",
    "pyzmq==24.0.1": "",
    "questionary==2.0.1": "",
    "referencing==0.31.0": "",
    "regex==2024.11.6": "",
    "requests==2.31.0": "",
    "rfc3339-validator==0.1.4": "",
    "rfc3986-validator==0.1.1": "",
    "rich==13.9.4": "",
    "rpds-py==0.13.1": "",
    "safetensors==0.4.5": "",
    "scikit-image==0.24.0": "",
    "scipy==1.14.1": "",
    "seaborn==0.13.2": "",
    "SecretStorage==3.3.1": "",
    "segment-anything==1.0": "",
    "semver==3.0.2": "",
    "Send2Trash==1.8.2": "",
    "sentencepiece==0.2.0": "",
    "shellingham==1.5.4": "",
    "six==1.16.0": "",
    "smmap==5.0.1": "",
    "sniffio==1.3.0": "",
    "soundfile==0.12.1": "",
    "soupsieve==2.5": "",
    "spandrel==0.4.0": "",
    "stack-data==0.6.3": "",
    "sympy==1.12": "",
    "terminado==0.18.0": "",
    "tifffile==2024.9.20": "",
    "tinycss2==1.2.1": "",
    "tokenizers==0.20.3": "",
    "tomli==2.0.1": "",
    "tomlkit==0.13.2": "",
    "torch==2.1.1": "",
    "torchaudio==2.1.1": "",
    "torchsde==0.2.6": "",
    "torchvision==0.16.1": "",
    "tornado==6.3.3": "",
    "tqdm==4.67.0": "",
    "traitlets==5.13.0": "",
    "trampoline==0.1.2": "",
    "transformers==4.46.2": "",
    "triton==2.1.0": "",
    "typer==0.13.0": "",
    "types-python-dateutil==2.8.19.14": "",
    "typing_extensions==4.8.0": "",
    "tzdata==2024.2": "",
    "ultralytics==8.3.31": "",
    "ultralytics-thop==2.0.11": "",
    "uri-template==1.3.0": "",
    "urllib3==1.26.20": "",
    "uv==0.5.2": "",
    "wadllib==1.3.6": "",
    "wcwidth==0.2.12": "",
    "webcolors==1.13": "",
    "webencodings==0.5.1": "",
    "websocket-client==1.6.4": "",
    "widgetsnbextension==4.0.9": "",
    "wrapt==1.16.0": "",
    "yarl==1.17.1": "",
    "zipp==1.0.0": ""
  }
}


=========================== File: test_resources/workflows/flux_dev_checkpoint_example.json ============================

{
  "6": {
    "inputs": {
      "text": "cute anime girl with massive fluffy fennec ears and a big fluffy tail blonde messy long hair blue eyes wearing a maid outfit with a long black gold leaf pattern dress and a white apron mouth open placing a fancy black forest cake with candles on top of a dinner table of an old dark Victorian mansion lit by candlelight with a bright window to the foggy forest and very expensive stuff everywhere there are paintings on the walls",
      "clip": [
        "30",
        1
      ]
    },
    "class_type": "CLIPTextEncode",
    "_meta": {
      "title": "CLIP Text Encode (Positive Prompt)"
    }
  },
  "8": {
    "inputs": {
      "samples": [
        "31",
        0
      ],
      "vae": [
        "30",
        2
      ]
    },
    "class_type": "VAEDecode",
    "_meta": {
      "title": "VAE Decode"
    }
  },
  "9": {
    "inputs": {
      "filename_prefix": "ComfyUI",
      "images": [
        "8",
        0
      ]
    },
    "class_type": "SaveImage",
    "_meta": {
      "title": "Save Image"
    }
  },
  "27": {
    "inputs": {
      "width": 512,
      "height": 512,
      "batch_size": 1
    },
    "class_type": "EmptySD3LatentImage",
    "_meta": {
      "title": "EmptySD3LatentImage"
    }
  },
  "30": {
    "inputs": {
      "ckpt_name": "flux1-dev-fp8.safetensors"
    },
    "class_type": "CheckpointLoaderSimple",
    "_meta": {
      "title": "Load Checkpoint"
    }
  },
  "31": {
    "inputs": {
      "seed": 150959564782347,
      "steps": 10,
      "cfg": 1,
      "sampler_name": "euler",
      "scheduler": "simple",
      "denoise": 1,
      "model": [
        "30",
        0
      ],
      "positive": [
        "35",
        0
      ],
      "negative": [
        "33",
        0
      ],
      "latent_image": [
        "27",
        0
      ]
    },
    "class_type": "KSampler",
    "_meta": {
      "title": "KSampler"
    }
  },
  "33": {
    "inputs": {
      "text": "",
      "clip": [
        "30",
        1
      ]
    },
    "class_type": "CLIPTextEncode",
    "_meta": {
      "title": "CLIP Text Encode (Negative Prompt)"
    }
  },
  "35": {
    "inputs": {
      "guidance": 3.5,
      "conditioning": [
        "6",
        0
      ]
    },
    "class_type": "FluxGuidance",
    "_meta": {
      "title": "FluxGuidance"
    }
  }
}


================================ File: test_resources/workflows/workflow_flux1_dev.json ================================

{
  "input": {
    "workflow": {
      "5": {
        "inputs": {
          "width": 1024,
          "height": 1024,
          "batch_size": 1
        },
        "class_type": "EmptyLatentImage",
        "_meta": {
          "title": "Empty Latent Image"
        }
      },
      "6": {
        "inputs": {
          "text": "grey cat wearing a harry potter hat and programming in javascript in its ultramodern computer",
          "clip": ["11", 0]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Prompt)"
        }
      },
      "8": {
        "inputs": {
          "samples": ["13", 0],
          "vae": ["10", 0]
        },
        "class_type": "VAEDecode",
        "_meta": {
          "title": "VAE Decode"
        }
      },
      "9": {
        "inputs": {
          "filename_prefix": "ComfyUI",
          "images": ["8", 0]
        },
        "class_type": "SaveImage",
        "_meta": {
          "title": "Save Image"
        }
      },
      "10": {
        "inputs": {
          "vae_name": "ae.safetensors"
        },
        "class_type": "VAELoader",
        "_meta": {
          "title": "Load VAE"
        }
      },
      "11": {
        "inputs": {
          "clip_name1": "t5xxl_fp8_e4m3fn.safetensors",
          "clip_name2": "clip_l.safetensors",
          "type": "flux"
        },
        "class_type": "DualCLIPLoader",
        "_meta": {
          "title": "DualCLIPLoader"
        }
      },
      "12": {
        "inputs": {
          "unet_name": "flux1-dev.safetensors",
          "weight_dtype": "fp8_e4m3fn"
        },
        "class_type": "UNETLoader",
        "_meta": {
          "title": "Load Diffusion Model"
        }
      },
      "13": {
        "inputs": {
          "noise": ["25", 0],
          "guider": ["22", 0],
          "sampler": ["16", 0],
          "sigmas": ["17", 0],
          "latent_image": ["5", 0]
        },
        "class_type": "SamplerCustomAdvanced",
        "_meta": {
          "title": "SamplerCustomAdvanced"
        }
      },
      "16": {
        "inputs": {
          "sampler_name": "euler"
        },
        "class_type": "KSamplerSelect",
        "_meta": {
          "title": "KSamplerSelect"
        }
      },
      "17": {
        "inputs": {
          "scheduler": "sgm_uniform",
          "steps": 4,
          "denoise": 1,
          "model": ["12", 0]
        },
        "class_type": "BasicScheduler",
        "_meta": {
          "title": "BasicScheduler"
        }
      },
      "22": {
        "inputs": {
          "model": ["12", 0],
          "conditioning": ["6", 0]
        },
        "class_type": "BasicGuider",
        "_meta": {
          "title": "BasicGuider"
        }
      },
      "25": {
        "inputs": {
          "noise_seed": 108076821791990
        },
        "class_type": "RandomNoise",
        "_meta": {
          "title": "RandomNoise"
        }
      }
    }
  }
}


============================== File: test_resources/workflows/workflow_flux1_schnell.json ==============================

{
  "input": {
    "workflow": {
      "5": {
        "inputs": {
          "width": 1024,
          "height": 1024,
          "batch_size": 1
        },
        "class_type": "EmptyLatentImage",
        "_meta": {
          "title": "Empty Latent Image"
        }
      },
      "6": {
        "inputs": {
          "text": "grey cat wearing a harry potter hat and programming in javascript in its ultramodern computer",
          "clip": ["11", 0]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Prompt)"
        }
      },
      "8": {
        "inputs": {
          "samples": ["13", 0],
          "vae": ["10", 0]
        },
        "class_type": "VAEDecode",
        "_meta": {
          "title": "VAE Decode"
        }
      },
      "9": {
        "inputs": {
          "filename_prefix": "ComfyUI",
          "images": ["8", 0]
        },
        "class_type": "SaveImage",
        "_meta": {
          "title": "Save Image"
        }
      },
      "10": {
        "inputs": {
          "vae_name": "ae.safetensors"
        },
        "class_type": "VAELoader",
        "_meta": {
          "title": "Load VAE"
        }
      },
      "11": {
        "inputs": {
          "clip_name1": "t5xxl_fp8_e4m3fn.safetensors",
          "clip_name2": "clip_l.safetensors",
          "type": "flux"
        },
        "class_type": "DualCLIPLoader",
        "_meta": {
          "title": "DualCLIPLoader"
        }
      },
      "12": {
        "inputs": {
          "unet_name": "flux1-schnell.safetensors",
          "weight_dtype": "fp8_e4m3fn"
        },
        "class_type": "UNETLoader",
        "_meta": {
          "title": "Load Diffusion Model"
        }
      },
      "13": {
        "inputs": {
          "noise": ["25", 0],
          "guider": ["22", 0],
          "sampler": ["16", 0],
          "sigmas": ["17", 0],
          "latent_image": ["5", 0]
        },
        "class_type": "SamplerCustomAdvanced",
        "_meta": {
          "title": "SamplerCustomAdvanced"
        }
      },
      "16": {
        "inputs": {
          "sampler_name": "euler"
        },
        "class_type": "KSamplerSelect",
        "_meta": {
          "title": "KSamplerSelect"
        }
      },
      "17": {
        "inputs": {
          "scheduler": "sgm_uniform",
          "steps": 4,
          "denoise": 1,
          "model": ["12", 0]
        },
        "class_type": "BasicScheduler",
        "_meta": {
          "title": "BasicScheduler"
        }
      },
      "22": {
        "inputs": {
          "model": ["12", 0],
          "conditioning": ["6", 0]
        },
        "class_type": "BasicGuider",
        "_meta": {
          "title": "BasicGuider"
        }
      },
      "25": {
        "inputs": {
          "noise_seed": 108076821791990
        },
        "class_type": "RandomNoise",
        "_meta": {
          "title": "RandomNoise"
        }
      }
    }
  }
}


=================================== File: test_resources/workflows/workflow_sd3.json ===================================

{
  "input": {
    "workflow": {
      "6": {
        "inputs": {
          "text": "comic illustration of a white unicorn with a golden horn and pink mane and tail standing amidst a colorful and magical fantasy landscape. The background is filled with pastel-colored mountains and fluffy clouds and colorful balloons and stars. There are vibrant rainbows arching across the sky. The ground is adorned with oversized, candy-like plants, trees shaped like lollipops, and swirling ice cream cones. The scene is bathed in soft, dreamy light, giving it an enchanting and otherworldly feel. 4k, high resolution",
          "clip": ["252", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Prompt)"
        }
      },
      "13": {
        "inputs": {
          "shift": 3,
          "model": ["252", 0]
        },
        "class_type": "ModelSamplingSD3",
        "_meta": {
          "title": "ModelSamplingSD3"
        }
      },
      "71": {
        "inputs": {
          "text": "worst quality, lowres, blurry, deformed, overexposure, bright, hands, oversaturated, burned, oversharpened, artifacts, hand, human, handwriting, nsfw, breast, breasts",
          "clip": ["252", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Negative Prompt)"
        }
      },
      "135": {
        "inputs": {
          "width": 1152,
          "height": 768,
          "batch_size": 1
        },
        "class_type": "EmptySD3LatentImage",
        "_meta": {
          "title": "EmptySD3LatentImage"
        }
      },
      "231": {
        "inputs": {
          "samples": ["271", 0],
          "vae": ["252", 2]
        },
        "class_type": "VAEDecode",
        "_meta": {
          "title": "VAE Decode"
        }
      },
      "252": {
        "inputs": {
          "ckpt_name": "sd3_medium_incl_clips_t5xxlfp8.safetensors"
        },
        "class_type": "CheckpointLoaderSimple",
        "_meta": {
          "title": "Load Checkpoint"
        }
      },
      "271": {
        "inputs": {
          "seed": 291740611171897,
          "steps": 28,
          "cfg": 4.5,
          "sampler_name": "dpmpp_2m",
          "scheduler": "sgm_uniform",
          "denoise": 1,
          "model": ["13", 0],
          "positive": ["6", 0],
          "negative": ["71", 0],
          "latent_image": ["135", 0]
        },
        "class_type": "KSampler",
        "_meta": {
          "title": "KSampler"
        }
      },
      "273": {
        "inputs": {
          "filename_prefix": "sd3/sd3",
          "images": ["231", 0]
        },
        "class_type": "SaveImage",
        "_meta": {
          "title": "Save Image"
        }
      }
    }
  }
}


=============================== File: test_resources/workflows/workflow_sdxl_turbo.json ================================

{
  "input": {
    "workflow": {
      "3": {
        "inputs": {
          "seed": 457699577674669,
          "steps": 3,
          "cfg": 1.5,
          "sampler_name": "euler_ancestral",
          "scheduler": "normal",
          "denoise": 1,
          "model": ["4", 0],
          "positive": ["6", 0],
          "negative": ["7", 0],
          "latent_image": ["5", 0]
        },
        "class_type": "KSampler",
        "_meta": {
          "title": "KSampler"
        }
      },
      "4": {
        "inputs": {
          "ckpt_name": "sd_xl_turbo_1.0_fp16.safetensors"
        },
        "class_type": "CheckpointLoaderSimple",
        "_meta": {
          "title": "Load Checkpoint"
        }
      },
      "5": {
        "inputs": {
          "width": 1024,
          "height": 1024,
          "batch_size": 1
        },
        "class_type": "EmptyLatentImage",
        "_meta": {
          "title": "Empty Latent Image"
        }
      },
      "6": {
        "inputs": {
          "text": "ancient rome, 4k photo",
          "clip": ["4", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Prompt)"
        }
      },
      "7": {
        "inputs": {
          "text": "text, watermark, blurry, ugly, deformed",
          "clip": ["4", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Prompt)"
        }
      },
      "8": {
        "inputs": {
          "samples": ["3", 0],
          "vae": ["4", 2]
        },
        "class_type": "VAEDecode",
        "_meta": {
          "title": "VAE Decode"
        }
      },
      "9": {
        "inputs": {
          "filename_prefix": "images/rome",
          "images": ["8", 0]
        },
        "class_type": "SaveImage",
        "_meta": {
          "title": "Save Image"
        }
      }
    }
  }
}


================================== File: test_resources/workflows/workflow_webp.json ===================================

{
  "input": {
    "workflow": {
      "3": {
        "inputs": {
          "seed": 416138702284529,
          "steps": 20,
          "cfg": 8,
          "sampler_name": "euler",
          "scheduler": "normal",
          "denoise": 1,
          "model": ["4", 0],
          "positive": ["6", 0],
          "negative": ["7", 0],
          "latent_image": ["5", 0]
        },
        "class_type": "KSampler",
        "_meta": {
          "title": "KSampler"
        }
      },
      "4": {
        "inputs": {
          "ckpt_name": "v1-5-pruned-emaonly.safetensors"
        },
        "class_type": "CheckpointLoaderSimple",
        "_meta": {
          "title": "Load Checkpoint"
        }
      },
      "5": {
        "inputs": {
          "width": 512,
          "height": 512,
          "batch_size": 1
        },
        "class_type": "EmptyLatentImage",
        "_meta": {
          "title": "Empty Latent Image"
        }
      },
      "6": {
        "inputs": {
          "text": "beautiful scenery nature glass bottle landscape, purple galaxy bottle,",
          "clip": ["4", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Prompt)"
        }
      },
      "7": {
        "inputs": {
          "text": "text, watermark",
          "clip": ["4", 1]
        },
        "class_type": "CLIPTextEncode",
        "_meta": {
          "title": "CLIP Text Encode (Prompt)"
        }
      },
      "8": {
        "inputs": {
          "samples": ["3", 0],
          "vae": ["4", 2]
        },
        "class_type": "VAEDecode",
        "_meta": {
          "title": "VAE Decode"
        }
      },
      "10": {
        "inputs": {
          "output_path": "output_path",
          "filename_prefix": "filename_prefix",
          "filename_delimiter": "___",
          "filename_number_padding": 4,
          "filename_number_start": "false",
          "extension": "webp",
          "quality": 10,
          "lossless_webp": "false",
          "overwrite_mode": "false",
          "show_history": "false",
          "show_history_by_prefix": "false",
          "embed_workflow": "false",
          "show_previews": "false",
          "images": ["8", 0]
        },
        "class_type": "Image Save",
        "_meta": {
          "title": "Image Save"
        }
      },
      "11": {
        "inputs": {
          "images": ["8", 0]
        },
        "class_type": "PreviewImage",
        "_meta": {
          "title": "Preview Image"
        }
      },
      "12": {
        "inputs": {
          "images": ["8", 0]
        },
        "class_type": "PreviewImage",
        "_meta": {
          "title": "Preview Image"
        }
      }
    }
  }
}


=============================================== File: tests/__init__.py ================================================




============================================= File: tests/test_handler.py ==============================================

import unittest
from unittest.mock import patch, MagicMock, mock_open, Mock
import sys
import os
import json
import base64

# Make sure that "src" is known and can be used to import handler.py
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src")))
from src import handler

# Local folder for test resources
RUNPOD_WORKER_COMFY_TEST_RESOURCES_IMAGES = "./test_resources/images"


class TestRunpodWorkerComfy(unittest.TestCase):
    def test_valid_input_with_workflow_only(self):
        input_data = {"workflow": {"key": "value"}}
        validated_data, error = handler.validate_input(input_data)
        self.assertIsNone(error)
        self.assertEqual(validated_data, {"workflow": {"key": "value"}, "images": None})

    def test_valid_input_with_workflow_and_images(self):
        input_data = {
            "workflow": {"key": "value"},
            "images": [{"name": "image1.png", "image": "base64string"}],
        }
        validated_data, error = handler.validate_input(input_data)
        self.assertIsNone(error)
        self.assertEqual(validated_data, input_data)

    def test_input_missing_workflow(self):
        input_data = {"images": [{"name": "image1.png", "image": "base64string"}]}
        validated_data, error = handler.validate_input(input_data)
        self.assertIsNotNone(error)
        self.assertEqual(error, "Missing 'workflow' parameter")

    def test_input_with_invalid_images_structure(self):
        input_data = {
            "workflow": {"key": "value"},
            "images": [{"name": "image1.png"}],  # Missing 'image' key
        }
        validated_data, error = handler.validate_input(input_data)
        self.assertIsNotNone(error)
        self.assertEqual(
            error, "'images' must be a list of objects with 'name' and 'image' keys"
        )

    def test_invalid_json_string_input(self):
        input_data = "invalid json"
        validated_data, error = handler.validate_input(input_data)
        self.assertIsNotNone(error)
        self.assertEqual(error, "Invalid JSON format in input")

    def test_valid_json_string_input(self):
        input_data = '{"workflow": {"key": "value"}}'
        validated_data, error = handler.validate_input(input_data)
        self.assertIsNone(error)
        self.assertEqual(validated_data, {"workflow": {"key": "value"}, "images": None})

    def test_empty_input(self):
        input_data = None
        validated_data, error = handler.validate_input(input_data)
        self.assertIsNotNone(error)
        self.assertEqual(error, "Please provide input")

    @patch("handler.requests.get")
    def test_check_server_server_up(self, mock_requests):
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_requests.return_value = mock_response

        result = handler.check_server("http://127.0.0.1:8188", 1, 50)
        self.assertTrue(result)

    @patch("handler.requests.get")
    def test_check_server_server_down(self, mock_requests):
        mock_requests.get.side_effect = handler.requests.RequestException()
        result = handler.check_server("http://127.0.0.1:8188", 1, 50)
        self.assertFalse(result)

    @patch("handler.urllib.request.urlopen")
    def test_queue_prompt(self, mock_urlopen):
        mock_response = MagicMock()
        mock_response.read.return_value = json.dumps({"prompt_id": "123"}).encode()
        mock_urlopen.return_value = mock_response
        result = handler.queue_workflow({"prompt": "test"})
        self.assertEqual(result, {"prompt_id": "123"})

    @patch("handler.urllib.request.urlopen")
    def test_get_history(self, mock_urlopen):
        # Mock response data as a JSON string
        mock_response_data = json.dumps({"key": "value"}).encode("utf-8")

        # Define a mock response function for `read`
        def mock_read():
            return mock_response_data

        # Create a mock response object
        mock_response = Mock()
        mock_response.read = mock_read

        # Mock the __enter__ and __exit__ methods to support the context manager
        mock_response.__enter__ = lambda s: s
        mock_response.__exit__ = Mock()

        # Set the return value of the urlopen mock
        mock_urlopen.return_value = mock_response

        # Call the function under test
        result = handler.get_history("123")

        # Assertions
        self.assertEqual(result, {"key": "value"})
        mock_urlopen.assert_called_with("http://127.0.0.1:8188/history/123")

    @patch("builtins.open", new_callable=mock_open, read_data=b"test")
    def test_base64_encode(self, mock_file):
        test_data = base64.b64encode(b"test").decode("utf-8")

        result = handler.base64_encode("dummy_path")

        self.assertEqual(result, test_data)

    @patch("handler.os.path.exists")
    @patch("handler.rp_upload.upload_image")
    @patch.dict(
        os.environ, {"COMFY_OUTPUT_PATH": RUNPOD_WORKER_COMFY_TEST_RESOURCES_IMAGES}
    )
    def test_bucket_endpoint_not_configured(self, mock_upload_image, mock_exists):
        mock_exists.return_value = True
        mock_upload_image.return_value = "simulated_uploaded/image.png"

        outputs = {
            "node_id": {"images": [{"filename": "ComfyUI_00001_.png", "subfolder": ""}]}
        }
        job_id = "123"

        result = handler.process_output_images(outputs, job_id)

        self.assertEqual(result["status"], "success")

    @patch("handler.os.path.exists")
    @patch("handler.rp_upload.upload_image")
    @patch.dict(
        os.environ,
        {
            "COMFY_OUTPUT_PATH": RUNPOD_WORKER_COMFY_TEST_RESOURCES_IMAGES,
            "BUCKET_ENDPOINT_URL": "http://example.com",
        },
    )
    def test_bucket_endpoint_configured(self, mock_upload_image, mock_exists):
        # Mock the os.path.exists to return True, simulating that the image exists
        mock_exists.return_value = True

        # Mock the rp_upload.upload_image to return a simulated URL
        mock_upload_image.return_value = "http://example.com/uploaded/image.png"

        # Define the outputs and job_id for the test
        outputs = {
            "node_id": {
                "images": [{"filename": "ComfyUI_00001_.png", "subfolder": "test"}]
            }
        }
        job_id = "123"

        # Call the function under test
        result = handler.process_output_images(outputs, job_id)

        # Assertions
        self.assertEqual(result["status"], "success")
        self.assertEqual(result["message"], "http://example.com/uploaded/image.png")
        mock_upload_image.assert_called_once_with(
            job_id, "./test_resources/images/test/ComfyUI_00001_.png"
        )

    @patch("handler.os.path.exists")
    @patch("handler.rp_upload.upload_image")
    @patch.dict(
        os.environ,
        {
            "COMFY_OUTPUT_PATH": RUNPOD_WORKER_COMFY_TEST_RESOURCES_IMAGES,
            "BUCKET_ENDPOINT_URL": "http://example.com",
            "BUCKET_ACCESS_KEY_ID": "",
            "BUCKET_SECRET_ACCESS_KEY": "",
        },
    )
    def test_bucket_image_upload_fails_env_vars_wrong_or_missing(
        self, mock_upload_image, mock_exists
    ):
        # Simulate the file existing in the output path
        mock_exists.return_value = True

        # When AWS credentials are wrong or missing, upload_image should return 'simulated_uploaded/...'
        mock_upload_image.return_value = "simulated_uploaded/image.png"

        outputs = {
            "node_id": {"images": [{"filename": "ComfyUI_00001_.png", "subfolder": ""}]}
        }
        job_id = "123"

        result = handler.process_output_images(outputs, job_id)

        # Check if the image was saved to the 'simulated_uploaded' directory
        self.assertIn("simulated_uploaded", result["message"])
        self.assertEqual(result["status"], "success")

    @patch("handler.requests.post")
    def test_upload_images_successful(self, mock_post):
        mock_response = unittest.mock.Mock()
        mock_response.status_code = 200
        mock_response.text = "Successfully uploaded"
        mock_post.return_value = mock_response

        test_image_data = base64.b64encode(b"Test Image Data").decode("utf-8")

        images = [{"name": "test_image.png", "image": test_image_data}]

        responses = handler.upload_images(images)

        self.assertEqual(len(responses), 3)
        self.assertEqual(responses["status"], "success")

    @patch("handler.requests.post")
    def test_upload_images_failed(self, mock_post):
        mock_response = unittest.mock.Mock()
        mock_response.status_code = 400
        mock_response.text = "Error uploading"
        mock_post.return_value = mock_response

        test_image_data = base64.b64encode(b"Test Image Data").decode("utf-8")

        images = [{"name": "test_image.png", "image": test_image_data}]

        responses = handler.upload_images(images)

        self.assertEqual(len(responses), 3)
        self.assertEqual(responses["status"], "error")


========================================= File: tests/test_restore_snapshot.sh =========================================

#!/usr/bin/env bash

# Set up error handling
set -e

# Store the path to the script we want to test
SCRIPT_TO_TEST="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src/restore_snapshot.sh"

# Ensure the script exists and is executable
if [ ! -f "$SCRIPT_TO_TEST" ]; then
    echo "Error: Script not found at $SCRIPT_TO_TEST"
    exit 1
fi
chmod +x "$SCRIPT_TO_TEST"

# Create test directory
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Create a minimal mock snapshot file
cat > test_restore_snapshot_temporary.json << 'EOF'
{
  "comfyui": "test-hash",
  "git_custom_nodes": {},
  "file_custom_nodes": [],
  "pips": {}
}
EOF

# Create a mock comfy command that simulates the real comfy behavior
cat > comfy << 'EOF'
#!/bin/bash
if [[ "$1" == "--workspace" && "$3" == "restore-snapshot" ]]; then
    # Verify the snapshot file exists
    if [[ ! -f "$4" ]]; then
        echo "Error: Snapshot file not found"
        exit 1
    fi
    echo "Mock: Restored snapshot from $4"
    exit 0
fi
EOF

chmod +x comfy
export PATH="$TEST_DIR:$PATH"

# Run the actual restore_snapshot script
echo "Testing snapshot restoration..."
echo "Script location: $SCRIPT_TO_TEST"
"$SCRIPT_TO_TEST"

# Verify the script executed successfully
if [ $? -eq 0 ]; then
    echo "✅ Test passed: Snapshot restoration script executed successfully"
else
    echo "❌ Test failed: Snapshot restoration script failed"
    exit 1
fi

# Clean up
rm -rf "$TEST_DIR"

