#import "TGImagePickerCellCheckButton.h"

static UIImage *checkImageNormal()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"ImagePickerThumbnalSelect.png"];
    return image;
}

static UIImage *checkImageChecked()
{
    static UIImage *image = nil;
    if (image == nil)
        image = [UIImage imageNamed:@"ImagePickerThumbnalSelect_Checked.png"];
    return image;
}

@implementation TGImagePickerCellCheckButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _checkView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [self addSubview:_checkView];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _checkView.transform = CGAffineTransformIdentity;
    
    [super touchesCancelled:touches withEvent:event];
}

- (void)setChecked:(bool)checked animated:(bool)animated
{
    _checkView.image = checked ? checkImageChecked() : checkImageNormal();
    
    if (animated)
    {
        _checkView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
        if (checked)
        {
            [UIView animateWithDuration:0.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
             {
                 _checkView.transform = CGAffineTransformMakeScale(1.16, 1.16f);
             } completion:^(BOOL finished)
             {
                 if (finished)
                 {
                     [UIView animateWithDuration:0.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
                      {
                          _checkView.transform = CGAffineTransformIdentity;
                      } completion:nil];
                 }
             }];
        }
        else
        {
            [UIView animateWithDuration:0.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
             {
                 _checkView.transform = CGAffineTransformIdentity;
             } completion:nil];
        }
    }
    else
    {
        _checkView.transform = CGAffineTransformIdentity;
    }
}

@end
