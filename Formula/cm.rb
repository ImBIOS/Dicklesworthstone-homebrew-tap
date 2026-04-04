# CM (CASS Memory System) - Homebrew formula
# Persistent memory system for AI coding agents using vector embeddings

class Cm < Formula
  desc "Persistent memory system for AI coding agents using vector embeddings"
  homepage "https://github.com/Dicklesworthstone/cass_memory_system"
  version "0.2.4"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/Dicklesworthstone/cass_memory_system/releases/download/v#{version}/cass-memory-macos-x64"
      sha256 "bf05519308597875110c33d5aa84b3b00563ea440afe255c6c88f8daa304dd57"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/cass_memory_system/releases/download/v#{version}/cass-memory-macos-arm64"
      sha256 "2c0c3ddabab5daf2ec560796088fe285499b9a366303c3be3c9db3ecebe56eb5"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/cass_memory_system/releases/download/v#{version}/cass-memory-linux-x64"
      sha256 "85effb160ba451ce98ac2565c287f3c17ff82b6768e71017d346ebce6e434543"
    end
    # NOTE: Linux ARM builds not currently available
  end

  def install
    # The release binary is a single file, rename it during install
    if OS.mac? && Hardware::CPU.intel?
      bin.install "cass-memory-macos-x64" => "cm"
    elsif OS.mac? && Hardware::CPU.arm?
      bin.install "cass-memory-macos-arm64" => "cm"
    else
      bin.install "cass-memory-linux-x64" => "cm"
    end
  end

  def caveats
    <<~EOS
      CM (CASS Memory System) provides persistent vector-based memory for AI agents.

      Quick start:
        cm --help                # Show all commands
        cm status                # Check system status
        cm store "fact"          # Store a memory

      The memory database is stored in ~/.cass_memory/
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin/"cm"} --version")
  end
end
