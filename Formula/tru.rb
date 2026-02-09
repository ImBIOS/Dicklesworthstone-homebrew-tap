# typed: false
# frozen_string_literal: true

class Tru < Formula
  desc "TOON encoder/decoder - Token-Optimized Object Notation"
  homepage "https://github.com/Dicklesworthstone/toon_rust"
  version "0.1.2"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/toon-darwin-amd64.tar.xz"
      sha256 "12733939163d71ef321da2cd9924eb994d51d3000200415d3370f8a194b6c7b6"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/toon-darwin-arm64.tar.xz"
      sha256 "047394c0457e6a134bb1e953c91e39d1e4ec85996a8ddc9924332fce525d9d6c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/toon-linux-amd64.tar.xz"
      sha256 "95ebf53061d86c0a0cb2e4ad1e4227ced8a05975a4de72d8398e49062163ad70"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/toon_rust/releases/download/v#{version}/toon-linux-arm64.tar.xz"
      sha256 "ff7b25b10358ad96eaa204632b746033a014cffb8b71352132e9768678457acf"
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
