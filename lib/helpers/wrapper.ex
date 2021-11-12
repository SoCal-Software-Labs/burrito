defmodule Burrito.Helpers.Wrapper do
  require Logger

  alias Burrito.BuildContext
  alias Burrito.Helpers
  alias Burrito.Platform
  alias Burrito.Zig

  @success_banner """
  \n\n
  🌯 Burrito has wrapped your Elixir app! 🌯
  """

  def build_wrapper(%BuildContext{} = build_context) do
    zig_target_string = Platform.make_zig_triplet(build_context.target)
    zig_build_args = ["-Dtarget=#{zig_target_string}"]

    zig_build_args =
      if build_context.debug? do
        zig_build_args
      else
        ["-Drelease-small=true" | zig_build_args]
      end

    release_name = Atom.to_string(build_context.release.name)

    Helpers.Metadata.run(build_context.self_path, zig_build_args, build_context.release)

    Path.join(build_context.work_directory, ["/lib", "/.burrito"]) |> File.touch!()

    is_prod? = if build_context.debug? do
      "0"
    else
      "1"
    end

    build_env = [
      {"__BURRITO_IS_PROD", is_prod?},
      {"__BURRITO_RELEASE_PATH", build_context.work_directory},
      {"__BURRITO_RELEASE_NAME", release_name},
      {"__BURRITO_PLUGIN_PATH", build_context.plugin}
    ]

    result = Zig.build(build_context.self_path, zig_build_args, build_env)

    case result do
      {_, 0} -> :ok
      _ ->
        Logger.error("Zig build failed, please check the output logs!")
        exit(1)
    end
  end

  @spec copy_wrapper(Burrito.BuildContext.t()) :: :ok
  def copy_wrapper(%BuildContext{} = build_context) do
    app_path = File.cwd!()

    bin_dir = Path.join(build_context.self_path, ["zig-out", "/bin"])
    bin_path = Path.join(build_context.self_path, ["zig-out", "/bin", "/*"]) |> Path.wildcard() |> List.first()
    bin_out_path = Path.join(app_path, ["burrito_out", "/#{Mix.env()}_", Platform.make_zig_triplet(build_context.target)])

    File.mkdir_p!(bin_out_path)

    File.chmod!(bin_path, 0o744)
    File.cp_r(bin_dir, bin_out_path, fn _, _ -> true end)
    File.rm!(bin_path)

    IO.puts(@success_banner <> "\tOutput Directory: #{bin_out_path}")
  end
end
