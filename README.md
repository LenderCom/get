# get — LenderCom install scripts

Served via GitHub Pages at **https://lendercom.github.io/get/**.

## saw-agent

```sh
curl -fsSL https://lendercom.github.io/get/agent | sh
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

## Follow-up: branded domain

The SAW infrastructure domain is `sawrun.com` (owner decision 2026-07-17; DNS on
Cloudflare — the original `get.saw.dev` string shipped in the UI referenced a
domain LenderCom does not own). To serve this site as `https://get.sawrun.com/agent`:

1. Cloudflare (sawrun.com zone): `CNAME get -> lendercom.github.io.` (DNS-only /
   unproxied, so GitHub Pages can issue the certificate).
2. This repo → Settings → Pages → Custom domain: `get.sawrun.com` (creates the
   `CNAME` file), wait for the cert, enable "Enforce HTTPS".
3. Update the install command in `saw-ui`
   (`src/features/remote-agents/PairingGuide/PairingGuide.tsx`) and this README
   to the new URL. The old `lendercom.github.io/get/...` URL keeps working (GitHub
   redirects project pages to the custom domain).
