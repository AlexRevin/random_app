FROM ruby:2.3.8
RUN echo "deb http://archive.debian.org/debian stretch main\ndeb-src http://archive.debian.org/debian stretch main" > /etc/apt/sources.list
RUN apt-get update
RUN curl -fsSL https://deb.nodesource.com/setup_16.x |  bash -
RUN apt-get install -y nodejs
WORKDIR /app
COPY . .
RUN bundle
CMD bash -c "bundle exec rspec"
