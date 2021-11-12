defmodule Burrito.Zig do
  require Logger

  @spec build(String.t(), list(String.t()), list({String.t(), String.t()}), nil | IO.Stream.t()) :: {Collectable.t(), non_neg_integer()}
  def build(cwd, zig_build_args, env \\ [], into \\ IO.stream()) do
    Logger.info("Running Zig Build Command: `zig build #{Enum.join(zig_build_args, " ")}`")
    System.cmd("zig", ["build"] ++ zig_build_args,
      cd: cwd,
      env: env,
      into: into
    )
  end

  def version(cwd \\ "./") do
    {zig_version_string, 0} = System.cmd("zig", ["version"], cd: cwd)
    String.trim(zig_version_string)
  end
end
