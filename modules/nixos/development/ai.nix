# Enable things for AI.

{
  config,
  lib,
  pkgs,
  ...
}:
let
  # llama-cpp: also includes llama-bench, etc.
  llama-cpp-vulkan = (pkgs.llama-cpp.override { vulkanSupport = true; }).overrideAttrs (old: rec {
    version = "9786";
    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "llama.cpp";
      rev = "b${version}";
      hash = "sha256-9YtbaIjkdlxsqXlKdjsgYg/YuA2xrnNl1hAXyxLtFGE=";
    };
    npmDepsHash = "sha256-X1DZgmhS/zHTqDT5zq0kywwntthcJ9vRXeqyO3zz6UU=";
  });
  # ROCm can be used instead of Vulkan:
  # llama-cpp-rocm = pkgs.llama-cpp.override { rocmSupport = true; };
  # but my brief usage showed it's currently slower on 780M:

  llama-server = lib.getExe' llama-cpp-vulkan "llama-server";

  llama-swap-latest = pkgs.stdenv.mkDerivation rec {
    pname = "llama-swap";
    version = "229";
    src = pkgs.fetchurl {
      url = "https://github.com/mostlygeek/llama-swap/releases/download/v${version}/llama-swap_${version}_linux_amd64.tar.gz";
      hash = "sha256-AdJf5KZgmbGboJ671ATonDVnouCps/34iBApJx8GD80=";
    };
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/bin
      install -m755 llama-swap $out/bin/llama-swap
    '';
    meta = {
      mainProgram = "llama-swap";
    };
  };
in
{
  options = {
    programs.development.ai.enable = lib.mkEnableOption "enables config for AI development, LLMs, etc.";
  };

  config = lib.mkIf config.programs.development.ai.enable {
    services.llama-swap = {
      enable = true;
      package = llama-swap-latest;
      settings = {
        healthCheckTimeout = 3000;
        includeAliasesInList = true;
        sendLoadingState = true;

        models = {
          "qwen3.6-35b-a3b" = {
            # `--jinja` is required for thinking toggle
            cmd = ''
              ${llama-server} --port ''${PORT}
              -m /var/lib/llama-swap/unsloth-Qwen3.6-35B-A3B-MTP/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf
              --mmproj /var/lib/llama-swap/unsloth-Qwen3.6-35B-A3B-MTP/mmproj-F16.gguf
              --ctx-size 32768
              --parallel 1
              --gpu-layers 999
              --jinja
              --flash-attn on
              --batch-size 2048
              --ubatch-size 512
              --cache-type-k q8_0
              --cache-type-v q8_0
              --cache-type-k-draft q8_0
              --cache-type-v-draft q8_0
              --min-p 0.0
              --spec-type draft-mtp --spec-draft-n-max 2
            '';

            ttl = 0;

            filters.setParamsByID = {
              "qwen3.6-35b-a3b" = {
                chat_template_kwargs = {
                  enable_thinking = true;
                  preserve_thinking = true;
                };
                temperature = 1.0;
                top_p = 0.95;
                top_k = 20;
                presence_penalty = 0.0;
              };
              "qwen3.6-35b-a3b:code" = {
                chat_template_kwargs = {
                  enable_thinking = true;
                  preserve_thinking = true;
                };
                temperature = 0.6;
                top_p = 0.95;
                top_k = 20;
                presence_penalty = 0.0;
              };
              "qwen3.6-35b-a3b:fast" = {
                chat_template_kwargs = {
                  enable_thinking = false;
                  preserve_thinking = false;
                };
                temperature = 0.7;
                top_p = 0.8;
                top_k = 20;
                presence_penalty = 1.5;
              };
            };

            aliases = [
              "qwen3.6-35b-a3b:code"
              "qwen3.6-35b-a3b:fast"
            ];
          };

          # TODO: test the Claude/APEX distilled version
          # https://huggingface.co/mudler/Qwen3.6-35B-A3B-Claude-4.7-Opus-Reasoning-Distilled-APEX-MTP-GGUF
          # "qwen3-35b-claude-apex" = {
          #   # Originally, `--spec-draft-n-max 2` resulted in error in Pi after
          #   # some prompts: `Invalid input batch.`
          #   # Might be these:
          #   # - https://github.com/ggml-org/llama.cpp/issues/24541
          #   # - https://github.com/ggml-org/llama.cpp/issues/24040
          #   # `--jinja` is equired for thinking toggle
          #   cmd = ''
          #     ${llama-server}
          #       --port ''${PORT}
          #       -m /var/lib/llama-swap/Qwen3.6-35B-A3B-Claude-4.7-Opus-Reasoning-Distilled-APEX-MTP/Qwen3.6-35B-A3B-Claude-4.7-Opus-Reasoning-Distilled-APEX-MTP-I-Quality.gguf
          #       --ctx-size 32768
          #       --gpu-layers 999
          #       --jinja
          #       --spec-type draft-mtp
          #       --spec-draft-n-max 1
          #       --flash-attn on
          #       --cache-type-k q8_0
          #       --cache-type-v q8_0

          #       --dry-multiplier 0.8 --dry-base 1.75 --dry-allowed-length 2
          #   ''; # trying out dry to prevent looping in Qwen3.6 models
          #   ttl = 0;

          #   filters.setParamsByID = {
          #     "qwen3-6" = {
          #       chat_template_kwargs = {
          #         enable_thinking = true;
          #         preserve_thinking = true;
          #       };
          #       temperature = 0.6;
          #       top_p = 0.95;
          #       top_k = 20;
          #     };

          #     "qwen3-35b-claude-apex:fast" = {
          #       chat_template_kwargs = {
          #         enable_thinking = false;
          #         preserve_thinking = false;
          #       };
          #       temperature = 0.7;
          #       top_p = 0.8;
          #       top_k = 20;
          #     };

          #     "qwen3-35b-claude-apex:deep" = {
          #       chat_template_kwargs = {
          #         enable_thinking = true;
          #         preserve_thinking = true;
          #       };
          #       temperature = 0.1;
          #       top_p = 0.95;
          #       top_k = 20;
          #     };
          #   };

          #   aliases = [
          #     "qwen3-35b-claude-apex:fast"
          #     "qwen3-35b-claude-apex:deep"
          #   ];
          # };

          "gemma-4-12b-qat" = {
            cmd = ''
              ${llama-server} --port ''${PORT}
              -m /var/lib/llama-swap/unsloth-gemma-4-12B-it-qat/gemma-4-12B-it-qat-UD-Q4_K_XL.gguf
              --mmproj /var/lib/llama-swap/unsloth-gemma-4-12B-it-qat/mmproj-F16.gguf
              --model-draft /var/lib/llama-swap/unsloth-gemma-4-12B-it-qat/mtp-gemma-4-12B-it.gguf
              --parallel 1
              --ctx-size 32768
              --gpu-layers 999
              --jinja
              --flash-attn on
              --batch-size 2048
              --ubatch-size 2048
              --cache-type-k q8_0
              --cache-type-v q8_0
              --cache-type-k-draft q8_0
              --cache-type-v-draft q8_0
              --spec-type draft-mtp --spec-draft-n-max 4
            '';

            ttl = 300;

            filters.setParamsByID = {
              "gemma-4-12b-qat" = {
                chat_template_kwargs = {
                  enable_thinking = true;
                };
                temperature = 1.0;
                top_p = 0.95;
                top_k = 64;
              };
              "gemma-4-12b-qat:fast" = {
                chat_template_kwargs = {
                  enable_thinking = false;
                };
                temperature = 0.7;
                top_p = 0.8;
                top_k = 64;
              };
              "gemma-4-12b-qat:deep" = {
                chat_template_kwargs = {
                  enable_thinking = true;
                };
                temperature = 0.3;
                top_p = 0.95;
                top_k = 64;
              };
            };

            aliases = [
              "gemma-4-12b-qat:fast"
              "gemma-4-12b-qat:deep"
            ];
          };
        };

        port = 8080;
      };
    };

    # Allows GPU backends to persist compiled shaders since NixOS doesn't allow
    # writing to root, which forces recompilation on every load.
    # E.g. First load of Gemma 4 12B takes a while, but subsequent loads should
    # be fast.
    systemd.services.llama-swap = {
      environment = {
        XDG_CACHE_HOME = "/var/cache/llama-swap";
      };
      serviceConfig = {
        CacheDirectory = "llama-swap";
        CacheDirectoryMode = "0750";
      };
    };

    # Create dir for models/files that llama-swap can access.
    systemd.tmpfiles.rules = [
      "d /var/lib/llama-swap 0755 llama-swap llama-swap -"
    ];

    # Open WebUI
    services.open-webui = {
      enable = true;
      port = 12345;
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        WEBUI_AUTH = "False";
        ENABLE_OLLAMA_API = "False";
        OPENAI_API_BASE_URL = "http://127.0.0.1:8080/v1";
        OPENAI_API_KEY = "dummy";
      };
    };

    environment.systemPackages = [
      llama-cpp-vulkan
    ];
  };
}
