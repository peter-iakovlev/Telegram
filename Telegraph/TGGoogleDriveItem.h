#import <Foundation/Foundation.h>

@class GDGoogleDriveMetadata;

@interface TGGoogleDriveItem : NSObject

@property (nonatomic, readonly) NSString *fileId;
@property (nonatomic, readonly) NSURL *fileUrl;
@property (nonatomic, readonly) NSURL *previewUrl;
@property (nonatomic, readonly) CGSize previewSize;

@property (nonatomic, readonly) NSString *mimeType;

@property (nonatomic, readonly) CGSize imageSize;
@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSUInteger fileSize;

+ (instancetype)googleDriveItemWithMetadata:(GDGoogleDriveMetadata *)metadata;

@end
