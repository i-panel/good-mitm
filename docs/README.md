# Good Man in the Middle

[![GitHub stars](https://img.shields.io/github/stars/kontorol/good-mitm)](https://github.com/kontorol/good-mitm/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/kontorol/good-mitm)](https://github.com/kontorol/good-mitm/network)
[![GitHub issues](https://img.shields.io/github/issues/kontorol/good-mitm)](https://github.com/kontorol/good-mitm/issues)
[![Build](https://github.com/kontorol/good-mitm/actions/workflows/build-test.yml/badge.svg)](https://github.com/kontorol/good-mitm/actions/workflows/build-test.yml)
[![GitHub license](https://img.shields.io/github/license/kontorol/good-mitm)](https://github.com/kontorol/good-mitm/blob/master/LICENSE)

Using MITM technology to provide `rewrite`、`redirect`、`reject` and other functions

## Function

- Automatic certificate signing based on TLS ClientHello
- Support for Selective MITM
- Rule description language based on YAML format: rewrite/block/redirect
  - Flexible rule matchers
    - Domain name prefix/suffix/full match
    - Regex match
    - Multiple filter rules
  - Flexible text content rewriting
    - Erase/Replace
    - Regex replacement
  - Flexible dictionary type content rewriting
    - HTTP Header rewriting
    - Cookie rewriting
  - Support multiple actions for a single rule
- Supports JavaScript scripting rules (programming intervention)
- Support transparent proxy
- Transparent proxy HTTPS and HTTP reuse single port
- Support automatic installation of CA certificates to the system trusted zone
