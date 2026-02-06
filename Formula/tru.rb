# typed: false
# frozen_string_literal: true

class Tru < Formula
  desc "TOON encoder/decoder - Token-Optimized Object Notation"
  homepage "https://github.com/Dicklesworthstone/toon_rust"
  version "0.1.1"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/tru-darwin-amd64.tar.xz"
      sha256 "12733939163d71ef321da2cd9924eb994d51d3000200415d3370f8a194b6c7b6"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/tru-darwin-arm64.tar.xz"
      sha256 "047394c0457e6a134bb1e953c91e39d1e4ec85996a8ddc9924332fce525d9d6c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/tru-linux-amd64.tar.xz"
      sha256 "a155e50383ca8388d3e84615776a70deb7ef6415f775879253cbcba6548dd5c9"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/tru-linux-arm64.tar.xz"
      sha256 "ff7b25b10358ad96eaa204632b746033a014cffb8b71352132e9768678457acf"
    end
  end

  def install
    bin.install "tru"
  end

  test do
    output = pipe_output("#{bin}/tru --encode", '{"test": true}')
    assert_match "test: true", output

    decoded = pipe_output("#{bin}/tru --decode", output)
    assert_match "\"test\"", decoded
  end
end
