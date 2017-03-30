#import "TGAttachmentSheetItemView.h"

#import "TGImageUtils.h"

@interface TGAttachmentSheetItemView ()
{
    UIView *_topSeparatorView;
    UIView *_bottomSeparatorView;
}

@end

@implementation TGAttachmentSheetItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _topSeparatorView = [[UIView alloc] init];
        _topSeparatorView.backgroundColor = TGSeparatorColor();
        [self addSubview:_topSeparatorView];
        
        _bottomSeparatorView = [[UIView alloc] init];
        _bottomSeparatorView.backgroundColor = TGSeparatorColor();
        [self addSubview:_bottomSeparatorView];
    }
    return self;
}

- (CGFloat)preferredHeight
{
    return 50.0f;
}

- (bool)wantsFullSeparator
{
    return false;
}

- (void)sheetDidAppear
{
    
}

- (void)sheetWillDisappear
{
    
}

- (void)setShowsTopSeparator:(bool)showsTopSeparator
{
    _showsTopSeparator = showsTopSeparator;
    _topSeparatorView.hidden = !showsTopSeparator;
}

- (void)setShowsBottomSeparator:(bool)showsBottomSeparator
{
    _showsBottomSeparator = showsBottomSeparator;
    _bottomSeparatorView.hidden = !showsBottomSeparator;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat separatorHeight = TGScreenPixel;
    CGFloat separatorInset = [self wantsFullSeparator] ? 0.0f : 15.0f;
    _topSeparatorView.frame = CGRectMake(separatorInset, 0.0f, self.frame.size.width - separatorInset, separatorHeight);
    _bottomSeparatorView.frame = CGRectMake(separatorInset, self.frame.size.height - separatorHeight, self.frame.size.width - separatorInset, separatorHeight);
}

@end
