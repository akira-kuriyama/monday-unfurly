FROM ruby:2.7.8-alpine

ENV LANG C.UTF-8
ENV RACK_ENV production
ENV PORT 9292

WORKDIR /app
EXPOSE $PORT

COPY Gemfile* ./
RUN bundle install --jobs=4
COPY . .

CMD bundle exec rackup config.ru -p $PORT
