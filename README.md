# Ruby ODBC

This repo is based on [ruby-odbc](https://rubygems.org/gems/ruby-odbc) gem.

The original gem is no longer maintained and has known issues with modern Ruby versions and ODBC drivers. This repo aims to understand the codebase and in the future to provide a more modern and maintained alternative.

*NOTE: This is not production ready code. It is a playground to explore the Ruby C API.*

## Development

The repo contains a devcontainer setup with MySQL 8 to facilitate development. The development image install and configures the ODBC driver for MySQL.

## Building

```
bundle install
rake compile
```

## Running specs

```
rake spec
```

## Links
- https://github.com/flavorjones/ruby-c-extensions-explained
- https://silverhammermba.github.io/emberb/c/
- https://dev.to/juneira/creating-a-gem-using-ruby-c-api-4h5a

## Disclaimer

This code is based on the original ruby-odbc gem by Christian Werner [http://www.ch-werner.de/rubyodbc](http://www.ch-werner.de/rubyodbc).
