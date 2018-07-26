#import "TGSharedMediaSelectionPanelView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGModernButton.h>

#import "TGPresentation.h"

@interface TGSharedMediaSelectionPanelView ()
{
    UIView *_separatorView;
    TGModernButton *_forwardButton;
    TGModernButton *_deleteButton;
    TGModernButton *_shareButton;
    UILabel *_label;
}

@end

@implementation TGSharedMediaSelectionPanelView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.backgroundColor = UIColorRGB(0xf7f7f7);
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = UIColorRGB(0xb2b2b2);
        [self addSubview:_separatorView];
        
        _forwardButton = [[TGModernButton alloc] init];
        _forwardButton.modernHighlight = true;
        _forwardButton.enabled = false;
        [_forwardButton addTarget:self action:@selector(forwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_forwardButton];
        
        _deleteButton = [[TGModernButton alloc] init];
        _deleteButton.modernHighlight = true;
        _deleteButton.enabled = false;
        [_deleteButton addTarget:self action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        
        _shareButton = [[TGModernButton alloc] init];
        _shareButton.modernHighlight = true;
        _shareButton.enabled = false;
        [_shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareButton];
    }
    return self;
}

- (void)setForwardEnabled:(bool)forwardEnabled
{
    _forwardEnabled = forwardEnabled;
    
    _forwardButton.hidden = !_forwardEnabled;
}

- (void)setDeleteEnabled:(bool)deleteEnabled {
    _deleteEnabled = deleteEnabled;
    
    _deleteButton.hidden = !_deleteEnabled;
}

- (void)setShareEnabled:(bool)shareEnabled {
    _shareEnabled = shareEnabled;
    
    _shareButton.hidden = !_shareEnabled;
}

- (void)setSelecterItemCount:(NSUInteger)selecterItemCount
{
    _selecterItemCount = selecterItemCount;

    _forwardButton.enabled = _selecterItemCount != 0;
    _deleteButton.enabled = _selecterItemCount != 0;
    _shareButton.enabled = _selecterItemCount != 0;
    
    if (_selecterItemCount == 0)
        _label.text = @"";
    else
    {
        _label.text = [[NSString alloc] initWithFormat:TGLocalized([TGStringUtils integerValueFormat:@"SharedMedia.ItemsSelected_" value:_selecterItemCount]), [[NSString alloc] initWithFormat:@"%d", (int)_selecterItemCount]];
    }
    [_label sizeToFit];
    [self layoutLabel];
}

- (void)setPresentation:(TGPresentation *)presentation
{
    _presentation = presentation;
    self.backgroundColor = presentation.pallete.barBackgroundColor;
    _separatorView.backgroundColor = presentation.pallete.barSeparatorColor;
    
    [_deleteButton setImage:presentation.images.chatEditDeleteIcon forState:UIControlStateNormal];
    [_deleteButton setImage:presentation.images.chatEditDeleteDisabledIcon forState:UIControlStateDisabled];
    
    [_forwardButton setImage:presentation.images.chatEditForwardIcon forState:UIControlStateNormal];
    [_forwardButton setImage:presentation.images.chatEditForwardDisabledIcon forState:UIControlStateDisabled];
    
    [_shareButton setImage:presentation.images.chatEditShareIcon forState:UIControlStateNormal];
    [_shareButton setImage:presentation.images.chatEditShareDisabledIcon forState:UIControlStateDisabled];
}

- (void)forwardButtonPressed
{
    if (_forwardSelectedItems)
        _forwardSelectedItems();
}

- (void)deleteButtonPressed
{
    if (_deleteSelectedItems)
        _deleteSelectedItems();
}

- (void)shareButtonPressed
{
    if (_shareSelectedItems)
        _shareSelectedItems();
}

- (void)layoutLabel
{
    _label.frame = CGRectMake(CGFloor((self.frame.size.width - _label.frame.size.width) / 2.0f), CGFloor((45.0f - _label.frame.size.height) / 2.0f) + 1.0f, _label.frame.size.width, _label.frame.size.height);
}

- (void)setSafeAreaInset:(UIEdgeInsets)safeAreaInset
{
    _safeAreaInset = safeAreaInset;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    _separatorView.frame = CGRectMake(0.0f, 0.0f, frame.size.width, TGScreenPixel);
    _forwardButton.frame = CGRectMake(frame.size.width - 56.0f - _safeAreaInset.right, TGScreenPixel, 56.0f, 44.0f);
    _deleteButton.frame = CGRectMake(_safeAreaInset.left, TGScreenPixel, 52.0f, 44.0f);
    _shareButton.frame = CGRectMake(floor((self.frame.size.width - 56.0f) / 2.0f), 0.0f, 56.0f, 44.0f);
    
    [self layoutLabel];
}

@end
