#import "TGCollectionBottonDisclosureItem.h"

#import "TGCollectionBottonDisclosureItemView.h"
#import "TGModernTextViewModel.h"

#import "TGFont.h"
#import "TGReusableLabel.h"

@interface TGCollectionBottonDisclosureItem ()
{
    TGModernTextViewModel *_textModel;
}

@end

@implementation TGCollectionBottonDisclosureItem

- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text
{
    self = [super init];
    if (self != nil)
    {
        self.selectable = true;
        self.highlightable = true;
        self.deselectAutomatically = true;
        
        _title = title;
        _text = text;
        NSArray *attributes = @[];
        NSArray *textCheckingResults = nil;
        NSString *string = [TGCollectionBottonDisclosureItemView stringForText:text outAttributes:&attributes outTextCheckingResults:&textCheckingResults];
        _textModel = [[TGModernTextViewModel alloc] initWithText:string font:TGCoreTextSystemFontOfSize(15.0f)];
        _textModel.layoutFlags = TGReusableLabelLayoutMultiline;
        _textModel.additionalAttributes = attributes;
        _textModel.textCheckingResults = textCheckingResults;
    }
    return self;
}

- (Class)itemViewClass
{
    return [TGCollectionBottonDisclosureItemView class];
}

- (CGSize)itemSizeForContainerSize:(CGSize)containerSize
{
    CGSize baseSize = CGSizeMake(containerSize.width, 0.0f);
    baseSize.height += CGFloor([TGCollectionBottonDisclosureItemView title:_title sizeForWidth:containerSize.width].height+ 1.0f) + 24.0f;
    
    if (_expanded)
    {
        if ([_textModel layoutNeedsUpdatingForContainerSize:CGSizeMake(containerSize.width - 30.0f, CGFLOAT_MAX)])
            [_textModel layoutForContainerSize:CGSizeMake(containerSize.width - 30.0f, CGFLOAT_MAX)];
        
        baseSize.height += CGFloor(_textModel.frame.size.height + 1.0f);
        baseSize.height += 15.0f;
    }
    
    return baseSize;
}

- (void)bindView:(TGCollectionBottonDisclosureItemView *)view
{
    [super bindView:view];
    
    [view setTitle:_title textModel:_textModel expanded:_expanded followAnchor:_followAnchor];
}

- (void)itemSelected:(id)__unused actionTarget
{
    _expanded = !_expanded;
    [(TGCollectionBottonDisclosureItemView *)self.boundView setExpanded:_expanded];
    
    if (_expandedChanged)
        _expandedChanged(self);
}

@end
