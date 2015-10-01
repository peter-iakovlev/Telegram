#import "TGMusicPlayerItem.h"

#import "TGMessage.h"

@implementation TGMusicPlayerItem

+ (instancetype)itemWithMessage:(TGMessage *)message
{
    for (id attachment in message.mediaAttachments)
    {
        if ([attachment isKindOfClass:[TGDocumentMediaAttachment class]])
        {
            for (id attribute in ((TGDocumentMediaAttachment *)attachment).attributes)
            {
                if ([attribute isKindOfClass:[TGDocumentAttributeAudio class]])
                {
                    return [[TGMusicPlayerItem alloc] initWithKey:@(message.mid) document:attachment peerId:message.cid];
                }
            }
        }
    }
    
    return nil;
}

- (instancetype)initWithKey:(id<NSObject, NSCopying>)key document:(TGDocumentMediaAttachment *)document peerId:(int64_t)peerId
{
    self = [super init];
    if (self != nil)
    {
        _key = key;
        _document = document;
        _peerId = peerId;
    }
    return self;
}

@end
