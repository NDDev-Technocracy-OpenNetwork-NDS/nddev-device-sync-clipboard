set shell := ["bash", "-euo", "pipefail", "-c"]

check: browser-check
    cargo fmt -- --check
    cargo clippy --locked --all-targets -- -D warnings
    cargo test --locked

provider-check:
    cargo test --locked --test provider -- --ignored

browser-check:
    bun install --frozen-lockfile --ignore-scripts
    bun run check
    bun run check:generated
