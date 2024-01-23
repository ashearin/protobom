#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

source hack/common.sh

# These two are pinned to the versions used in the latest generated code
export PROTOC_VER="24.4"
export PROTOC_GO_VER="v1.31.0"

# Last tagged release v1.1.2 was August 2022, `go install` will resolve ref and pin version
export PROTOC_GORM_VER="main"

curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VER}/protoc-${PROTOC_VER}-linux-x86_64.zip
unzip protoc-${PROTOC_VER}-linux-x86_64.zip -d $HOME/.local
go install google.golang.org/protobuf/cmd/protoc-gen-go@${PROTOC_GO_VER}
go install github.com/infobloxopen/protoc-gen-gorm@${PROTOC_GORM_VER}
curl -LO https://raw.githubusercontent.com/infobloxopen/protoc-gen-gorm/main/proto/options/gorm.proto

$HOME/.local/bin/protoc --proto_path=$HOME/.local/include --proto_path=. --go_out=pkg --gorm_out=pkg ./api/sbom.proto

git diff --exit-code || exit_with_msg "The protobuf definitions are not up to date. Check the docs and run make proto"
