class DockerLocalHostname < Formula
  desc "Reach Docker Compose projects by local hostname on macOS (tunnel + /etc/hosts)"
  homepage "https://github.com/asmgit/docker-local-hostname"
  url "https://github.com/asmgit/docker-local-hostname/archive/refs/tags/v0.1.7.tar.gz"
  sha256 "5c45acea8d2077407288b3ddcda6f59dc826ada521f34b8ad8364db0616984ee"
  license "MIT"

  depends_on "go" => :build
  depends_on :macos

  def install
    proj = "github.com/asmgit/docker-local-hostname"
    ldflags = %W[
      -s -w
      -X #{proj}/version.Version=v0.1.7
      -X #{proj}/version.SetupImage=ghcr.io/chipmk/docker-mac-net-connect/setup
    ].join(" ")
    system "go", "build", *std_go_args(ldflags: ldflags), "."
  end

  service do
    run [opt_bin/"docker-local-hostname"]
    keep_alive true
    require_root true
    environment_variables DOCKER_LOCAL_HOSTNAME_DOMAIN: ".ldev"
    log_path var/"log/docker-local-hostname.log"
    error_log_path var/"log/docker-local-hostname.log"
  end

  def caveats
    <<~EOS
      docker-local-hostname needs root (it creates the WireGuard tunnel and edits
      /etc/hosts). Start it with:

        sudo brew services start asmgit/tap/docker-local-hostname

      It INCLUDES the docker-mac-net-connect tunnel, so do not run both. If the
      upstream tunnel is running, stop it first:

        sudo brew services stop chipmk/tap/docker-mac-net-connect

      Then give a Compose service a `hostname: myapp.ldev` (and publish no host
      ports) and reach it from the Mac at http://myapp.ldev. Change the domain via
      the DOCKER_LOCAL_HOSTNAME_DOMAIN environment variable.
    EOS
  end

  test do
    assert_path_exists bin/"docker-local-hostname"
  end
end
