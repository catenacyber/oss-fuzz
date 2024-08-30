/*
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
*/

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <memory>

#include "codec_def.h"
#include "codec_app_def.h"
#include "codec_api.h"
#include "read_config.h"
#include "typedefs.h"
#include "measure_time.h"

/*
 * To build locally:
 * CC=clang CXX=clang++ CFLAGS="-fsanitize=address,fuzzer-no-link -g" CXXFLAGS="-fsanitize=address,fuzzer-no-link -g" LDFLAGS="-fsanitize=address,fuzzer-no-link" make -j$(nproc) USE_ASM=No BUILDTYPE=Debug libraries
 * clang++ -o decoder_fuzzer -fsanitize=address -g -O1 -I./codec/api/wels -I./codec/console/common/inc -I./codec/common/inc -L. -lFuzzer -lstdc++ decoder_fuzzer.cpp libopenh264.a
 */

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
  int iLevelSetting = (int) WELS_LOG_QUIET; // disable logging while fuzzing

  if (size < 8) {
    return 0;
  }
  ISVCEncoder *pEncoder;
  int rv = WelsCreateSVCEncoder (&pEncoder);
  if (rv != 0 || pEncoder == NULL) {
    return 0;
  }

  SEncParamBase param;
    memset (&param, 0, sizeof (SEncParamBase));
    if (data[0] & 1) {
        param.iUsageType = SCREEN_CONTENT_REAL_TIME;
    } else {
        param.iUsageType = CAMERA_VIDEO_REAL_TIME;
    }
  param.fMaxFrameRate = 1<<(data[1] & 0x1F);
  param.iPicWidth = 1+(((data[2] << 8) + data[3]) % 2048);
  param.iPicHeight = 1+(((data[4] << 8) + data[5]) % 2048);
  param.iTargetBitrate = 1<<(data[2] & 0x1F);
  int videoFormat = videoFormatI420;
  pEncoder->Initialize (&param);
  pEncoder->SetOption (ENCODER_OPTION_TRACE_LEVEL, &iLevelSetting);
  if (pEncoder->SetOption (ENCODER_OPTION_DATAFORMAT, &videoFormat) != 0 ) {
      pEncoder->Uninitialize ();
      WelsDestroySVCEncoder (pEncoder);
    return 0;
  }

    data += 8;
    size -= 8;

    size_t imsize = 4*param.iPicWidth * param.iPicHeight;
    uint8_t * imbuf = malloc(4*param.iPicWidth * param.iPicHeight);

    SFrameBSInfo info = { 0 };
    SSourcePicture pic = { 0 };
    pic.iPicWidth = param.iPicWidth;
    pic.iPicHeight = param.iPicHeight;
    pic.iColorFormat = videoFormat;
    pic.iStride[0] = pic.iPicWidth;
    pic.iStride[1] = pic.iPicWidth >> 1;
    pic.iStride[2] = pic.iPicWidth >> 1;
    pic.pData[0] = imbuf;
    pic.pData[1] = imbuf + param.iPicWidth * param.iPicHeight;
    pic.pData[2] = imbuf + 2 * param.iPicWidth * param.iPicHeight;
    while (size > 0) {
        //prepare input data
        if (imsize > size) {
            imsize = size;
        }
        memcpy(imbuf, data, imsize);
        pEncoder->EncodeFrame (&pic, &info);
        data += imsize;
        size -= imsize;
    }
    free(imbuf);

    pEncoder->Uninitialize ();
    WelsDestroySVCEncoder (pEncoder);
  return 0;
}
