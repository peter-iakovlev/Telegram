#import <Foundation/Foundation.h>

#import <LegacyComponents/LegacyComponents.h>

@interface TGAudioMediaAttachment (TG)

- (NSString *)localFilePath;
 
+ (NSString *)localAudioFileDirectoryForLocalAudioId:(int64_t)audioId;
+ (NSString *)localAudioFileDirectoryForRemoteAudioId:(int64_t)audioId;
+ (NSString *)localAudioFilePathForLocalAudioId:(int64_t)audioId;
+ (NSString *)localAudioFilePathForRemoteAudioId:(int64_t)audioId;

@end
