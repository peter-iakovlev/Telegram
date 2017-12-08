#import "TGReplyHeaderFileModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGSharedMediaSignals.h"
#import "TGSharedFileSignals.h"
#import "TGSharedMediaUtils.h"

#import "TGSignalImageViewModel.h"

#import "TGSharedPhotoSignals.h"

@interface TGReplyHeaderFileModel ()
{
}

@end

@implementation TGReplyHeaderFileModel

- (instancetype)initWithPeer:(id)peer fileMedia:(TGDocumentMediaAttachment *)fileMedia incoming:(bool)incoming system:(bool)system {
    return [self initWithPeer:peer fileMedia:fileMedia incoming:incoming system:system caption:fileMedia.caption.length == 0 ? nil : fileMedia.caption];
}

- (instancetype)initWithPeer:(id)peer fileMedia:(TGDocumentMediaAttachment *)fileMedia incoming:(bool)incoming system:(bool)system caption:(NSString *)caption
{
    bool isVoice = false;
    for (id attribute in fileMedia.attributes) {
        if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]]) {
            isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
            break;
        }
    }
    NSString *text = isVoice ? TGLocalized(@"Message.Audio") : ([fileMedia isAnimated] ? TGLocalized(@"Message.Animation") : fileMedia.fileName);
    
    TGImageMediaAttachment *imageMedia = nil;
    if ([fileMedia isAnimated] && fileMedia.thumbnailInfo != nil) {
        imageMedia = [[TGImageMediaAttachment alloc] init];
        imageMedia.imageInfo = fileMedia.thumbnailInfo;
    }
    
    for (id attribute in fileMedia.attributes)
    {
        if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
        {
            TGDocumentAttributeAudio *audio = (TGDocumentAttributeAudio *)attribute;
            if (audio.title.length > 0)
            {
                text = audio.title;
                if (audio.performer.length > 0)
                    text = [[NSString alloc] initWithFormat:@"%@ — %@", audio.performer, text];
            }
        }
    }
    
    self = [super initWithPeer:peer incoming:incoming text:caption == nil ? text : caption imageSignalGenerator:imageMedia == nil ? nil : ^SSignal *
            {
                return [TGSharedPhotoSignals squarePhotoThumbnail:imageMedia ofSize:CGSizeMake(33.0f, 33.0f) threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:[TGReplyHeaderModel thumbnailCornerRadius]] downloadLargeImage:false placeholder:nil];
            } imageSignalIdentifier:[[NSString alloc] initWithFormat:@"reply-image-%@-%" PRId64 "", imageMedia.imageId != 0 ? @"remote" : @"local", imageMedia.imageId != 0 ? imageMedia.imageId : imageMedia.localImageId] icon:nil truncateTextInTheMiddle:false system:system];
    
    if (self != nil)
    {
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
