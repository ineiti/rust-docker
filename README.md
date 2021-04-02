# Rust-Docker Chef Example

This is a simple example of a binary package depending on a library package:

- one: binary, depends on:
- two: library

The goal of this repo is twofold:
1. Check how to write a Dockerfile using `cargo chef` to speed up compilation
2. Learn how to use `cargo chef` with `wasm32-unknown-unknown` target

# Using wasm32 with cargo chef

On my first compilation of a wasm32 project using `cargo chef cook`, I got the followng
error:

```
error[E0463]: can't find crate for `std`
  |
  = note: the `wasm32-unknown-unknown` target may not be installed

error: aborting due to previous error

For more information about this error, try `rustc --explain E0463`.
error: could not compile `urlencoding`
```

Turns out you have to first install the wasm32 target by adding the following
before the first call to `cargo chef cook`:

```
RUN rustup target add wasm32-unknown-unknown
```