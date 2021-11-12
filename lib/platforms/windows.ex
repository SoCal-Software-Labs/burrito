defmodule Burrito.Platforms.Windows do
  @behaviour Burrito.Platform

  alias Burrito.BuildContext
  alias Burrito.Helpers
  alias Burrito.Util

  require Logger

  @spec download_erts(BuildContext.t()) :: BuildContext.t()
  def download_erts(%BuildContext{} = build_context) do
    target_os = elem(build_context.target, 0)
    target_arch = elem(build_context.target, 1)

    # Currently we only support Windows 64-bit
    exit_if_wrong_arch(build_context)

    otp_version = Util.get_otp_verson()

    if Util.get_current_os() != target_os do
      Burrito.OTPFetcher.download_and_replace_erts_release(
        build_context.release.erts_version,
        otp_version,
        build_context.work_directory,
        :win64
      )
    end

    target_arch
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
