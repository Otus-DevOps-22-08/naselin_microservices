FROM alpine:3.9

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
RUN apk --no-cache --update add \
        build-base \
        ruby-dev \
        ruby-full \
    && gem install bundler:1.17.2 --no-document \
    && bundle install \
    && apk del \
        build-base \
        ruby-dev

COPY . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
