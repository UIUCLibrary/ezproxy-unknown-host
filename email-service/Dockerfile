FROM ruby:3.3 AS base
#ARG RUBY_VERSION=3.1.2
#FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /app


RUN gem update --system --no-document && gem install -N bundler

FROM base AS build

COPY Gemfile Gemfile

RUN bundle install


FROM base

RUN useradd ruby --home /app --shell /bin/bash
USER ruby:ruby

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=ruby:ruby /app /app

# note - we may just end up copyying . . 
COPY --chown=ruby:ruby config.ru config.ru

ENV RACK_ENV=production

ARG EZPROXY_EMAIL_TARGETS
ENV EZPROXY_EMAIL_TARGETS=${EZPROXY_EMAIL_TARGETS}

ARG EZPROXY_EMAIL_RELAY
ENV EZPROXY_EMAIL_RELAY=${EZPROXY_EMAIL_RELAY}


ARG EZPROXY_EMAIL_SENDER
ENV EZPROXY_EMAIL_SENDER=${EZPROXY_EMAIL_SENDER}

ARG EZPROXY_CORS_ORIGINS
ENV EZPROXY_CORS_ORIGINS=${EZPROXY_CORS_ORIGINS}

EXPOSE 9292

CMD ["bundle","exec","rackup"]