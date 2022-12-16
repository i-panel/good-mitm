# Good Man in the Middle

[![GitHub stars](https://img.shields.io/github/stars/kontorol/good-mitm',)](https://github.com/kontorol/good-mitm',/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/kontorol/good-mitm',)](https://github.com/kontorol/good-mitm',/network)
[![Release](https://img.shields.io/github/release/kontorol/good-mitm',)](https://github.com/kontorol/good-mitm',/releases)
[![GitHub issues](https://img.shields.io/github/issues/kontorol/good-mitm',)](https://github.com/kontorol/good-mitm',/issues)
[![Build](https://github.com/kontorol/good-mitm',/actions/workflows/build-test.yml/badge.svg)](https://github.com/kontorol/good-mitm',/actions/workflows/build-test.yml)
[![GitHub license](https://img.shields.io/github/license/kontorol/good-mitm',)](https://github.com/kontorol/good-mitm',/blob/master/LICENSE)
[![Docs](https://img.shields.io/badge/docs-read-blue.svg?style=flat)](https://docs.mitm.plus)

Use `MITM` technology to realize operations such as `rewriting`, `redirecting`, and `blocking` of requests and returns

## Instructions

Only the most basic usage process is introduced here, please refer to [documentation] for specific usage methods and rules(https://docs.mitm.plus)

### certificate preparation

Due to `MITM` technology, you need to generate and trust your own root certificate

#### generate root certificate

For security reasons, please do not trust any root certificate provided by strangers, you need to generate your own root certificate and private key

```shell
video-mitm.exe genca
```

The above command will generate the private key and certificate, and the files will be stored in the `ca` folder

#### trust certificate

You can add the root certificate to the trusted zone of the operating system or browser, and choose according to your needs

### Run

Start Video-MITM, specify the rule file or directory to use

```shell
video-mitm.exe run -r rules
```

Use the http proxy provided by Video-MITM in the browser or operating system：`http://127.0.0.1:34567`

## License

**Video-MITM** © [zu1k](https://github.com/zu1k), Released under the [MIT](./LICENSE) License.<br>

> Blog [zu1k.com](https://zu1k.com) · GitHub [@zu1k](https://github.com/zu1k) · Twitter [@zu1k_lv](https://twitter.com/zu1k_lv) · Telegram Channel [@peekfun](https://t.me/peekfun)