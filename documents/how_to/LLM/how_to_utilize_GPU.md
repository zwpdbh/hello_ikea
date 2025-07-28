# How to utilize GPU 

## The problem 

The `Nx` is used with `Bumblebee` to run LLM to generate text.

```elixir 
# in config/config.exs 
config :nx, default_backend: EXLA.Backend

# lib/hello/application.ex config Nx.Serving 
{Nx.Serving, serving: Hello.Rag.Serving.build_llm_serving(), name: MyLLMServing}

# Hello.Rag.Serving 
defmodule Hello.Rag.Serving do
  def build_llm_serving() do
    repo = {:hf, "microsoft/phi-3.5-mini-instruct"}

    {:ok, model_info} = Bumblebee.load_model(repo)
    {:ok, tokenizer} = Bumblebee.load_tokenizer(repo)
    {:ok, generation_config} = Bumblebee.load_generation_config(repo)

    generation_config = Bumblebee.configure(generation_config, max_new_tokens: 512)

    Bumblebee.Text.generation(model_info, tokenizer, generation_config,
      compile: [batch_size: 1, sequence_length: 6000],
      defn_options: [compiler: EXLA],
      stream: false
    )
  end
end
```

After above configuration, the generation of text is done by 

```elixir
defmodule Hello.Rag.Generator do
  def generate_response(query) do
    {:ok, sections} = Hello.Rag.search_section(%{query: query})

    context =
      sections
      |> Enum.map(fn %Hello.Rag.Section{chunk: chunk} ->
        """
        [...]
        #{chunk}
        [...]
        """
      end)
      |> Enum.join("\n\n")

    """
    <|system|>
    You are a helpful assistant.</s>
    <|user|>
    Context information is below.
    ---------------------
    #{context}
    ---------------------
    Given the context information and no prior knowledge, answer the query.
    Query: #{query}
    Answer: </s>
    <|assistant|>
    """

    # Nx.Serving.batched_run(MyLLMServing, prompt)
  end
end
```

However, the process of `generate_response` is so slow when only using CPU. 

How to utilize GPU?

## Steps to enable GPU 

To utilize GPU acceleration with Nx and Bumblebee in your Elixir project, you need to make sure of the following:

### Install and configure `EXLA` with CUDA backend

1. Ensure GPU is accesible using `CUDA`.

```sh 
nvidia-smi
Sun Jul 27 12:12:52 2025       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.86.16              Driver Version: 572.16         CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3090        On  |   00000000:01:00.0  On |                  N/A |
| 31%   36C    P8             30W /  350W |    1377MiB /  24576MiB |      1%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A              24      G   /Xwayland                             N/A      |
+-----------------------------------------------------------------------------------------+
```

It means 
- GPU Model: NVIDIA GeForce RTX 3090
- Total Memory: 24576 MiB (≈ 24 GB)
- Used Memory: 1377 MiB (≈ 1.3 GB)
- Free Memory: 24576 - 1377 ≈ 23.2 GB



2. Rebuild EXLA with CUDA support

```bash
mix deps.clean exla
mix deps.get
export XLA_TARGET="cuda"
mix deps.compile exla
```

Troubleshooting error:
```bash
mix deps.compile exla
==> exla
could not compile dependency :exla, "mix compile" failed. Errors may have been logged above. You can recompile this dependency with "mix deps.compile exla --force", update it with "mix deps.update exla" or clean it with "mix deps.clean exla"
** (RuntimeError) no precompiled XLA archive available for this target: x86_64-linux-gnu-cuda.

The available targets are:

  * x86_64-darwin-cpu
  * aarch64-darwin-cpu
  * x86_64-linux-gnu-cpu
  * aarch64-linux-gnu-cpu
  * x86_64-linux-gnu-cuda12
  * aarch64-linux-gnu-cuda12
  * x86_64-linux-gnu-tpu

You can compile XLA locally by setting an environment variable: XLA_BUILD=true
    (xla 0.9.1) lib/xla.ex:186: XLA.download_precompiled!/1
    (xla 0.9.1) lib/xla.ex:56: XLA.archive_path!/0
    /home/zw/code/elixir_programming/hello/deps/exla/mix.exs:116: EXLA.MixProject.extract_xla/1
```

It looks for `x86_64-linux-gnu-cuda` which is not in available targets. 
We need to adjust to `XLA_TARGET` to be `cuda12`.

Solution:

```bash
mix deps.clean exla && mix deps.get
export XLA_TARGET=cuda12 && mix deps.compile exla
```

However, this time new error produced:

```bash
mix deps.compile exla

12:19:51.982 [info] Downloading a precompiled XLA archive for target x86_64-linux-gnu-cuda12

12:20:14.543 [info] Successfully downloaded the XLA archive
==> exla
Unpacking /home/zw/.cache/xla/0.9.1/download/xla_extension-0.9.1-x86_64-linux-gnu-cuda12.tar.gz into /home/zw/code/elixir_programming/hello/deps/exla/cache
EXLA_CPU_ONLY is not set, checking for nvcc availability
CUDA is not available.
g++ -fPIC -I/home/zw/.asdf/installs/erlang/27.3.3/erts-15.2.6/include -I/home/zw/code/elixir_programming/hello/deps/fine/include -Icache/xla_extension/include -Wall -Wno-sign-compare -Wno-unused-parameter -Wno-missing-field-initializers -Wno-comment -std=c++17 -w -O3 -c c_src/exla/exla.cc -o cache/0.10.0/objs/exla.o
...
Caching libexla.so at /home/zw/.cache/xla/exla/elixir-1.18.4-erts-15.2.6-xla-0.9.1-exla-0.10.0-ymq6wkipo5buwst5rpr4nmx2iu/libexla.so
Compiling 23 files (.ex)

12:20:38.870 [error] Process #PID<0.283.0> raised an exception
** (RuntimeError) Failed to load NIF library.
Follow the steps in the :exla README Troubleshooting section for more information.

:load_failed
Failed to load NIF library /home/zw/code/elixir_programming/hello/_build/dev/lib/exla/priv/libexla: 'libnccl.so.2: cannot open shared object file: No such file or directory'

    lib/exla/nif.ex:13: EXLA.NIF.__on_load__/0
    (kernel 10.2.6) code_server.erl:1379: anonymous fn/1 in :code_server.schedule_on_load/4

12:20:38.876 [warning] The on_load function for module Elixir.EXLA.NIF returned:
{%RuntimeError{
   message: "Failed to load NIF library.\nFollow the steps in the :exla README Troubleshooting section for more information.\n\n:load_failed\nFailed to load NIF library /home/zw/code/elixir_programming/hello/_build/dev/lib/exla/priv/libexla: 'libnccl.so.2: cannot open shared object file: No such file or directory'\n"
 },
 [
   {EXLA.NIF, :__on_load__, 0,
    [file: ~c"lib/exla/nif.ex", line: 13, error_info: %{...}]},
   {:code_server, :"-schedule_on_load/4-fun-0-", 1,
    [file: ~c"code_server.erl", line: 1379]}
 ]}

Generated exla app
```

solution: we need to install [NCCL](https://docs.nvidia.com/deeplearning/nccl/install-guide/index.html#down).
Use the script `install_nccl.sh` to install `NCCL` according the above document.

Keep compiling, it shows another error:

```sh 
Failed to load NIF library /home/zw/code/elixir_programming/hello/_build/dev/lib/exla/priv/libexla: 'libcudnn_engines_precompiled.so.9: cannot open shared object file: No such file or directory'
```

Solution: download [cuDNN Archive](https://developer.nvidia.com/rdp/cudnn-archive)

```sh 
sudo dpkg -i cudnn-local-repo-cross-sbsa-ubuntu2204-8.9.7.29_1.0-1_all.deb
# Then follow the instruction to copy:
# sudo cp /var/cudnn-local-repo-cross-sbsa-ubuntu2204-8.9.7.29/cudnn-local-82E66276-keyring.gpg /usr/share/keyrings/
sudo apt-key add /usr/share/keyrings/cudnn-local-*.key
sudo apt update
sudo apt install libcudnn9-cuda-12 libcudnn9-dev-cuda-12 libcudnn9-samples

# check libcudnn whether is installed by 
dpkg -l | grep libcudnn
```

Finally

```sh 
mix deps.clean exla && mix deps.get
export XLA_TARGET=cuda12 && mix deps.compile exla
==> exla
Unpacking /home/zw/.cache/xla/0.9.1/download/xla_extension-0.9.1-x86_64-linux-gnu-cuda12.tar.gz into /home/zw/code/elixir_programming/hello/deps/exla/cache
Using libexla.so from /home/zw/.cache/xla/exla/elixir-1.18.4-erts-15.2.6-xla-0.9.1-exla-0.10.0-ymq6wkipo5buwst5rpr4nmx2iu/libexla.so
EXLA_CPU_ONLY is not set, checking for nvcc availability
CUDA is not available.
g++ -fPIC -I/home/zw/.asdf/installs/erlang/27.3.3/erts-15.2.6/include -I/home/zw/code/elixir_programming/hello/deps/fine/include -Icache/xla_extension/include -Wall -Wno-sign-compare -Wno-unused-parameter -Wno-missing-field-initializers -Wno-comment -std=c++17 -w -O3 -c c_src/exla/exla_client.cc -o cache/0.10.0/objs/exla_client.o
....
exla_cuda.cc -o cache/0.10.0/objs/exla_cuda.o
g++ cache/0.10.0/objs/exla.o cache/0.10.0/objs/exla_client.o cache/0.10.0/objs/exla_mlir.o cache/0.10.0/objs/ipc.o cache/0.10.0/objs/custom_calls/eigh_f32.o cache/0.10.0/objs/custom_calls/eigh_f64.o cache/0.10.0/objs/custom_calls/lu_bf16.o cache/0.10.0/objs/custom_calls/lu_f16.o cache/0.10.0/objs/custom_calls/lu_f32.o cache/0.10.0/objs/custom_calls/lu_f64.o cache/0.10.0/objs/custom_calls/qr_bf16.o cache/0.10.0/objs/custom_calls/qr_f16.o cache/0.10.0/objs/custom_calls/qr_f32.o cache/0.10.0/objs/custom_calls/qr_f64.o cache/0.10.0/objs/exla_cuda.o -o cache/libexla.so -Lcache/xla_extension/lib -lxla_extension -shared -fvisibility=hidden -Wl,-rpath,'$ORIGIN/xla_extension/lib'
Compiling 23 files (.ex)
Generated exla app
```

After starting Phoenix application, then run `nvidia-smi`:

```sh
nvidia-smi
Mon Jul 28 09:44:45 2025       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 570.86.16              Driver Version: 572.16         CUDA Version: 12.8     |
|-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3090        On  |   00000000:01:00.0  On |                  N/A |
| 30%   35C    P8             29W /  350W |   23736MiB /  24576MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                         
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A              25      G   /Xwayland                             N/A      |
|    0   N/A  N/A            7753      C   /beam.smp                             N/A      |
+-----------------------------------------------------------------------------------------+ 
```




## References 

- [Google's XLA (Accelerated Linear Algebra) compiler/backend for Nx.](https://hexdocs.pm/exla/EXLA.html)