# typed: false
# frozen_string_literal: true

class Tru < Formula
  desc "TOON encoder/decoder - Token-Optimized Object Notation"
  homepage "https://github.com/Dicklesworthstone/toon_rust"
  url "https://github.com/Dicklesworthstone/toon_rust/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "0fdabd57e11d7edf40a99a5e6e9477ac53aed32d3f9778a0e8247a0be7c19b66"
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
