class CodeTunnel < Formula
  desc "VS Code Remote Tunnel as a persistent brew service"
  homepage "https://code.visualstudio.com/docs/remote/tunnels"
  url "file:///dev/null"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  version "1.0.0"

  def install
    code_tunnel = "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code-tunnel"
    odie "VS Code not found at: #{code_tunnel}" unless File.exist?(code_tunnel)

    (bin/"code-tunnel-svc").write <<~BASH
      #!/bin/bash
      exec "#{code_tunnel}" tunnel --accept-server-license-terms "$@"
    BASH
    chmod 0755, bin/"code-tunnel-svc"
  end

  service do
    run [opt_bin/"code-tunnel-svc"]
    keep_alive true
    restart_delay 10
    log_path var/"log/code-tunnel.log"
    error_log_path var/"log/code-tunnel-error.log"
    working_dir Dir.home
    environment_variables HOME: Dir.home, PATH: "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
  end

  def caveats
    <<~EOS
      Manage the tunnel service:
        brew services start   magammon/code-tunnel/code-tunnel
        brew services stop    magammon/code-tunnel/code-tunnel
        brew services restart magammon/code-tunnel/code-tunnel

      View logs:
        tail -f #{var}/log/code-tunnel.log
        tail -f #{var}/log/code-tunnel-error.log
    EOS
  end
end
