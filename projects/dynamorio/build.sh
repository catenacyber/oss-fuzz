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
git apply ../patch.diff
mkdir build && cd build
# ugly hack as some file named core gets created
cmake -DBUILD_SHARED_LIBS=OFF -DBUILD_DRSTATS=OFF -DBUILD_TOOLS=OFF -DBUILD_SAMPLES=OFF .. || { rm core && cmake -DBUILD_SHARED_LIBS=OFF -DBUILD_DRSTATS=OFF -DBUILD_TOOLS=OFF -DBUILD_SAMPLES=OFF ..; }
make -j$(nproc)

cp bin/fuzz* $OUT/
