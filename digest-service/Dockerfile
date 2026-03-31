ARG RUBY_IMAGE_TAG
FROM ruby:${RUBY_IMAGE_TAG}

WORKDIR /app

RUN gem update --system --no-document && gem install -N bundler

COPY Gemfile Gemfile

RUN bundle install

RUN useradd ruby --home /app --shell /bin/bash
USER ruby:ruby

COPY --chown=ruby:ruby digest.rb digest.rb
COPY --chown=ruby:ruby lib lib
COPY --chown=ruby:ruby hostignore.yml hostignore.yml

CMD ["ruby", "digest.rb"]
