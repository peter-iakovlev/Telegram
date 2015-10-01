#import "TGReplyHeaderVideoModel.h"

#import "TGSharedMediaSignals.h"
#import "TGSharedVideoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGVideoMediaAttachment.h"

#import "TGSignalImageViewModel.h"
#import "TGModernImageViewModel.h"

@interface TGReplyHeaderVideoModel ()
{
}

@end

@implementation TGReplyHeaderVideoModel

- (instancetype)initWithPeer:(id)peer videoMedia:(TGVideoMediaAttachment *)videoMedia incoming:(bool)incoming system:(bool)system
{
    self = [super initWithPeer:peer incoming:incoming text:TGLocalized(@"Message.Video") truncateTextInTheMiddle:false textColor:[TGReplyHeaderModel colorForMediaText:incoming] leftInset:44.0f system:system];
    self = [super initWithPeer:peer incoming:incoming text:TGLocalized(@"Message.Video") imageSignalGenerator:^SSignal *
    {
        return [TGSharedVideoSignals squareVideoThumbnail:videoMedia ofSize:CGSizeMake(33.0f, 33.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]]];
    } imageSignalIdentifier:[[NSString alloc] initWithFormat:@"reply-video-%@-%" PRId64 "", videoMedia.videoId != 0 ? @"remote" : @"local", videoMedia.videoId != 0 ? videoMedia.videoId : videoMedia.localVideoId] icon:[UIImage imageNamed:@"ReplyHeaderThumbnailVideoPlay.png"] truncateTextInTheMiddle:false system:system];
    if (self != nil)
    {
    }
    return self;
}

@end
