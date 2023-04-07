#!/bin/bash -eu
# Copyright 2019 Google Inc.
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

#patch
cp regexp/regexp.go /root/.go/src/regexp/

compile_go_fuzzer github.com/google/gonids FuzzParseRule fuzz_parserule
/root/.go/bin/go build -o fuzz.a -buildmode c-archive -gcflags all=-d=libfuzzer -trimpath -gcflags syscall=-d=libfuzzer=0 cfuzz.go
clang++ -fno-omit-frame-pointer -gline-tables-only -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION -fsanitize=address -fsanitize-address-use-after-scope -fsanitize=fuzzer-no-link -stdlib=libc++ -fsanitize=fuzzer fuzz.a -o fuzz_parse
cp fuzz_parse $OUT/fuzz_parse2

# use different GODEBUG env variables for https://github.com/golang/go/issues/49075
cp $SRC/gobughunt/fuzz_parserule.options $OUT/
