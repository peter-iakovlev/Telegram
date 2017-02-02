#import "TGCallRatingView.h"

@implementation TGCallRatingView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 210, 38)];
    if (self != nil)
    {
        for (NSInteger i = 0; i < 5; i++)
        {
            UIButton *starButton = [[UIButton alloc] initWithFrame:CGRectMake(42.0f * i, 0, 42.0f, 38.0f)];
            starButton.tag = i;
            starButton.adjustsImageWhenDisabled = false;
            starButton.adjustsImageWhenHighlighted = false;
            starButton.contentMode = UIViewContentModeCenter;
            [starButton setImage:[UIImage imageNamed:@"CallStar"] forState:UIControlStateNormal];
            [starButton setImage:[UIImage imageNamed:@"CallStar_Highlighted"] forState:UIControlStateSelected];
            [starButton setImage:[UIImage imageNamed:@"CallStar_Highlighted"] forState:UIControlStateSelected | UIControlStateHighlighted];
            [starButton addTarget:self action:@selector(starPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:starButton];
        }
    }
    return self;
}

- (void)starPressed:(UIButton *)sender
{
    _selectedStars = sender.tag + 1;
    
    for (UIButton *button in self.subviews)
    {
        button.selected = button.tag < _selectedStars;
    }
    
    if (self.onStarsSelected != nil)
        self.onStarsSelected();
}

@end
