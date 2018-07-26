#import <LegacyComponents/LegacyComponents.h>
#import "TGPassportGalleryItem.h"

@class TGPassportFile;

@interface TGPassportGalleryModel : TGModernGalleryModel

@property (nonatomic, copy) void (^deleteFile)(TGPassportFile *);

- (instancetype)initWithFiles:(NSArray *)files centralFile:(TGPassportFile *)centralFile;

@end
