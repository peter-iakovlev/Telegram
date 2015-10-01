#import "TGBridgeCommon.h"

@implementation TGBridgeCommon

+ (NSString *)groupName
{
    static NSString *groupName = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        groupName = [@"group." stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
        
        if ([groupName hasSuffix:@".watchkitapp.watchkitextension"])
            groupName = [groupName substringWithRange:NSMakeRange(0, groupName.length - @".watchkitapp.watchkitextension".length)];
    });
    
    return groupName;
}

+ (NSString *)cachePath
{
    static NSString *path = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        NSString *groupName = [self groupName];
        
        NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:groupName];
        if (groupURL != nil)
        {
            NSString *cachePath = [[groupURL path] stringByAppendingPathComponent:@"Caches"];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:true attributes:nil error:NULL];
            
            path = cachePath;
        }
        else
            path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)[0];
    });
                  
    return path;
}

@end

NSString *const TGBridgeFileKey = @"fileKey";

NSString *const TGBridgeIncomingFileTypeKey = @"type";
NSString *const TGBridgeIncomingFileRandomIdKey = @"randomId";
NSString *const TGBridgeIncomingFilePeerIdKey = @"peerId";
NSString *const TGBridgeIncomingFileReplyToMidKey = @"replyToMid";

NSString *const TGBridgeIncomingFileTypeAudio = @"audio";
