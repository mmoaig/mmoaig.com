FROM elixir:1.16.0

ARG PHOENIX_VERSION=1.7.10

RUN apt update \
  && apt upgrade -y \ 
  && apt install -y git build-essential inotify-tools

# Phoenix
RUN mix local.hex --force
RUN mix archive.install --force hex phx_new ${PHOENIX_VERSION}
RUN mix local.rebar --force