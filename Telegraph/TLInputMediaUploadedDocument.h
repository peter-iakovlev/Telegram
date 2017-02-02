#import "TLInputMedia.h"

//inputMediaUploadedDocument flags:# file:InputFile mime_type:string attributes:Vector<DocumentAttribute> caption:string stickers:flags.0?Vector<InputDocument> = InputMedia;

@class TLInputFile;

@interface TLInputMediaUploadedDocument : TLInputMedia

@property (nonatomic) int32_t flags;
@property (nonatomic, strong) TLInputFile *file;
@property (nonatomic, strong) NSString *mime_type;
@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *stickers;

@end
