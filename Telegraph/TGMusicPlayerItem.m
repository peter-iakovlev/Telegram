#import "TGMusicPlayerItem.h"

#import "TGMessage.h"

@interface TGMusicPlayerItem () {
    bool _isVoice;
}

@end

@implementation TGMusicPlayerItem

+ (instancetype)itemWithMessage:(TGMessage *)message author:(TGUser *)author
{
    for (id attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
            {
                if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
                {
                    TGMusicPlayerItem *item = [[TGMusicPlayerItem alloc] initWithKey:@(message.mid) media:attachment peerId:message.cid author:author date:(int32_t)message.date];
                    item->_isVoice = ((TGDocumentAttributeAudio *)attribute).isVoice;
                    return item;
                }
            }
        } else if ([attachment isKindOfClass:[TGAudioMediaAttachment class]]) {
            TGMusicPlayerItem *item = [[TGMusicPlayerItem alloc] initWithKey:@(message.mid) media:attachment peerId:message.cid author:author date:(int32_t)message.date];
            item->_isVoice = true;
            return item;
        }
    }
    
    return nil;
}

- (instancetype)initWithKey:(id<NSObject, NSCopying>)key media:(id)media peerId:(int64_t)peerId author:(TGUser *)author date:(int32_t)date
{
    self = [super init];
    if (self != nil)
    {
        _key = key;
        _media = media;
        _peerId = peerId;
        _author = author;
        _date = date;
    }
    return self;
}

- (bool)isVoice {
    return _isVoice;
}

@end
