defmodule Burrito.Platform do
  @type supported_os :: :windows | :linux | :darwin
  @type supported_arch :: :x86_64 | :arm64
  @type supported_libc :: :gnu | :musl | :none

  @type build_tuple :: {supported_os(), supported_arch(), supported_libc()} | {supported_os(), supported_arch()}

  @spec make_zig_triplet(build_tuple()) :: String.t()
  def make_zig_triplet({os, arch, libc}) do
    "#{Atom.to_string(arch)}-#{Atom.to_string(os)}-#{Atom.to_string(libc)}"
  end

  def make_zig_triplet({os, arch}) do
    "#{Atom.to_string(arch)}-#{Atom.to_string(os)}"
  end

  @callback init(Burrito.BuildContext.t()) :: Burrito.BuildContext.t()
  @callback recompile_nifs(Burrito.BuildContext.t()) :: Burrito.BuildContext.t()
  @callback compile_wrapper(Burrito.BuildContext.t()) :: Burrito.BuildContext.t()
end

defmodule Burrito.BuildContext do
  use TypedStruct

  alias Burrito.Platform

  typedstruct do
    field(:self_path, String.t(), enforce: true)
    field(:work_directory, String.t(), enforce: true)
    field(:target, Platform.build_tuple(), enforce: true)
    field(:plugin, String.t() | nil, enforce: true)
    field(:release, Mix.Release.t(), enforce: true)
    field(:debug?, boolean(), enforce: true)
  end
end
