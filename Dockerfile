FROM ruby:alpine

RUN apk add make gcc libc-dev libpq-dev

WORKDIR /app
ADD gems.rb gems.locked ./
RUN bundle

ADD *.rb ./
ADD index.html.erb ./
ADD config.ru ./

CMD ["puma", "-p", "8080"]
