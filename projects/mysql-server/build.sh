
#!/bin/bash -eu
# Copyright 2018 Google Inc.
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

rm -f -r $OUT/*

cd mysql-server
git branch -f fuzzing
git checkout fuzzing
git pull origin fuzzing


sed -i -e "s/ADD_SUBDIRECTORY(r/#ADD_SUBDIRECTORY(r/g" ./CMakeLists.txt
# build project
rm -r ./components/test/perfschema/
mkdir build
cd build
cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=$WORK -DWITH_SSL=system -DDISABLE_SHARED=1 -DFUZZING=1 #Il y a aussi DWITHOUT_SERVER à considérer...
#make clean
#make -j$(nproc)
make GenError -j$(nproc)
make validate_password_fuzz

# build fuzz targets
#TODO

#TODO corpus, options

#cp ./* $OUT

cp $SRC/mysql-server/build/bin/validate_password_fuzz $OUT
