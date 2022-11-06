#!/bin/bash -eu
# Copyright 2016 Google Inc.
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

CONFIGURE_FLAGS=""
if [[ $CFLAGS = *sanitize=memory* ]]
then
  CONFIGURE_FLAGS="no-asm"
fi

./config --debug enable-fuzz-libfuzzer -DPEDANTIC -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION no-shared enable-tls1_3 enable-rc5 enable-md2 enable-ec_nistp_64_gcc_128 enable-ssl3 enable-ssl3-method enable-nextprotoneg enable-weak-ssl-ciphers --with-fuzzer-lib=/usr/lib/libFuzzingEngine $CFLAGS -fno-sanitize=alignment $CONFIGURE_FLAGS

make -j$(nproc) LDCMD="$CXX $CXXFLAGS"

fuzzers=$(find fuzz -executable -type f '!' -name \*.py '!' -name \*-test '!' -name \*.pl '!' -name \*.sh)
for f in $fuzzers; do
	fuzzer=$(basename $f)
	cp $f $OUT/
	zip -j $OUT/${fuzzer}_seed_corpus.zip fuzz/corpora/${fuzzer}/*
done

cp $SRC/*.options $OUT/
cp fuzz/oids.txt $OUT/asn1.dict
cp fuzz/oids.txt $OUT/x509.dict

(
cd $SRC/aware
mkdir genfiles
# TODO not sure proto_path or -I
$SRC/LPM/external.protobuf/bin/protoc $SRC/aware/DaSSLFuzzInputToServer.proto --cpp_out=genfiles --proto_path=$SRC/aware/
$CXX $CXXFLAGS -c -I genfiles/ -I $SRC/LPM/external.protobuf/include genfiles/DaSSLFuzzInputToServer.pb.cc
$CXX $CXXFLAGS -c -I. -I $SRC/libprotobuf-mutator/ -I $SRC/LPM/external.protobuf/include serializer.cc
$CXX $CXXFLAGS -c -I. -I $SRC/libprotobuf-mutator/ -I $SRC/LPM/external.protobuf/include toServer.cc

# TODO check openssl path to static lib + other libs needed (libcrypto.a ?)
$CXX $CXXFLAGS $LIB_FUZZING_ENGINE DaSSLFuzzInputToServer.pb.o serializer.o toServer.o $SRC/openssl/libssl.a $SRC/LPM/src/libfuzzer/libprotobuf-mutator-libfuzzer.a $SRC/LPM/src/libprotobuf-mutator.a $SRC/LPM/external.protobuf/lib/libprotobuf.a -o $OUT/fuzz_lpm
)
