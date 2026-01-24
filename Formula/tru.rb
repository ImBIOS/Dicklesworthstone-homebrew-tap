# typed: false
# frozen_string_literal: true

class Tru < Formula
  desc "TOON encoder/decoder - Token-Optimized Object Notation"
  homepage "https://github.com/Dicklesworthstone/toon_rust"
  url "https://github.com/Dicklesworthstone/toon_rust/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "08b6c166045886a6670baad0383511d5934e7ef1c6cb66bfa5492aa2f9be9d18"
  license "MIT"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "--release", "--bin", "tru"
    bin.install "target/release/tru"
  end

  def caveats
    <<~EOS
      The toon_rust CLI installs as `tru` to avoid conflicting with coreutils `tr`.
    EOS
  end

  test do
    output = pipe_output("#{bin}/tru --encode", '{"test": true}')
    assert_match "test: true", output

    decoded = pipe_output("#{bin}/tru --decode", output)
    assert_match "\"test\"", decoded
  end
end
