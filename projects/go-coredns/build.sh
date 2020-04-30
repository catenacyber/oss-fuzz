#!/bin/bash -eu
# Copyright 2020 Google Inc.
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

# Same as usual except for added -tags gofuzz.
function compile_fuzzer {
  path=$1
  function=$2
  fuzzer=$3

  # Compile and instrument all Go files relevant to this fuzz target.
  go-fuzz-build -libfuzzer -tags gofuzz -func $function -o $fuzzer.a $path

  # Link Go code ($fuzzer.a) with fuzzing engine to produce fuzz target binary.
  $CXX $CXXFLAGS $LIB_FUZZING_ENGINE $fuzzer.a -o $OUT/$fuzzer
}

cd coredns
#make
ls plugin/*/fuzz.go | while read target
do
    fuzzed_plugin=`echo $target | cut -d'/' -f 2`
    compile_fuzzer ./plugin/$fuzzed_plugin Fuzz fuzz_plugin_$fuzzed_plugin
done

compile_fuzzer ./test Fuzz fuzz_core
