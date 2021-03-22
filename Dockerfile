FROM elixir:1.11.4

EXPOSE 80

ARG PORT=${PORT}
ARG SECRET_KEY_BASE=${SECRET_KEY_BASE}
ARG MIX_ENV=${MIX_ENV}

ENV PORT=${PORT} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    MIX_ENV=${MIX_ENV}

#RUN usermod -u 1000 root
#USER www-data

RUN mkdir -p /var/www

COPY  ./config /var/www/config/
COPY  ./mix.* /var/www/

WORKDIR /var/www/

RUN rm -Rf _build && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod && \
    mix deps.compile

COPY  ./ /var/www/

RUN mix phx.digest
RUN mix release prod

CMD ["_build/prod/rel/prod/bin/prod", "start"]
