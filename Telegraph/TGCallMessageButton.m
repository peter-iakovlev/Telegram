#import "TGCallMessageButton.h"

#import "TGFont.h"

@implementation TGCallMessageButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.adjustsImageWhenDisabled = false;
        self.adjustsImageWhenHighlighted = false;
        self.titleLabel.font = TGSystemFontOfSize(14.0f);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(floor((self.frame.size.width - self.imageView.frame.size.width) / 2.0f), floor((self.frame.size.height - self.imageView.frame.size.height) / 2.0f), self.imageView.frame.size.width, self.imageView.frame.size.height);
    
    [self.titleLabel sizeToFit];
    CGRect frame = self.titleLabel.frame;
    frame = CGRectMake(floor((self.frame.size.width - frame.size.width) / 2.0f), self.bounds.size.height - 5.0f, frame.size.width, frame.size.height);
    self.titleLabel.frame = frame;
}

@end
