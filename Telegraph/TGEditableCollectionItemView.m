/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGEditableCollectionItemView.h"

#import "TGCollectionMenuView.h"
#import "TGEditingScrollView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

@interface TGEditableCollectionItemView () <TGEditingScrollViewDelegate>
{
    TGEditingScrollView *_editingScrollView;
    
    UIImageView *_deleteIndicator;
    UIButton *_actionButton;
    
    NSString *_optionText;
}

@end

@implementation TGEditableCollectionItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _enableEditing = true;
        
        _editingScrollView = [[TGEditingScrollView alloc] init];
        _editingScrollView.editingDelegate = self;
        [self addSubview:_editingScrollView];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_editingScrollView setOptionsAreRevealed:false];
}

- (UIView *)editingContentView
{
    return _editingScrollView;
}

- (NSString *)optionText
{
    if (_optionText == nil)
        _optionText = TGLocalized(@"Common.Delete");
    
    return _optionText;
}

- (void)setOptionText:(NSString *)optionText
{
    if (_actionButton != nil)
        [_actionButton setTitle:optionText forState:UIControlStateNormal];
    
    _optionText = optionText;
}

static TGCollectionMenuView *_findCollectionMenuView(UIView *baseView)
{
    if (baseView == nil || [baseView isKindOfClass:[TGCollectionMenuView class]])
        return (TGCollectionMenuView *)baseView;
    
    return _findCollectionMenuView(baseView.superview);
}

- (TGCollectionMenuView *)_collectionMenuView
{
    return _findCollectionMenuView(self.superview);
}

- (void)setDisableControls:(bool)disableControls {
    _disableControls = disableControls;
    _editingScrollView.userInteractionEnabled = !disableControls;
}

- (void)reorderSelfToFront
{
    int index = -1;
    int maxCellIndex = -1;
    int selfIndex = -1;
    for (UIView *sibling in self.superview.subviews)
    {
        index++;
        
        if ([sibling isKindOfClass:[TGCollectionItemView class]])
            maxCellIndex = MAX(index, maxCellIndex);
        if (sibling == self)
            selfIndex = index;
    }
    
    if (maxCellIndex != -1 && selfIndex != -1 && maxCellIndex != selfIndex)
        [self.superview exchangeSubviewAtIndex:maxCellIndex withSubviewAtIndex:selfIndex];
}

- (UIButton *)actionButton
{
    if (_actionButton == nil)
    {
        _actionButton = [[UIButton alloc] init];
        _actionButton.backgroundColor = _indicatorMode == TGEditableCollectionItemViewIndicatorAdd ? TGAccentColor() : TGDestructiveAccentColor();
        [_actionButton setTitle:self.optionText forState:UIControlStateNormal];
        [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _actionButton.titleLabel.font = TGSystemFontOfSize(18);
        [_actionButton addTarget:self action:@selector(optionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_actionButton];
    }
    
    return _actionButton;
}

- (void)setEnableEditing:(bool)enableEditing
{
    [self setEnableEditing:enableEditing animated:false];
}

- (void)setEnableEditing:(bool)enableEditing animated:(bool)animated
{
    if (_enableEditing != enableEditing)
    {
        _enableEditing = enableEditing;
        
        if (!_enableEditing)
            [_editingScrollView setOptionsAreRevealed:false animated:animated];
        
        _editingScrollView.disableScroll = !_enableEditing;
        
        if (_deleteIndicator != nil)
        {
            CGFloat deleteIndicatorAlpha = (_enableEditing && _showsDeleteIndicator) ? 1.0f : 0.0f;
            if (ABS(_deleteIndicator.alpha - deleteIndicatorAlpha) > FLT_EPSILON)
            {
                if (animated)
                {
                    [UIView animateWithDuration:0.3 animations:^
                    {
                        _deleteIndicator.alpha = deleteIndicatorAlpha;
                    }];
                }
                else
                    _deleteIndicator.alpha = deleteIndicatorAlpha;
            }
        }
    }
}

- (void)editingScrollViewOptionsOffsetChanged:(TGEditingScrollView *)__unused editingScrollView
{
    if (_editingScrollView.bounds.origin.x > FLT_EPSILON)
        [self actionButton];
    
    [self _layoutActionButton];
}

- (void)editingScrollViewWillRevealOptions:(TGEditingScrollView *)__unused editingScrollView
{
    [self reorderSelfToFront];
    
    [[self _collectionMenuView] _setEditingCell:self editing:true];
}

- (void)editingScrollViewDidHideOptions:(TGEditingScrollView *)__unused editingScrollView
{
    [[self _collectionMenuView] _setEditingCell:self editing:false];
}

- (void)setShowsDeleteIndicator:(bool)showsDeleteIndicator
{
    [self setShowsDeleteIndicator:showsDeleteIndicator animated:false];
}

- (void)setIndicatorMode:(TGEditableCollectionItemViewIndicator)indicatorMode {
    if (_indicatorMode != indicatorMode) {
        _indicatorMode = indicatorMode;
        if (_deleteIndicator != nil) {
            _deleteIndicator.image = _indicatorMode == TGEditableCollectionItemViewIndicatorAdd ? [UIImage imageNamed:@"ModernMenuAddIcon.png"] : [UIImage imageNamed:@"ModernMenuDeleteIcon.png"];
        }
        if (_actionButton != nil) {
            _actionButton.backgroundColor = _indicatorMode == TGEditableCollectionItemViewIndicatorAdd ? TGAccentColor() : TGDestructiveAccentColor();
        }
    }
}

- (void)setShowsDeleteIndicator:(bool)showsDeleteIndicator animated:(bool)animated
{
    if (_showsDeleteIndicator != showsDeleteIndicator)
    {
        if (_deleteIndicator == nil)
        {
            _deleteIndicator = [[UIImageView alloc] initWithImage:_indicatorMode == TGEditableCollectionItemViewIndicatorAdd ? [UIImage imageNamed:@"ModernMenuAddIcon.png"] : [UIImage imageNamed:@"ModernMenuDeleteIcon.png"]];
            _deleteIndicator.userInteractionEnabled = true;
            [_deleteIndicator addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteIndicatorTapGesture:)]];
            
            _deleteIndicator.alpha = 0.0f;
            [_editingScrollView addSubview:_deleteIndicator];
            [self _layoutDeleteIndicator];
        }
        
        _showsDeleteIndicator = showsDeleteIndicator;
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^
            {
                _deleteIndicator.alpha = _enableEditing && _showsDeleteIndicator ? 1.0f : 0.0f;
                [self layoutSubviews];
                
                if (!_showsDeleteIndicator)
                    [_editingScrollView setOptionsAreRevealed:false animated:false];
            } completion:nil];
        }
        else
        {
            _deleteIndicator.alpha = _enableEditing && _showsDeleteIndicator ? 1.0f : 0.0f;
            
            if (!_showsDeleteIndicator)
                [_editingScrollView setOptionsAreRevealed:false animated:false];
            
            [self setNeedsLayout];
        }
        
        _editingScrollView.lockScroll = showsDeleteIndicator;
        _editingScrollView.disableScroll = !_enableEditing;
    }
}

- (void)setShowsEditingOptions:(bool)showsEditingOptions animated:(bool)animated
{
    if (showsEditingOptions != _editingScrollView.optionsAreRevealed)
    {
        if (showsEditingOptions)
        {
            [self actionButton];
            [self _layoutActionButton];
        }
        
        if (showsEditingOptions || !animated)
        {
            [_editingScrollView setOptionsAreRevealed:true animated:animated];
        }
        else
        {
            [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^
            {
                [_editingScrollView setOptionsAreRevealed:false animated:false];
            } completion:nil];
        }
    }
}

- (void)_layoutDeleteIndicator
{
    CGSize deleteIndicatorSize = _deleteIndicator.bounds.size;
    _deleteIndicator.frame = CGRectMake((_showsDeleteIndicator ? 12.0f : -deleteIndicatorSize.width), CGFloor((self.bounds.size.height - deleteIndicatorSize.height) / 2.0f) + 1.0f, deleteIndicatorSize.width, deleteIndicatorSize.height);
}

- (void)_layoutActionButton
{
    CGRect bounds = _editingScrollView.bounds;
    CGFloat optionsWidth = [_editingScrollView optionsWidth];
    
    _actionButton.frame = CGRectMake(bounds.size.width - MIN(bounds.origin.x, optionsWidth), _optionsOffset.y, optionsWidth, bounds.size.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGFloat separatorHeight = TGScreenPixel;
    
    _editingScrollView.contentSize = CGSizeMake(bounds.size.width + 82.0f, bounds.size.height + separatorHeight);
    _editingScrollView.frame = CGRectMake(0.0f, 0.0f, bounds.size.width, bounds.size.height + separatorHeight);
    
    if (_deleteIndicator != nil)
        [self _layoutDeleteIndicator];
}

#pragma mark -

- (void)_requestSelection
{
    [[self _collectionMenuView] _selectCell:self];
}

#pragma mark -

- (void)deleteIndicatorTapGesture:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (_disableControls) {
            if (_customOpenControls) {
                _customOpenControls();
            }
        } else {
            [self actionButton];
            [self _layoutActionButton];
            
            [_editingScrollView setOptionsAreRevealed:true animated:true];
        }
    }
}

- (void)optionButtonPressed:(UIButton *)button
{
    if (button == _actionButton)
        [self deleteAction];
}

- (void)deleteAction
{
}

- (UIView *)hitTestDeleteIndicator:(CGPoint)point {
    if (_deleteIndicator != nil) {
        CGPoint converted = [self convertPoint:point toView:_deleteIndicator];
        if (CGRectContainsPoint(_deleteIndicator.bounds, converted)) {
            return _deleteIndicator;
        }
    }
    return nil;
}

@end
