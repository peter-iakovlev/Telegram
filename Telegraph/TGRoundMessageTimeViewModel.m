#import "TGRoundMessageTimeViewModel.h"
#import "TGRoundMessageTimeView.h"

@interface TGRoundMessageTimeViewModel ()
{
    UIFont *_font;
    UIColor *_textColor;
    
    NSString *_time;
}
@end

@implementation TGRoundMessageTimeViewModel

- (instancetype)initWithFont:(UIFont *)font textColor:(UIColor *)textColor
{
    self = [super init];
    if (self != nil)
    {
        _font = font;
        _textColor = textColor;
    }
    return self;
}

- (Class)viewClass
{
    return [TGRoundMessageTimeView class];
}

- (void)setTime:(NSString *)time
{
    _time = time;
    [(TGRoundMessageTimeView *)[self boundView] setText:_time];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    TGRoundMessageTimeView *view = (TGRoundMessageTimeView *)[self boundView];
    [view setFont:_font];
    [view setTextColor:_textColor];
    [view setText:_time];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [super unbindView:viewStorage];
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    CGRect frame = self.frame;
    frame.size = [@"8:8:88" sizeWithFont:_font constrainedToSize:containerSize];
    frame.size.width = CGFloor(frame.size.width);
    frame.size.height = CGFloor(frame.size.height);
    self.frame = frame;
}


@end
