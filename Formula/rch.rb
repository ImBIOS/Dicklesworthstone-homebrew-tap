class Rch < Formula
  desc "Remote Compilation Helper for AI coding agents"
  homepage "https://github.com/Dicklesworthstone/remote_compilation_helper"
  version "1.0.26"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/remote_compilation_helper/releases/download/v#{version}/rch-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "67a2a86a1a88c901b0fdca77112c05be74163ae0ce4da0b78dfd3969f4d713e8"
    end

    on_intel do
      url "https://github.com/Dicklesworthstone/remote_compilation_helper/releases/download/v#{version}/rch-v#{version}-x86_64-apple-darwin.tar.gz"
      sha256 "bc39e23a5c93f127c343c3199c31d80b2b5a1d32557b63581508bae8d0ac5d18"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/remote_compilation_helper/releases/download/v#{version}/rch-v#{version}-x86_64-unknown-linux-musl.tar.gz"
      sha256 "5972e88ff6b4d264420f46f0450c1289f18c6b79656510c177b3207e28daae46"
    end

    on_arm do
      url "https://github.com/Dicklesworthstone/remote_compilation_helper/releases/download/v#{version}/rch-v#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "81c8cb32b22cabd36d5f25abff84bc99e627464396780d2926beddfaa3b3762b"
    end
  end

  def install
    bin.install "rch"
    bin.install "rchd"
    bin.install "rch-wkr"
  end

  def caveats
    <<~EOS
      RCH offloads compilation commands to remote workers for AI coding agents.

      Quick start:
        rch init
        rch doctor
        rch workers probe --all
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rch --version")
    assert_match "doctor", shell_output("#{bin}/rch --help")
  end
end
