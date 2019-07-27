FROM ruby:2.6.3-alpine

ENV LANG C.UTF-8

WORKDIR /app
EXPOSE 4567

RUN gem update bundler
COPY Gemfile* ./
RUN bundle install --jobs=4
COPY . .

CMD bundle exec ruby main.rb -o 0.0.0.0
