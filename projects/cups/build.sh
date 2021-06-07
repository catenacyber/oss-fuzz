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

function copy_lib
    {
    local fuzzer_path=$1
    local lib=$2
    cp $(ldd ${fuzzer_path} | grep "${lib}" | awk '{ print $3 }') ${OUT}/lib
    }

mkdir -p $OUT/lib

# build project
export LDFLAGS=$CXXFLAGS
./configure --with-dnssd=no --with-tls=no
make -j$(nproc)

$CC $CFLAGS -I. -Icups -c $SRC/fuzzippread.c -o fuzzippread.o
$CXX $CXXFLAGS fuzzippread.o -o fuzzippread \
    cups/libcups.a $LIB_FUZZING_ENGINE -lz

cp fuzzippread $OUT/
