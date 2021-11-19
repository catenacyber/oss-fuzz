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

(
# Ignore memory leaks from python scripts invoked in the build
export ASAN_OPTIONS="detect_leaks=0"

CFLAGS=${CFLAGS//"-pthread"/}

FLAGS=()
case $SANITIZER in
  address)
    FLAGS+=("--with-address-sanitizer")
    ;;
  memory)
    FLAGS+=("--with-memory-sanitizer")
    # installing ensurepip takes a while with MSAN instrumentation, so
    # we disable it here
    FLAGS+=("--without-ensurepip")
    # -msan-keep-going is needed to allow MSAN's halt_on_error to function
    FLAGS+=("CFLAGS=-mllvm -msan-keep-going=1")
    ;;
  undefined)
    FLAGS+=("--with-undefined-behavior-sanitizer")
    ;;
esac

export CPYTHON_INSTALL_PATH=$SRC/cpython-install
rm -rf $CPYTHON_INSTALL_PATH
mkdir $CPYTHON_INSTALL_PATH

cd $SRC/cpython
cp $SRC/python-library-fuzzers/python_coverage.h Python/

# Patch the interpreter to record code coverage
sed -i '1 s/^.*$/#include "python_coverage.h"/g' Python/ceval.c
sed -i 's/case TARGET\(.*\): {/\0\nfuzzer_record_code_coverage(f->f_code, f->f_lasti);/g' Python/ceval.c

./configure "${FLAGS[@]:-}" --prefix=$CPYTHON_INSTALL_PATH
make -j$(nproc)
make install

cp -R $CPYTHON_INSTALL_PATH $OUT/
)
pip3 install numpy

python3 setup.py build install

# Build fuzzers in $OUT.
for fuzzer in $(find . -name 'fuzz_*.py'); do
  fuzzer_basename=$(basename -s .py $fuzzer)
  fuzzer_package=${fuzzer_basename}.pkg
  pyinstaller --distpath $OUT --onefile --name $fuzzer_package $fuzzer

  # Create execution wrapper.
  echo "#!/bin/sh
# LLVMFuzzerTestOneInput for fuzzer detection.
this_dir=\$(dirname \"\$0\")
ASAN_OPTIONS=\$ASAN_OPTIONS:symbolize=1:external_symbolizer_path=\$this_dir/llvm-symbolizer:detect_leaks=0 \
\$this_dir/$fuzzer_package \$@" > $OUT/$fuzzer_basename
  chmod +x $OUT/$fuzzer_basename
done
