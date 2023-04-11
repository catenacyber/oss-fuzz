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

# fails early
compile_go_fuzzer github.com/google/gonids FuzzParseRule fuzz_fail

# fails 15 hours later
/root/.go/bin/go build -o fuzz.a -buildmode c-archive -gcflags all=-d=libfuzzer -tags gofuzz,gofuzz_libfuzzer,libfuzzer -trimpath -gcflags syscall=-d=libfuzzer=0 cfuzz.go
clang++ -O1 -fno-omit-frame-pointer -gline-tables-only -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION -fsanitize=address -fsanitize-address-use-after-scope -fsanitize=fuzzer-no-link -stdlib=libc++ -fsanitize=fuzzer fuzz.a -o $OUT/fuzz_steps

# Testing
clang++ -stdlib=libc++ -fsanitize=fuzzer fuzz.a -o $OUT/fuzz_basic
clang++ -fsanitize=address -fsanitize-address-use-after-scope -fsanitize=fuzzer-no-link -stdlib=libc++ -fsanitize=fuzzer fuzz.a -o $OUT/fuzz_libfuzz

/root/.go/bin/go build -o fuzzgo.a -buildmode c-archive cfuzz.go
clang++ -O1 -fno-omit-frame-pointer -gline-tables-only -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION -fsanitize=address -fsanitize-address-use-after-scope -fsanitize=fuzzer-no-link -stdlib=libc++ -fsanitize=fuzzer fuzzgo.a -o $OUT/fuzz_go


sed -i -e 's/go l/l/' lex.go
# fails early 14 more hours later
compile_go_fuzzer github.com/google/gonids FuzzParseRule fuzz_nogo


# use different GODEBUG env variables for https://github.com/golang/go/issues/49075
cp $SRC/gobughunt/fuzz_parserule.options $OUT/
