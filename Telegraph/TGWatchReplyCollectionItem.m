#import "TGWatchReplyCollectionItem.h"
#import "TGWatchReplyCollectionItemView.h"

@implementation TGWatchReplyCollectionItem

- (instancetype)initWithIdentifier:(NSString *)identifier value:(NSString *)value placeholder:(NSString *)placeholder
{
    self = [super init];
    if (self != nil)
    {
        self.highlightable = false;
        self.selectable = false;
        
        _identifier = identifier;
        _value = value;
        _placeholder = placeholder;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGWatchReplyCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    return CGSizeMake(containerSize.width, 44.0f);
}

- (void)bindView:(TGWatchReplyCollectionItemView *)view
{
    [super bindView:view];
    
    [view setValue:_value];
    [view setPlaceholder:_placeholder];
    
    __weak TGWatchReplyCollectionItem *weakSelf = self;
    view.valueChanged = ^(NSString *value)
    {
        __strong TGWatchReplyCollectionItem *strongSelf = weakSelf;
        strongSelf.value = value;
        
        if (strongSelf.valueChanged)
            strongSelf.valueChanged(value);
    };
    view.inputReturned = [self.inputReturned copy];
}

- (void)unbindView
{
    ((TGWatchReplyCollectionItemView *)self.boundView).valueChanged = nil;
    ((TGWatchReplyCollectionItemView *)self.boundView).inputReturned = nil;
    
    [super unbindView];
}

- (void)becomeFirstResponder
{
    [((TGWatchReplyCollectionItemView *)self.boundView) becomeFirstResponder];
}

- (void)resignFirstResponder
{
    [((TGWatchReplyCollectionItemView *)self.boundView) resignFirstResponder];
}

@end
