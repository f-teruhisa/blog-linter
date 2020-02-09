FROM alpine:3.5

LABEL maintainer "f-teruhisa: teru_fukumoto@outlook.jp"

RUN set -x \
  && apk add --update --no-cache build-base nodejs

RUN npm init --yes

RUN npm install --save-dev \
  textlint \
  textlint-rule-preset-ja-spacing \
  textlint-rule-preset-ja-technical-writing \
  textlint-rule-spellcheck-tech-word \
  @textlint-ja/textlint-rule-no-insert-dropping-sa \
  textlint-filter-rule-whitelist \
  textlint-rule-ja-hiragana-fukushi \
  textlint-rule-ja-hiragana-hojodoushi \
  textlint-rule-ja-no-redundant-expression \
  textlint-rule-ja-unnatural-alphabet \
  textlint-rule-joyo-kanji \
  textlint-rule-no-dead-link \
  textlint-rule-no-renyo-chushi \
  textlint-rule-one-white-space-between-zenkaku-and-hankaku-eiji

RUN mkdir -p /inter\
  /post

WORKDIR /linter

RUN echo  'docker build is completed'
