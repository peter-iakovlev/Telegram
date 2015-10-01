#import "TGSharedMediaThumbnailItemView.h"

#import "TGImagePickerCellCheckButton.h"

#import "TGViewController.h"

@interface TGSharedMediaThumbnailItemView ()
{
    UIView *_checkButtonContainer;
    TGImagePickerCellCheckButton *_checkButton;
    
    UIGestureRecognizer *_tapRecognizer;
}

@end

@implementation TGSharedMediaThumbnailItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _checkButtonContainer = [[UIView alloc] init];
        [self.contentView addSubview:_checkButtonContainer];
        
        _checkButton = [[TGImagePickerCellCheckButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 33.0f, 33.0f)];
        [_checkButton setChecked:false animated:false];
        _checkButton.hidden = true;
        _checkButton.userInteractionEnabled = false;
        _checkButton.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        [_checkButtonContainer addSubview:_checkButton];
        
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        _tapRecognizer.enabled = false;
        _tapRecognizer.cancelsTouchesInView = true;
        [self.contentView addGestureRecognizer:_tapRecognizer];
    }
    return self;
}

- (void)setEditing:(bool)editing animated:(bool)animated delay:(NSTimeInterval)delay
{
    [super setEditing:editing animated:animated delay:delay];
    
    if (editing)
    {
        if (animated)
        {
            _checkButton.hidden = false;
            [UIView animateWithDuration:0.15 delay:delay options:[TGViewController preferredAnimationCurve] << 16 animations:^
            {
                _checkButton.transform = CGAffineTransformIdentity;
                _checkButton.alpha = 1.0f;
            } completion:nil];
        }
        else
        {
            _checkButton.hidden = false;
            _checkButton.transform = CGAffineTransformIdentity;
            _checkButton.alpha = 1.0f;
        }
    }
    else
    {
        if (animated)
        {
            [UIView animateWithDuration:0.25 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^
            {
                _checkButton.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
                _checkButton.alpha = 0.0f;
            } completion:^(BOOL finished)
            {
                if (finished)
                {
                    _checkButton.hidden = true;
                    _checkButton.alpha = 1.0f;
                }
            }];
        }
        else
        {
            _checkButton.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            _checkButton.hidden = true;
            _checkButton.alpha = 1.0f;
        }
    }
    
    _tapRecognizer.enabled = editing;
}

- (void)updateItemSelected
{
    [super updateItemSelected];
    
    [_checkButton setChecked:self.isItemSelected && self.item != nil && self.isItemSelected(self.item) animated:false];
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.toggleItemSelection && self.item != nil)
            self.toggleItemSelection(self.item);
        [_checkButton setChecked:self.isItemSelected && self.item != nil && self.isItemSelected(self.item) animated:true];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    _checkButtonContainer.frame = CGRectMake(frame.size.width - 33.0f - 0.0f, 1.0f, 33.0f, 33.0f);
}

@end
