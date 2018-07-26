#import "TGCommon.h"

#import <LegacyComponents/LegacyComponents.h>

#include <sys/sysctl.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

#import <UIKit/UIKit.h>

#import <CommonCrypto/CommonDigest.h>

#import <CoreMotion/CoreMotion.h>

#import "TGAppDelegate.h"

#import <sys/time.h>

#import <pthread.h>

int cpuCoreCount()
{
    static int count = 0;
    if (count == 0)
    {
        size_t len;
        unsigned int ncpu;
        
        len = sizeof(ncpu);
        sysctlbyname("hw.ncpu", &ncpu, &len, NULL, 0);
        count = ncpu;
    }
    
    return count;
}

bool hasModernCpu()
{
    return iosMajorVersion() >= 7 && [CMMotionActivityManager isActivityAvailable];
}

int deviceMemorySize()
{
    static int memorySize = 0;
    if (memorySize == 0)
    {
        size_t len;
        __int64_t nmem;
        
        len = sizeof(nmem);
        sysctlbyname("hw.memsize", &nmem, &len, NULL, 0);
        memorySize = (int)(nmem / (1024 * 1024));
    }
    return memorySize;
}

bool TGObjectCompare(id obj1, id obj2)
{
    if (obj1 == nil && obj2 == nil)
        return true;
    
    return [obj1 isEqual:obj2];
}

bool TGStringCompare(NSString *s1, NSString *s2)
{
    if (s1.length == 0 && s2.length == 0)
        return true;
    
    if ((s1 == nil) != (s2 == nil))
        return false;
    
    return s1 == nil || [s1 isEqualToString:s2];
}

NSTimeInterval TGCurrentSystemTime()
{
    static mach_timebase_info_data_t timebase;
    if (timebase.denom == 0)
        mach_timebase_info(&timebase);
    
    return ((double)mach_absolute_time()) * ((double)timebase.numer) / ((double)timebase.denom) / 1e9;
}

int iosMajorVersion()
{
    static bool initialized = false;
    static int version = 7;
    if (!initialized)
    {
        switch ([[[UIDevice currentDevice] systemVersion] intValue])
        {
            case 4:
                version = 4;
                break;
            case 5:
                version = 5;
                break;
            case 6:
                version = 6;
                break;
            case 7:
                version = 7;
                break;
            case 8:
                version = 8;
                break;
            case 9:
                version = 9;
                break;
            case 10:
                version = 10;
                break;
            case 11:
                version = 11;
                break;
            case 12:
                version = 12;
                break;
            default:
                version = 11;
                break;
        }
        
        initialized = true;
    }
    return version;
}

int iosMinorVersion()
{
    static bool initialized = false;
    static int version = 0;
    if (!initialized)
    {
        NSString *versionString = [[UIDevice currentDevice] systemVersion];
        NSRange range = [versionString rangeOfString:@"."];
        if (range.location != NSNotFound)
            version = [[versionString substringFromIndex:range.location + 1] intValue];
        
        initialized = true;
    }
    return version;
}

void printMemoryUsage(NSString *tag)
{
    struct task_basic_info info;
    
    mach_msg_type_number_t size = sizeof(info);
    
    kern_return_t kerr = task_info(mach_task_self(),
                                   
                                   TASK_BASIC_INFO,
                                   
                                   (task_info_t)&info,
                                   
                                   &size);
    if( kerr == KERN_SUCCESS )
    {
        TGLog(@"===== %@: Memory used: %u", tag, info.resident_size / 1024 / 1024);
    }
    else
    {
        TGLog(@"===== %@: Error: %s", tag, mach_error_string(kerr));
    }
}

void TGDumpViews(UIView *view, NSString *indent)
{
    TGLog(@"%@%@", indent, view);
    NSString *newIndent = [[NSString alloc] initWithFormat:@"%@    ", indent];
    for (UIView *child in view.subviews)
        TGDumpViews(child, newIndent);
}

NSString *TGEncodeText(NSString *string, int key)
{
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (int i = 0; i < (int)[string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        c += key;
        [result appendString:[NSString stringWithCharacters:&c length:1]];
    }
    
    return result;
}

NSString *TGStringMD5(NSString *string)
{
    const char *ptr = [string UTF8String];
    unsigned char md5Buffer[16];
    CC_MD5(ptr, (CC_LONG)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], md5Buffer);
    NSString *output = [[NSString alloc] initWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", md5Buffer[0], md5Buffer[1], md5Buffer[2], md5Buffer[3], md5Buffer[4], md5Buffer[5], md5Buffer[6], md5Buffer[7], md5Buffer[8], md5Buffer[9], md5Buffer[10], md5Buffer[11], md5Buffer[12], md5Buffer[13], md5Buffer[14], md5Buffer[15]];

    return output;
}

@implementation NSNumber (IntegerTypes)

- (int32_t)int32Value
{
    return (int32_t)[self intValue];
}

- (int64_t)int64Value
{
    return (int64_t)[self longLongValue];
}

@end

int TGLocalizedStaticVersion = 0;

void TGSetLocalizationFromFile(NSString *filePath) {
    if (filePath != nil) {
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        if (dict != nil) {
            setCurrentCustomLocalization([[TGLocalization alloc] initWithVersion:0 code:@"custom" dict:dict isActive:true]);
        }
    }
}

static pthread_mutex_t _currentLocalizationMutex = PTHREAD_MUTEX_INITIALIZER;
static TGLocalization *_safeCurrentNativeLocalization;
static bool _currentCustomLocalizationInitialized = false;
static TGLocalization *_safeCurrentCustomLocalization;

static NSString *currentNativeLocalizationPath() {
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0] stringByAppendingPathComponent:@"localization"];
    });
    return path;
}

static NSString *currentNativeExtensionLocalizationPath() {
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"localization"];
    });
    return path;
}

static NSString *currentCustomLocalizationPath() {
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0] stringByAppendingPathComponent:@"localization-custom-active"];
    });
    return path;
}

NSString *currentLocalizationEnglishLanguageName() {
    if ([currentNativeLocalization().code isEqualToString:@"en"]) {
        return [currentNativeLocalization() get:@"Localization.EnglishLanguageName"];
    } else {
        TGLocalization *localization = [[TGLocalization alloc] initWithVersion:0 code:@"en" dict:@{} isActive:true];
        return [localization get:@"Localization.EnglishLanguageName"];
    }
}

TGLocalization *nativeEnglishLocalization() {
    if ([currentNativeLocalization().code isEqualToString:@"en"]) {
        return currentNativeLocalization();
    } else {
        TGLocalization *localization = [[TGLocalization alloc] initWithVersion:0 code:@"en" dict:@{} isActive:true];
        return localization;
    }
}

TGLocalization *currentNativeLocalization() {
    TGLocalization *value = nil;
    pthread_mutex_lock(&_currentLocalizationMutex);
    value = _safeCurrentNativeLocalization;
    pthread_mutex_unlock(&_currentLocalizationMutex);
    if (value == nil) {
        NSData *data = [NSData dataWithContentsOfFile:currentNativeLocalizationPath()];
        if (data != nil) {
            value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        if (value == nil) {
            NSString *nativeLanguage = @"en";
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            if ([bundleIdentifier isEqualToString:@"co.one.Teleapp"]) {
                nativeLanguage = @"ru";
            }
            value = [[TGLocalization alloc] initWithVersion:0 code:nativeLanguage dict:@{} isActive:true];
        }
        if (value != nil) {
            pthread_mutex_lock(&_currentLocalizationMutex);
            _safeCurrentNativeLocalization = value;
            pthread_mutex_unlock(&_currentLocalizationMutex);
        }
    }
    return value;
}

static NSString *legacyCustomLocalizationBundlePath() {
    return [[TGAppDelegate documentsPath] stringByAppendingPathComponent:@"CustomLocalization.bundle"];
}

TGLocalization *currentCustomLocalization() {
    TGLocalization *value = nil;
    bool initialized = false;
    pthread_mutex_lock(&_currentLocalizationMutex);
    value = _safeCurrentCustomLocalization;
    initialized = _currentCustomLocalizationInitialized;
    pthread_mutex_unlock(&_currentLocalizationMutex);
    if (!initialized) {
        NSData *data = [NSData dataWithContentsOfFile:currentCustomLocalizationPath()];
        if (data != nil) {
            value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        } else {
            NSBundle *bundle = [NSBundle bundleWithPath:legacyCustomLocalizationBundlePath()];
            NSString *path = [bundle pathForResource:@"Localizable" ofType:@"strings"];
            if (path != nil) {
                NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
                if (dict != nil) {
                    [[NSFileManager defaultManager] removeItemAtPath:legacyCustomLocalizationBundlePath() error:nil];
                    TGLocalization *localization = [[TGLocalization alloc] initWithVersion:0 code:@"custom" dict:dict isActive:true];
                    setCurrentCustomLocalization(localization);
                    value = localization;
                }
            }
        }
        
        pthread_mutex_lock(&_currentLocalizationMutex);
        _safeCurrentCustomLocalization = value;
        _currentCustomLocalizationInitialized = true;
        pthread_mutex_unlock(&_currentLocalizationMutex);
    }
    return value;
}

TGLocalization *effectiveLocalization() {
    TGLocalization *custom = currentCustomLocalization();
    if (custom.isActive) {
        return custom;
    }
    return currentNativeLocalization();
}

void setCurrentNativeLocalization(TGLocalization *localization, bool switchIfCustom) {
    pthread_mutex_lock(&_currentLocalizationMutex);
    _safeCurrentNativeLocalization = localization;
    pthread_mutex_unlock(&_currentLocalizationMutex);
    
    [[NSFileManager defaultManager] removeItemAtPath:currentNativeLocalizationPath() error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:currentNativeExtensionLocalizationPath() error:nil];
    [NSKeyedArchiver archiveRootObject:localization toFile:currentNativeLocalizationPath()];
    
    [[NSFileManager defaultManager] copyItemAtPath:currentNativeLocalizationPath() toPath:currentNativeExtensionLocalizationPath() error:nil];
    TGLocalizedStaticVersion++;
    
    if (switchIfCustom) {
        setCurrentCustomLocalization([currentCustomLocalization() withUpdatedIsActive:false]);
    }
}

void setCurrentCustomLocalization(TGLocalization *localization) {
    pthread_mutex_lock(&_currentLocalizationMutex);
    _safeCurrentCustomLocalization = localization;
    _currentCustomLocalizationInitialized = true;
    pthread_mutex_unlock(&_currentLocalizationMutex);
    
    [[NSFileManager defaultManager] removeItemAtPath:currentCustomLocalizationPath() error:nil];
    if (localization != nil) {
        [NSKeyedArchiver archiveRootObject:localization toFile:currentCustomLocalizationPath()];
    }
    TGLocalizedStaticVersion++;
}

NSString *TGLocalized(NSString *s)
{
    return [effectiveLocalization() get:s];
}

static dispatch_queue_t TGLogQueue()
{
    static dispatch_queue_t queue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = dispatch_queue_create("com.telegraphkit.logging", 0);
    });
    return queue;
}

static NSFileHandle *TGLogFileHandle()
{
    static NSFileHandle *fileHandle = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        NSString *documentsDirectory = [TGAppDelegate documentsPath];
        
        NSString *currentFilePath = [documentsDirectory stringByAppendingPathComponent:@"application-0.log"];
        NSString *oldestFilePath = [documentsDirectory stringByAppendingPathComponent:@"application-30.log"];
        
        if ([fileManager fileExistsAtPath:oldestFilePath])
            [fileManager removeItemAtPath:oldestFilePath error:nil];
        
        for (int i = 60 - 1; i >= 0; i--)
        {
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"application-%d.log", i]];
            NSString *nextFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"application-%d.log", i + 1]];
            if ([fileManager fileExistsAtPath:filePath])
            {
                [fileManager moveItemAtPath:filePath toPath:nextFilePath error:nil];
            }
        }
        
        [fileManager createFileAtPath:currentFilePath contents:nil attributes:nil];
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:currentFilePath];
        [fileHandle truncateFileAtOffset:0];
    });
    
    return fileHandle;
}

void TGLogSynchronize()
{
    dispatch_async(TGLogQueue(), ^
    {
        [TGLogFileHandle() synchronizeFile];
    });
}

static bool logEnabled =
#if (defined(DEBUG) || defined(INTERNAL_RELEASE)) && !defined(DISABLE_LOGGING)
    true;
#else
    false;
#endif

void TGLogSetEnabled(bool enabled)
{
    logEnabled = enabled;
}

bool TGLogEnabled()
{
    return logEnabled;
}

void TGLog(NSString *format, ...)
{
    if (logEnabled)
    {
        va_list L;
        va_start(L, format);
        TGLogv(format, L);
        va_end(L);
    }
}

void TGLogv(NSString *format, va_list args)
{
    if (logEnabled)
    {
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        
        NSLog(@"%@", message);
        
        dispatch_async(TGLogQueue(), ^
        {
            NSFileHandle *output = TGLogFileHandle();
            
            if (output != nil)
            {
                time_t rawtime;
                struct tm timeinfo;
                char buffer[64];
                time(&rawtime);
                localtime_r(&rawtime, &timeinfo);
                struct timeval curTime;
                gettimeofday(&curTime, NULL);
                int milliseconds = curTime.tv_usec / 1000;
                strftime(buffer, 64, "%Y-%m-%d %H:%M", &timeinfo);
                char fullBuffer[128] = { 0 };
                snprintf(fullBuffer, 128, "%s:%2d.%.3d ", buffer, timeinfo.tm_sec, milliseconds);
                
                [output writeData:[[[NSString alloc] initWithCString:fullBuffer encoding:NSASCIIStringEncoding] dataUsingEncoding:NSUTF8StringEncoding]];
                
                [output writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
                
                static NSData *returnData = nil;
                if (returnData == nil)
                    returnData = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
                [output writeData:returnData];
            }
        });
    }
}

NSArray *TGGetLogFilePaths(int count)
{
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    
    NSString *documentsDirectory = [TGAppDelegate documentsPath];
    
    for (int i = 0; i <= count; i++)
    {
        NSString *fileName = [NSString stringWithFormat:@"application-%d.log", i];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            [filePaths addObject:filePath];
        }
    }
    
    return filePaths;
}

NSArray *TGGetPackedLogs()
{
    NSMutableArray *resultFiles = [[NSMutableArray alloc] init];
    
    dispatch_sync(TGLogQueue(), ^
    {
        [TGLogFileHandle() synchronizeFile];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        NSString *documentsDirectory = [TGAppDelegate documentsPath];
        
        for (int i = 0; i <= 4; i++)
        {
            NSString *fileName = [NSString stringWithFormat:@"application-%d.log", i];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
            if ([fileManager fileExistsAtPath:filePath])
            {
                NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
                if (fileData != nil)
                    [resultFiles addObject:fileData];
            }
        }
    });
    
    return resultFiles;
}
