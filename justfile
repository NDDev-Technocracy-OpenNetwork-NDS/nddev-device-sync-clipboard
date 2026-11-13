set shell := ["bash", "-euo", "pipefail", "-c"]

setup:
    cargo fetch --locked
    bun install --frozen-lockfile --ignore-scripts

check: browser-check
    cargo fmt -- --check
    cargo deny --locked check licenses sources
    cargo shear --locked --deny-warnings

# Execution host or runner only, including generated JavaScript acceptance.
test:
    cargo clippy --locked --all-targets -- -D warnings
    cargo test --locked
    bun run check:generated

provider-check:
    cargo test --locked --test provider -- --ignored

browser-check:
    bun run check

wasm-check:
    rustup target add --toolchain 1.99.1 wasm32-unknown-unknown
    cargo clippy --locked --lib --target wasm32-unknown-unknown -- -D warnings

# The checks the former CI library ran from .github/nddev-ci.toml; CI calls them through
# `just test` on a pull request and `just verify` on dev.
ci-extras:
    cargo audit --deny warnings
    just browser-check
    bun run check:generated
    just wasm-check

ci-policy:
    cargo deny --locked check licenses sources

ci-build:
    cargo build --locked --workspace --release

verify:
    just check
    just test
    just ci-policy
    just ci-extras
    just ci-build
