#import "TGReplyHeaderPhotoModel.h"

#import "TGSharedMediaSignals.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGImageMediaAttachment.h"

@interface TGReplyHeaderPhotoModel ()
{
}

@end

@implementation TGReplyHeaderPhotoModel

- (instancetype)initWithPeer:(id)peer imageMedia:(TGImageMediaAttachment *)imageMedia incoming:(bool)incoming system:(bool)system
{
    self = [super initWithPeer:peer incoming:incoming text:TGLocalized(@"Message.Photo") truncateTextInTheMiddle:false textColor:[TGReplyHeaderModel colorForMediaText:incoming] leftInset:44.0f system:system];
    self = [super initWithPeer:peer incoming:incoming text:TGLocalized(@"Message.Photo") imageSignalGenerator:^SSignal *
        {
            return [TGSharedPhotoSignals squarePhotoThumbnail:imageMedia ofSize:CGSizeMake(33.0f, 33.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]] downloadLargeImage:false placeholder:nil];
        } imageSignalIdentifier:[[NSString alloc] initWithFormat:@"reply-image-%@-%" PRId64 "", imageMedia.imageId != 0 ? @"remote" : @"local", imageMedia.imageId != 0 ? imageMedia.imageId : imageMedia.localImageId] icon:nil truncateTextInTheMiddle:false system:system];
    if (self != nil)
    {
    }
    return self;
}

@end
