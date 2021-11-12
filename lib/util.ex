defmodule Burrito.Util do
  @spec get_current_os :: :darwin | :linux | :windows
  def get_current_os do
    case :os.type() do
      {:win32, _} -> :windows
      {:unix, :darwin} -> :darwin
      {:unix, :linux} -> :linux
    end
  end

  @spec get_libc_type :: :linux | :linux_musl
  def get_libc_type do
    {result, _} = System.cmd("ldd", ["--version"])

    cond do
      String.contains?(result, "musl") -> :linux_musl
      true -> :linux
    end
  end

  @spec is_prod? :: <<_::8>>
  def is_prod?() do
    if Mix.env() == :prod do
      "1"
    else
      "0"
    end
  end

  @spec get_otp_verson :: binary
  def get_otp_verson() do
    {:ok, opt_verson} =
      :file.read_file(
        :filename.join([
          :code.root_dir(),
          "releases",
          :erlang.system_info(:otp_release),
          "OTP_VERSION"
        ])
      )

    String.trim(opt_verson)
  end
end
