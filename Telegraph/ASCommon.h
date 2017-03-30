/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#ifndef ActionStage_ASCommon_h
#define ActionStage_ASCommon_h

#include <inttypes.h>

//#define DISABLE_LOGGING

//#define INTERNAL_RELEASE

//#define EXTERNAL_INTERNAL_RELEASE

#ifdef __cplusplus
extern "C" {
#endif

void TGLogSetEnabled(bool enabled);
bool TGLogEnabled();
void TGLog(NSString *format, ...);
void TGLogv(NSString *format, va_list args);

void TGLogSynchronize();
NSArray *TGGetLogFilePaths(int count);
NSArray *TGGetPackedLogs();
    
#ifdef __cplusplus
}
#endif

#endif
