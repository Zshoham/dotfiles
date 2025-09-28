#!/bin/sh

export CARGO_HOME="${XDG_DATA_HOME}/cargo/"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup/"
curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -c rust-analyzer -y
