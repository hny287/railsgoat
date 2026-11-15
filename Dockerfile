FROM --platform=linux/amd64 ruby:3.4.1
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential libpq-dev nodejs
RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler
RUN bundle install
ADD . /myapp
RUN useradd -m app && chown -R app /myapp
USER app
