FROM node:slim
LABEL maintainer "f-teruhisa: teru_fukumoto@outlook.jp"

ENV PATH $PATH:/node_modules/.bin

RUN npm init --y

COPY package.json package-lock.json /
RUN npm install

RUN mkdir -p /post \
    /textlint

WORKDIR /textlint

ENTRYPOINT ["textlint"]