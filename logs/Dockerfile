FROM elixir:1.7.4-alpine

WORKDIR /usr/app

COPY mix.lock .
COPY mix.exs .
COPY deps .

RUN yes | mix local.hex
RUN yes | mix deps.get --quiet

COPY . .
