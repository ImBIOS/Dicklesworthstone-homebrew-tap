# typed: false
# frozen_string_literal: true

class Dcg < Formula
  desc "Destructive Command Guard - Safety rails for AI coding agents"
  homepage "https://github.com/Dicklesworthstone/destructive_command_guard"
  version "0.4.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v0.3.0/dcg-aarch64-apple-darwin.tar.xz"
      sha256 "fc4524a954b1056a9edc6d0453fbf315d6a9ae8e3e23f6fb4ca51a725dcbc700"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/destructive_command_guard/releases/download/v0.3.0/dcg-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "1b189fd747a41e3cda4d6f4b8c444f036ce96da4031c4c4c6ff60afaee01fdc0"
    end
  end

  def install
    bin.install "dcg"
  end

  def caveats
    <<~EOS
      DCG (Destructive Command Guard) blocks dangerous commands from AI coding agents.

      Quick start:
        dcg test "rm -rf /"        # Test if a command would be blocked
        dcg explain "git push -f"  # See why a command is flagged
        dcg doctor                 # Verify installation

      To integrate with Claude Code, add to hooks:
        See: https://github.com/Dicklesworthstone/destructive_command_guard#integration
    EOS
  end

  test do
    system bin/"dcg", "--version"
  end
end
