set shell := ["bash", "-euo", "pipefail", "-c"]

setup:
    cargo fetch --locked
    bun install --frozen-lockfile --ignore-scripts

check: browser-check
    just --fmt --check
    cargo fmt -- --check
    cargo deny --locked check licenses sources
    cargo shear --locked --deny-warnings

# Execution host or runner only, including generated JavaScript acceptance.
test: build audit wasm-check
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

# List the project commands.
default:
    @just --list

# Compile the locked release workspace.
build:
    cargo build --locked --workspace --release

# Check current RustSec advisories.
audit:
    cargo audit --deny warnings

# Run source checks, native tests and the advisory audit.
verify: check test audit build
