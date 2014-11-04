#import "TGPreparedMessage.h"

@class TGImageInfo;

@interface TGPreparedDownloadImageMessage : TGPreparedMessage

@property (nonatomic, strong) TGImageInfo *imageInfo;

- (instancetype)initWithImageInfo:(TGImageInfo *)imageInfo;

@end
