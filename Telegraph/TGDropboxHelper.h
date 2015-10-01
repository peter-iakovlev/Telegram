#import <Foundation/Foundation.h>

@interface TGDropboxHelper : NSObject

+ (void)openExternalPicker;
+ (void)handleOpenURL:(NSURL *)url;

+ (NSString *)dropboxURLScheme;
+ (bool)isDropboxInstalled;

@end

extern NSString *const TGDropboxFilesReceivedNotification;
