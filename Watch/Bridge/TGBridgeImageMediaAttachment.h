#import "TGBridgeMediaAttachment.h"
#import "TGBridgeImageInfo.h"

@interface TGBridgeImageMediaAttachment : TGBridgeMediaAttachment

@property (nonatomic, assign) int64_t imageId;
@property (nonatomic, assign) int64_t localImageId;
@property (nonatomic, strong) TGBridgeImageInfo *imageInfo;
@property (nonatomic, strong) NSString *caption;

@end
