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

FROM gcr.io/oss-fuzz-base/base-builder
MAINTAINER rlohningqt@gmail.com
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y build-essential libc6-dev:i386
RUN git clone --branch 5.15 --depth 1 git://code.qt.io/qt/qt5.git qt
WORKDIR qt
RUN git submodule update --init --depth 1 qtbase
WORKDIR $SRC
RUN git clone --depth 1 git://code.qt.io/qt/qtqa.git
RUN git clone --depth 1 https://github.com/google/AFL.git
COPY build.sh $SRC/
