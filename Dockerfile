FROM alpine:3.5
LABEL maintainer "f-teruhisa: teru_fukumoto@outlook.jp"

ENV PATH $PATH:/node_modules/.bin
RUN apk add --update --no-cache nodejs

RUN npm init --y

COPY package.json package-lock.json /
RUN npm install

RUN mkdir -p /post
