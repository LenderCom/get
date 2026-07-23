# get — LenderCom install scripts

Served via GitHub Pages at **https://get.sawrun.com/**.

## saw-agent

```sh
curl -fsSL https://get.sawrun.com/agent | sh -s -- --channel stable
```

Track the dev channel instead with `--channel dev` (or `SAW_CLOUD_CHANNEL=dev`
if you'd rather set it once for CI/config-management). Channel defaults to
`stable`.

macOS users can also `brew install lendercom/tap/saw-agent`
([LenderCom/homebrew-tap](https://github.com/LenderCom/homebrew-tap)).

The [`agent`](agent) script:

- detects OS (macOS/Linux) and arch (amd64/arm64),
- downloads the release manifest from the public
  [LenderCom/saw-agent-releases](https://github.com/LenderCom/saw-agent-releases)
  and verifies its minisign signature against an embedded public key **before
  trusting anything in it** — a signature check failure is a hard install
  failure, by design (see the comments at the top of `agent` for why the
  manifest's own signed sha256, not the unsigned `SHA256SUMS` file, is the
  authoritative checksum),
- installs the verified binary to `~/.saw/bin/saw-agent`,
- installs and starts a launchd (macOS) / `systemd --user` (Linux) unit with
  `Restart=always` and no start-limit — crash-loop handling lives in the
  agent's own self-update engine, not the service manager,
- warns (does not by default refuse — set `SAW_INSTALL_REQUIRE_STOPPED=1` to
  make it a hard failure) if a saw-agent is already running on the host,
- writes the chosen channel to `~/.saw/cloud/channel`.

Requires `minisign` on the machine running the install (`brew install
minisign` on macOS; `apt`/`dnf`/`pacman install minisign` on Linux) — the
script refuses to install without it rather than skip signature verification.

Overrides (environment variables): `SAW_INSTALL_DIR`, `SAW_SKIP_SERVICE=1`,
`SAW_AGENT_TAG_DEV=<tag>` / `SAW_AGENT_TAG_STABLE=<tag>` (pin an exact
release tag instead of the script's built-in default).

Run `./agent --dry-run [--channel dev|stable]` to self-test the install logic
(manifest parsing, signature verification round-trip, checksum verification,
host-lock detection, service-unit generation) against a throwaway, self-signed
fixture — no network access and no writes outside a temp directory. This is
what CI runs on both macOS and Linux.

Note: downloading a release tarball with a *browser* (instead of curl/brew) sets
macOS's quarantine attribute on the extracted binary; use the script or brew, or
`xattr -d com.apple.quarantine saw-agent`.

## Releasing

saw-agent releases are published to
[LenderCom/saw-agent-releases](https://github.com/LenderCom/saw-agent-releases)
(dev channel: prerelease tags off `main`; stable channel: `v*` tags) — see
`plan/saw-agent-auto-update-plan.md` §2.7 in `LenderCom/saw-docs`. The pinned
tag constants in [`agent`](agent) (`SAW_AGENT_TAG_DEV` / `SAW_AGENT_TAG_STABLE`)
are bumped by the release pipeline's automated formula/get-bump step once it
lands; until then, bump them by hand alongside a release.

## Branded domain

Served as `https://get.sawrun.com/` — `sawrun.com` is the SAW infrastructure
domain (owner decision 2026-07-17; the original `get.saw.dev` string shipped in
the UI referenced a domain LenderCom does not own). Wiring (live since
2026-07-21, DEV-5921):

- Cloudflare (sawrun.com zone): unproxied `CNAME get -> lendercom.github.io`
  (unproxied so GitHub Pages could issue/renew the certificate); codified in
  `saw-infrastructure` (`environments/dev/main.get-install.tf`).
- This repo's GitHub Pages custom domain: `get.sawrun.com` (the committed
  `CNAME` file), HTTPS enforced.
- The old `https://lendercom.github.io/get/...` URLs keep working — GitHub
  301-redirects project pages to the custom domain.
