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

wasm-check:
    rustup target add --toolchain 1.99.1 wasm32-unknown-unknown
    cargo clippy --locked --lib --target wasm32-unknown-unknown -- -D warnings
