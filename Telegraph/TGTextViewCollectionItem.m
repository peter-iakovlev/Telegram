#import "TGTextViewCollectionItem.h"

#import "TGTextViewCollectionItemView.h"
#import "TGFont.h"

@interface TGTextViewCollectionItem ()
{
    NSUInteger _numberOfLines;
}

@end

@implementation TGTextViewCollectionItem

- (instancetype)initWithNumberOfLines:(NSUInteger)numberOfLines
{
    self = [super init];
    if (self != nil)
    {
        self.selectable = false;
        self.highlightable = false;
        
        _numberOfLines = numberOfLines;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGTextViewCollectionItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    NSMutableString *string = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < _numberOfLines; i++)
    {
        [string appendString:@"a\n"];
    }
    
    CGSize size = [string sizeWithFont:TGSystemFontOfSize(16.0f) constrainedToSize:CGSizeMake(containerSize.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    return CGSizeMake(containerSize.width, size.height);
}

- (void)bindView:(TGTextViewCollectionItemView *)view
{
    [super bindView:view];
    
    [view setText:_text];
    
    __weak TGTextViewCollectionItem *weakSelf = self;
    view.textChanged = ^(NSString *text)
    {
        __strong TGTextViewCollectionItem *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            strongSelf.text = text;
            if (strongSelf.textChanged)
                strongSelf.textChanged(text);
        }
    };
}

- (void)unbindView
{
    ((TGTextViewCollectionItemView *)self.boundView).textChanged = nil;
    
    [super unbindView];
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    [((TGTextViewCollectionItemView *)self.boundView) setText:text];
}

@end
