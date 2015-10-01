#import "TGReplyHeaderLocationModel.h"

#import "TGSharedLocationSignals.h"

#import "TGSharedMediaSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGSignalImageViewModel.h"

@interface TGReplyHeaderLocationModel ()
{
    //TGSignalImageViewModel *_imageModel;
}

@end

@implementation TGReplyHeaderLocationModel

- (instancetype)initWithPeer:(id)peer latitude:(double)__unused latitude longitude:(double)__unused longitude incoming:(bool)incoming system:(bool)system
{
    self = [super initWithPeer:peer incoming:incoming text:TGLocalized(@"Message.Location") truncateTextInTheMiddle:false textColor:[TGReplyHeaderModel colorForMediaText:incoming] leftInset:0.0f system:system];
    if (self != nil)
    {
        /*_imageModel = [[TGSignalImageViewModel alloc] init];
        [_imageModel setSignalGenerator:^SSignal *
        {
            return [TGSharedLocationSignals squareLocationThumbnailForLatitude:latitude longitude:longitude ofSize:CGSizeMake(35.0f, 35.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] persistentCache:[TGSharedMediaUtils sharedMediaTemporaryPersistentCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]]];
        } identifier:[[NSString alloc] initWithFormat:@"reply-location-%f-%f", latitude, longitude]];
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
