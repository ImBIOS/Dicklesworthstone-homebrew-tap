# typed: false
# frozen_string_literal: true

class Tru < Formula
  desc "TOON encoder/decoder - Token-Optimized Object Notation"
  homepage "https://github.com/Dicklesworthstone/toon_rust"
  version "0.2.3"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/toon-darwin-amd64.tar.xz"
      sha256 "Not"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/toon-darwin-arm64.tar.xz"
      sha256 "Not"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/toon-linux-amd64.tar.xz"
      sha256 "Not"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/toon-linux-arm64.tar.xz"
      sha256 "Not"
    end
  end

  def install
    bin.install "toon"
  end

  test do
    output = pipe_output("#{bin}/toon --encode", '{"test": true}')
    assert_match "test: true", output

    decoded = pipe_output("#{bin}/toon --decode", output)
    assert_match "\"test\"", decoded
  end
end
