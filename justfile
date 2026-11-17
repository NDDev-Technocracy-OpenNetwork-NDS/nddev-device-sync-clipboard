set shell := ["bash", "-euo", "pipefail", "-c"]

# Lists the commands.
default:
    @just --list

# Fetches locked source dependencies without compilation or package hooks.
setup:
    cargo fetch --locked
    bun install --frozen-lockfile --ignore-scripts

# Checks source formatting, browser types and frozen dependency policy offline.
check: browser-check
    just --fmt --check
    cargo fmt -- --check
    cargo deny --frozen check licenses sources
    cargo shear --locked --deny-warnings

# Execution host or runner only, including generated JavaScript acceptance.
test:
    cargo clippy --locked --all-targets -- -D warnings
    cargo test --locked
    bun run check:generated
    just wasm-check

provider-check:
    cargo test --locked --test provider -- --ignored

browser-check:
    bun run check

wasm-check:
    cargo clippy --locked --lib --target wasm32-unknown-unknown -- -D warnings

# The checks the former CI library ran from .github/nddev-ci.toml; CI calls them through
# `just test` on a pull request and `just verify` on dev.
ci-extras:
    cargo audit --deny warnings
    just browser-check
    bun run check:generated

ci-policy:
    cargo deny --locked check licenses sources

ci-build:
    cargo build --locked --workspace --release

# Runs complete source, native, wasm and release verification.
verify:
    just check
    just test
    just ci-policy
    just ci-extras
    just ci-build
