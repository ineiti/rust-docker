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
RUN rustup target add wasm32-unknown-unknown
COPY --from=planner /rust-docker/one/recipe.json one/
COPY --from=planner /rust-docker/two/recipe.json two/
RUN cd two; cargo chef cook --target wasm32-unknown-unknown --release --recipe-path recipe.json 
RUN cd one; cargo chef cook --target wasm32-unknown-unknown --release --recipe-path recipe.json

FROM rust as builder
WORKDIR /rust-docker
RUN curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
COPY . .
# Copy over the cached dependencies
COPY --from=cacher /rust-docker/one/target one/target
COPY --from=cacher /rust-docker/two/target two/target
COPY --from=cacher /usr/local/cargo /usr/local/cargo
RUN cd one; wasm-pack build --release --target web --out-name one --out-dir ./static

FROM joseluisq/static-web-server
COPY --from=builder /rust-docker/one/static/ /var/www/
ENV SERVER_NAME=one
ENV SERVER_ROOT=/var/www
