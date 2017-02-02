#import "TLInputMedia.h"

@class TLInputFile;

@interface TLInputMediaUploadedPhoto : TLInputMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLInputFile *file;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *stickers;

@end
