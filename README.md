<h1 align="center">Welcome to blog-linter 👋</h1>
<p>
  <img alt="Version" src="https://img.shields.io/badge/version-1.0.0-blue.svg?cacheSeconds=2592000" />
  <a href="#" target="_blank">
    <img alt="License: ISC" src="https://img.shields.io/badge/License-ISC-yellow.svg" />
  </a>
  <a href="https://twitter.com/terry_i_" target="_blank">
    <img alt="Twitter: terry_i_" src="https://img.shields.io/twitter/follow/terry_i_.svg?style=social" />
  </a>
</p>

> This is npm textlint (and fix) service for articles with MarkDown. Run textlint in Docker container enviroment, so it doesn't have an unnecessary effect on your local environment.

## Install

```sh
$ git clone git@github.com:f-teruhisa/blog-linter.git
$ make init
```

## Usage
- You can check the grammar `/post/post.md` using textlint

```sh
make lint
```

- In addition, you can use `fix` command to automatically correct the text (as much as  possible)

```sh
make fix
```

## Author

👤 **f-teruhisa**

* Website: https://github.com/f-teruhisa/blog-linter
* Twitter: [@terry_i_](https://twitter.com/terry_i_)
* Github: [@f-teruhisa](https://github.com/f-teruhisa)

## Show your support

Give a ⭐️ if this project helped you!

***
_This README was generated with ❤️ by [readme-md-generator](https://github.com/kefranabg/readme-md-generator)_
