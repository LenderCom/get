# get — LenderCom install scripts

Served via GitHub Pages at **https://get.sawrun.com/**.

## saw-agent

```sh
curl -fsSL https://get.sawrun.com/agent | sh
```

macOS users can also `brew install lendercom/tap/saw-agent`
([LenderCom/homebrew-tap](https://github.com/LenderCom/homebrew-tap)).

The [`agent`](agent) script:

- detects OS (macOS/Linux) and arch (amd64/arm64),
- downloads the pinned prebuilt binary from the public release on
  [LenderCom/homebrew-tap](https://github.com/LenderCom/homebrew-tap/releases)
  (versioned release-asset URLs — atomic, uncached, no rate-limited API calls),
- verifies its SHA-256 against the release's `SHA256SUMS`,
- installs to `/usr/local/bin` when writable, else `~/.local/bin` (with a PATH
  hint). Never invokes sudo — under `curl | sh`, a sudo password prompt would
  consume the piped script.

Overrides: `SAW_AGENT_VERSION=vX.Y.Z`, `SAW_INSTALL_DIR=/path`.

Note: downloading a release tarball with a *browser* (instead of curl/brew) sets
macOS's quarantine attribute on the extracted binary; use the script or brew, or
`xattr -d com.apple.quarantine saw-agent`.

## Releasing

When a new saw-agent version ships (see
[homebrew-tap/RELEASING.md](https://github.com/LenderCom/homebrew-tap/blob/main/RELEASING.md)),
bump `SAW_AGENT_VERSION` in [`agent`](agent).

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
