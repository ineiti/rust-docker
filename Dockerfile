FROM rust as planner
WORKDIR /rust-docker
# We only pay the installation cost once, 
# it will be cached from the second build onwards
# To ensure a reproducible build consider pinning 
# the cargo-chef version with `--version X.X.X`
RUN cargo install cargo-chef 
COPY . .
RUN cd one; cargo chef prepare --recipe-path recipe.json
RUN cd two; cargo chef prepare --recipe-path recipe.json

FROM rust as cacher
WORKDIR /rust-docker
RUN cargo install cargo-chef
COPY --from=planner /rust-docker/one/recipe.json one/
COPY --from=planner /rust-docker/two/recipe.json two/
RUN cd two; cargo chef cook --release --recipe-path recipe.json
RUN cd one; cargo chef cook --release --recipe-path recipe.json

FROM rust as builder
WORKDIR /rust-docker
COPY . .
# Copy over the cached dependencies
COPY --from=cacher /rust-docker/one/target one/target
COPY --from=cacher /rust-docker/two/target two/target
COPY --from=cacher /usr/local/cargo /usr/local/cargo
RUN cd one; cargo build --release

FROM rust as runtime
WORKDIR /rust-docker
COPY --from=builder /rust-docker/one/target/release/one one
ENTRYPOINT ["/rust-docker/one"]