# mdeb [![Build Status][travis-image]][travis-url]

> Minimal Debian packaging

Without scripts and dependencies

## Install

```sh
npm install --global mdeb
```

## Usage

```sh
mdeb --help

  Minimal Debian packaging

  Usage
    mdeb <...files>

  Options
    --path, -p    Package installation path

  Examples
    mdeb foo.sh
    mdeb bar.sh --path /usr/local/share
```

## Dependencies

* `dpkg`
* `jq`

## License

MIT

[travis-url]: https://travis-ci.org/andrepolischuk/mdeb
[travis-image]: https://travis-ci.org/andrepolischuk/mdeb.svg?branch=master
