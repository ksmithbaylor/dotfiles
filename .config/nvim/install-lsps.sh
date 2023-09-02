#!/usr/bin/env zsh

set -e

go install golang.org/x/tools/gopls@latest
go install github.com/nametake/golangci-lint-langserver@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

yarn global add \
  typescript typescript-language-server \
  pyright \
  vscode-langservers-extracted \
  @microsoft/compose-language-service \
  dockerfile-language-server-nodejs \
  graphql-language-service-cli \
  @ignored/solidity-language-server

gem install \
  solargraph \
  rubocop
