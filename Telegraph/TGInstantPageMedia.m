#import "TGInstantPageMedia.h"

#import <LegacyComponents/LegacyComponents.h>

@implementation TGInstantPageMedia

- (instancetype)initWithIndex:(NSInteger)index media:(id)media groupedId:(int64_t)groupedId {
    self = [super init];
    if (self != nil) {
        _index = index;
        _media = media;
        _groupedId = groupedId;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGInstantPageMedia class]] && ((TGInstantPageMedia *)object)->_index == _index && TGObjectCompare(((TGInstantPageMedia *)object)->_media, _media) && ((TGInstantPageMedia *)object)->_groupedId == _groupedId;
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
