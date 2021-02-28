#!/bin/bash -eu
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# build project
export ASAN_OPTIONS=detect_leaks=0
go mod init github.com/apache/thrift

./bootstrap.sh
./configure
make -j$(nproc)
make install
(cd lib/go/thrift && go mod init github.com/apache/thrift/lib/go/thrift)

mkdir fuzzgo
cd fuzzgo
thrift -r --gen go ../tutorial/tutorial.thrift
cp $SRC/fuzz.go .
go mod init thriftfuzz
(cd ./gen-go/shared && go mod init shared)
go mod edit -replace shared=./gen-go/shared
(cd ./gen-go/tutorial && go mod init tutorial)
go mod edit -replace tutorial=./gen-go/tutorial
go mod edit -replace github.com/apache/thrift/lib/go/thrift=../lib/go/thrift
compile_go_fuzzer . Fuzz fuzz_go_tutorial
