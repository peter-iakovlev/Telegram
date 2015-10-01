#import "TGSharedMediaItemView.h"

@implementation TGSharedMediaItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.layer.zPosition = -1.0f;
    }
    return self;
}

- (void)enqueueImageViewWithUri
{
}

- (UIView *)transitionView
{
    return nil;
}

- (void)updateItemHidden
{
}

- (void)updateItemSelected
{
}

- (void)imageThumbnailUpdated:(NSString *)__unused thumbnaiUri
{
}

- (void)setEditing:(bool)editing animated:(bool)animated
{
    [self setEditing:editing animated:animated delay:0.0];
}

- (void)setEditing:(bool)editing animated:(bool)__unused animated delay:(NSTimeInterval)__unused delay
{
    _editing = editing;
}

@end
