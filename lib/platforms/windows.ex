defmodule Burrito.Platforms.Windows do
  @behaviour Burrito.Platform

  alias Burrito.BuildContext
  alias Burrito.Helpers

  require Logger

  @spec init(BuildContext.t()) :: BuildContext.t()
  def init(%BuildContext{} = build_context) do
    # Currently we only support Windows 64-bit
    exit_if_wrong_arch(build_context)

    build_context
  end

  @spec recompile_nifs(BuildContext.t()) :: BuildContext.t()
  def recompile_nifs(%BuildContext{} = build_context) do
    build_context
  end

  @spec compile_wrapper(BuildContext.t()) :: BuildContext.t()
  def compile_wrapper(%BuildContext{} = build_context) do
    Helpers.Wrapper.build_wrapper(build_context)
    Helpers.Wrapper.copy_wrapper(build_context)
    build_context
  end

  defp exit_if_wrong_arch(%BuildContext{} = build_context) do
    target_os = elem(build_context.target, 0)
    target_arch = elem(build_context.target, 1)

    if target_arch != :x86_64 do
      Logger.error(
        "#{inspect(target_os)} does not currently support the architecture: #{target_arch}"
      )
      exit(1)
    end
  end
end
