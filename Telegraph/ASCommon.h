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

#if (defined(DEBUG) || defined(INTERNAL_RELEASE)) && !defined(DISABLE_LOGGING)
#define TGLog TGLogToFile
#define TGLogv TGLogToFilev
#else
#define TGLog(x, ...) (void)x
#define TGLogv(x, args) (void)x
#endif

#ifdef __cplusplus
extern "C" {
#endif

void TGLogToFile(NSString *format, ...);
void TGLogToFilev(NSString *format, va_list args);
void TGLogSynchronize();
NSArray *TGGetLogFilePaths();
NSArray *TGGetPackedLogs();
    
#ifdef __cplusplus
}
#endif

#endif
