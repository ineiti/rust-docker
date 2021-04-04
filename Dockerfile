FROM lukemathwalker/cargo-chef as planner
WORKDIR /rust-docker
# We only pay the installation cost once, 
# it will be cached from the second build onwards
# To ensure a reproducible build consider pinning 
# the cargo-chef version with `--version X.X.X`
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM lukemathwalker/cargo-chef as cacher
WORKDIR /rust-docker
COPY --from=planner /rust-docker/recipe.json ./
RUN cargo chef cook --release -p one

FROM rust as builder
WORKDIR /rust-docker
COPY . .
# Copy over the cached dependencies
COPY --from=cacher /rust-docker/target/ target/
COPY --from=cacher /usr/local/cargo /usr/local/cargo
RUN cargo build --release -p one

FROM rust as runtime
WORKDIR /rust-docker
COPY --from=builder /rust-docker/target/release/one one
ENTRYPOINT ["/rust-docker/one"]