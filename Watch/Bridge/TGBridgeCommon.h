#import <Foundation/Foundation.h>

@interface TGBridgeCommon : NSObject

+ (NSString *)groupName;
+ (NSString *)cachePath;

@end

extern NSString *const TGBridgeIncomingFileTypeKey;
extern NSString *const TGBridgeIncomingFileIdentifierKey;
extern NSString *const TGBridgeIncomingFileRandomIdKey;
extern NSString *const TGBridgeIncomingFilePeerIdKey;
extern NSString *const TGBridgeIncomingFileReplyToMidKey;

extern NSString *const TGBridgeIncomingFileTypeAudio;
extern NSString *const TGBridgeIncomingFileTypeImage;
