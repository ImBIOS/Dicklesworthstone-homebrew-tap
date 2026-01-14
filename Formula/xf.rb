# xf (X-Former) - Homebrew formula
# Search and analyze your Twitter/X archive data

class Xf < Formula
  desc "Search and analyze your Twitter/X archive data"
  homepage "https://github.com/Dicklesworthstone/xf"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/Dicklesworthstone/xf/releases/download/v#{version}/xf-x86_64-apple-darwin.tar.gz"
      sha256 "c85c11d4be13fdda3588aeb6d9d5ff62aac150c60e9f1253c2c710882e05b2ce"
    end
    on_arm do
      url "https://github.com/Dicklesworthstone/xf/releases/download/v#{version}/xf-aarch64-apple-darwin.tar.gz"
      sha256 "e90a04cb49e0910766b573d41338779ca22a6c29076a211eaa7148b637eb1674"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Dicklesworthstone/xf/releases/download/v#{version}/xf-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e8de166f4464ec46ae6b38d89194e5312f0cce06ae5398df48527d26d5bbe299"
    end
    # NOTE: Linux ARM builds not currently available
  end

  def install
    bin.install "xf"

    # Generate shell completions using built-in support
    generate_completions_from_executable(bin/"xf", "completions")
  end

  def caveats
    <<~EOS
      xf searches and analyzes your Twitter/X archive data.

      Setup:
        1. Download your Twitter data archive from Twitter settings
        2. Extract the archive to a directory
        3. Point xf to it: xf --data-dir /path/to/twitter-archive

      Quick start:
        xf search "keyword"         # Search your tweets
        xf stats                    # Show archive statistics
        xf search "topic" --limit 5 # Limit results
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin/"xf"} --version")
    assert_match "search", shell_output("#{bin/"xf"} --help")
  end
end
