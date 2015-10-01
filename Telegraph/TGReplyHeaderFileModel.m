#import "TGReplyHeaderFileModel.h"

#import "TGSharedMediaSignals.h"
#import "TGSharedFileSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGDocumentMediaAttachment.h"

#import "TGSignalImageViewModel.h"

@interface TGReplyHeaderFileModel ()
{
    //TGSignalImageViewModel *_imageModel;
}

@end

@implementation TGReplyHeaderFileModel

- (instancetype)initWithPeer:(id)peer fileMedia:(TGDocumentMediaAttachment *)fileMedia incoming:(bool)incoming system:(bool)system
{
    self = [super initWithPeer:peer incoming:incoming text:fileMedia.fileName truncateTextInTheMiddle:true textColor:[TGReplyHeaderModel colorForMediaText:incoming] leftInset:0.0f system:system];
    if (self != nil)
    {
        /*_imageModel = [[TGSignalImageViewModel alloc] init];
        [_imageModel setSignalGenerator:^SSignal *
        {
            return [TGSharedFileSignals squareFileThumbnail:fileMedia ofSize:CGSizeMake(35.0f, 35.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]]];
        } identifier:[[NSString alloc] initWithFormat:@"reply-file-%@-%" PRId64 "", fileMedia.documentId != 0 ? @"remote" : @"local", fileMedia.documentId != 0 ? fileMedia.documentId : fileMedia.localDocumentId]];
        _imageModel.skipDrawInContext = true;
        [self addSubmodel:_imageModel];*/
    }
    return self;
}

/*- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    [super bindSpecialViewsToContainer:container viewStorage:viewStorage atItemPosition:itemPosition];
    
    _imageModel.parentOffset = itemPosition;
    [_imageModel bindViewToContainer:container viewStorage:viewStorage];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    [super layoutForContainerSize:containerSize];
    
    _imageModel.frame = CGRectMake(8.0f, 7.0f, 35.0f, 35.0f);
}*/

@end
