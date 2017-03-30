#import "TGWallpaperItemsBackgroundDecorationView.h"

#import "TGImageUtils.h"

@interface TGWallpaperItemsBackgroundDecorationView ()
{
    UIView *_topSeparatorView;
    UIView *_bottomSeparatorView;
}

@end

@implementation TGWallpaperItemsBackgroundDecorationView

+ (NSString *)kind
{
    return @"TGWallpaperItemsBackgroundDecorationView";
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat separatorHeight = TGScreenPixel;
        
        _topSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, separatorHeight)];
        _topSeparatorView.backgroundColor = TGSeparatorColor();
        [self addSubview:_topSeparatorView];
        
        _bottomSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - separatorHeight, frame.size.width, separatorHeight)];
        _bottomSeparatorView.backgroundColor = TGSeparatorColor();
        [self addSubview:_bottomSeparatorView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    CGFloat separatorHeight = TGScreenPixel;
    
    _topSeparatorView.frame = CGRectMake(0.0f, 0.0f, frame.size.width, separatorHeight);
    _bottomSeparatorView.frame = CGRectMake(0.0f, frame.size.height - separatorHeight, frame.size.width, separatorHeight);
}

@end
