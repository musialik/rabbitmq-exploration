FROM ruby:2.3.3
RUN apt-get update -qq

# yarn

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get install -y nodejs
RUN apt-get update && apt-get install -y yarn

# rest

WORKDIR /usr/app

COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install

COPY package.json .
COPY yarn.lock .
RUN yarn --silent

COPY . .
