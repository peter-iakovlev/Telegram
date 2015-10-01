#import "ASCommon.h"

#import <sys/time.h>

#import "TGAppDelegate.h"

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

