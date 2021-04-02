# Rust-Docker Chef Example

This is a simple example of a binary package depending on a library package:

- one: binary, depends on:
- two: library

The goal of this repo is twofold:
1. Check how to write a Dockerfile using `cargo chef` to speed up compilation
2. Learn how to use `cargo chef` with `wasm32-unknown-unknown` target

# Using wasm32 and rand

The current `Dockerfile` produces an error:

```
#19 5.801 error: target is not supported, for more information see: https://docs.rs/getrandom/#unsupported-targets
#19 5.801    --> /usr/local/cargo/registry/src/github.com-1ecc6299db9ec823/getrandom-0.2.2/src/lib.rs:213:9
#19 5.801     |
#19 5.801 213 | /         compile_error!("target is not supported, for more information see: \
#19 5.801 214 | |                         https://docs.rs/getrandom/#unsupported-targets");
#19 5.801     | |_________________________________________________________________________^
#19 5.801 
#19 5.819 error[E0433]: failed to resolve: use of undeclared crate or module `imp`
#19 5.819    --> /usr/local/cargo/registry/src/github.com-1ecc6299db9ec823/getrandom-0.2.2/src/lib.rs:235:5
#19 5.819     |
#19 5.819 235 |     imp::getrandom_inner(dest)
#19 5.819     |     ^^^ use of undeclared crate or module `imp`
#19 5.819 
#19 5.866 error: aborting due to 2 previous errors
```

But if you replace `rand` with `serde` in `one/Cargo.toml`, it works:

```bash
sed -i 's/rand/serde/' one/Cargo.toml
make
```

