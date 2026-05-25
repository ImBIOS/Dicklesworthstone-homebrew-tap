# typed: false
# frozen_string_literal: true

# ee (Eidetic Engine CLI) - local-first memory substrate for coding agents
class Ee < Formula
  desc "Durable, local-first, explainable memory for coding agents"
  homepage "https://github.com/Dicklesworthstone/eidetic_engine_cli"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/eidetic_engine_cli/releases/download/v0.3.0/ee-aarch64-apple-darwin.tar.xz"
      sha256 "50640f6108c8530efc1584509683cb38c708777ca282c4352c4eff07e6f397a7"
    end

    on_intel do
      url "https://github.com/Dicklesworthstone/eidetic_engine_cli/releases/download/v0.3.0/ee-x86_64-apple-darwin.tar.xz"
      sha256 "4b98cd6d6bb84ae8fc9ee2b24bbd69219159bd3a782c6dcb0892cedcfc422374"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Dicklesworthstone/eidetic_engine_cli/releases/download/v0.3.0/ee-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "a79900f6db673735e306b2ef462edec970c16cf65b6e5a624b8a619c008ec037"
    end

    on_intel do
      url "https://github.com/Dicklesworthstone/eidetic_engine_cli/releases/download/v0.3.0/ee-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "c210d6d7950792767609bf30f7beb5e0751d0ad4cc5ac8cf93f49aa385ce4577"
    end
  end

  def install
    bin.install "ee"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ee --version")
  end
end
