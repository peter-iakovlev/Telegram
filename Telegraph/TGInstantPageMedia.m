#import "TGInstantPageMedia.h"

#import "TGImageMediaAttachment.h"
#import "TGVideoMediaAttachment.h"

@implementation TGInstantPageMedia

- (instancetype)initWithIndex:(NSInteger)index media:(id)media {
    self = [super init];
    if (self != nil) {
        _index = index;
        _media = media;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGInstantPageMedia class]] && ((TGInstantPageMedia *)object)->_index == _index && TGObjectCompare(((TGInstantPageMedia *)object)->_media, _media);
}

- (NSString *)caption {
    if ([_media isKindOfClass:[TGImageMediaAttachment class]]) {
        return ((TGImageMediaAttachment *)_media).caption;
    } else if ([_media isKindOfClass:[TGVideoMediaAttachment class]]) {
        return ((TGVideoMediaAttachment *)_media).caption;
    }
    return nil;
}

@end
