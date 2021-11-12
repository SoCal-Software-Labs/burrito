defmodule Burrito do
  alias Burrito.Helpers

  require Logger

  alias Burrito.BuildContext

  @spec wrap(Mix.Release.t()) :: Mix.Release.t()
  def wrap(%Mix.Release{} = release) do
    options = release.options[:burrito] || []
    targets = Keyword.get(options, :targets, [:native])
    debug? = Keyword.get(options, :debug, false)
    no_clean? = Keyword.get(options, :no_clean, false)
    plugin = Keyword.get(options, :plugin, nil)

    plugin_result = Helpers.ZigPlugins.run(plugin)

    Enum.each(targets, fn target ->
      dispatch_platform(target, release, plugin_result, debug?, no_clean?)
    end)

    release
  end

  defp dispatch_platform(platform, release, plugin, debug?, no_clean?) do
    random_build_dir_id = :crypto.strong_rand_bytes(8) |> Base.encode16()

    release_working_path =
      System.tmp_dir!()
      |> Path.join(["burrito_build_#{random_build_dir_id}"])

    Logger.info("Platform Tuple: #{inspect(platform)}")
    Logger.info("Working directory: #{release_working_path}")

    File.cp_r(release.path, release_working_path, fn _, _ -> true end)

    build_context = %BuildContext{
      self_path: get_self_path(),
      work_directory: release_working_path,
      target: platform,
      debug?: debug?,
      release: release,
      plugin: plugin,
    }

    platform_os = elem(platform, 0)

    platform_module =
      case elem(platform, 0) do
        :windows -> Burrito.Platforms.Windows
        :linux -> Burrito.Platforms.Linux
        :darwin -> Burrito.Platforms.Darwin
        _ -> nil
      end

    if platform_module do
      # Pre-checks
      Helpers.Precheck.run()

      # Boot up finch
      :telemetry_sup.start_link()
      Finch.start_link(name: Req.Finch)

      # Maybe download replacement ERTS
      platform_module.download_erts(build_context)

      # Patch the ERTS statup scripts
      Helpers.PatchStartupScripts.run(build_context.self_path, build_context.work_directory, release.name)

      # Maybe recompile NIFs
      platform_module.recompile_nifs(build_context)

      # Build and copy the binary
      platform_module.compile_wrapper(build_context)
    else
      Logger.error(
        "Could not find a platform module for #{platform_os}, please implement one using the `Burrito.Platform` behaviour!"
      )
    end

    unless no_clean? do
      Helpers.Clean.run(build_context.self_path)
      File.rm_rf!(build_context.work_directory)
    end
  end

  defp get_self_path do
    __ENV__.file
    |> Path.dirname()
    |> Path.split()
    |> List.delete_at(-1)
    |> Path.join()
  end
end
