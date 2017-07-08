/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGGroupInfoUserCollectionItemView.h"

#import "TGImageUtils.h"
#import "TGFont.h"

#import "TGUser.h"

#import "TGLetteredAvatarView.h"

#import "TGDialogListCellEditingControls.h"

#import "TGCollectionMenuView.h"

@interface TGGroupInfoUserCollectionItemViewContent : UIView

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *label;
@property (nonatomic) bool editing;
@property (nonatomic) bool statusIsActive;
@property (nonatomic) bool isSecretChat;

@end

@implementation TGGroupInfoUserCollectionItemViewContent

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        self.contentMode = UIViewContentModeLeft;
        self.opaque = false;
    }
    return self;
}

- (void)drawRect:(CGRect)__unused rect
{
    static UIFont *regularNameFont = nil;
    static UIFont *boldNameFont = nil;
    static CGColorRef nameColor = NULL;
    static CGColorRef secretNameColor = NULL;
    
    static UIFont *statusFont = nil;
    static dispatch_once_t onceToken;
    static CGColorRef activeStatusColor = NULL;
    static CGColorRef regularStatusColor = NULL;
    dispatch_once(&onceToken, ^
    {
        regularNameFont = TGSystemFontOfSize(17.0f);
        boldNameFont = TGMediumSystemFontOfSize(17.0f);
        statusFont = TGSystemFontOfSize(13.0f);
        
        nameColor = CGColorRetain([UIColor blackColor].CGColor);
        secretNameColor = CGColorRetain(UIColorRGB(0x00a629).CGColor);
        activeStatusColor = CGColorRetain(TGAccentColor().CGColor);
        regularStatusColor = CGColorRetain(UIColorRGB(0xb3b3b3).CGColor);
    });
    
    CGRect bounds = self.bounds;
    CGFloat availableWidth = bounds.size.width - 20.0f - 1.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGSize firstNameSize = [_firstName sizeWithFont:regularNameFont];
    CGSize lastNameSize = [_lastName sizeWithFont:boldNameFont];
    CGFloat nameSpacing = 4.0f;
    
    CGSize labelSize = [_label sizeWithFont:statusFont];
    
    if (!self.editing) {
        if (_label.length != 0) {
            CGContextSetFillColorWithColor(context, regularStatusColor);
            [_label drawAtPoint:CGPointMake(availableWidth - labelSize.width + 6.0f, 11.0f + TGRetinaPixel) withFont:statusFont];
        }
    }
    
    availableWidth -= labelSize.width;
    
    firstNameSize.width = MIN(firstNameSize.width, availableWidth - 30.0f);
    lastNameSize.width = MIN(lastNameSize.width, availableWidth - nameSpacing - firstNameSize.width);
    
    CGContextSetFillColorWithColor(context, _isSecretChat ? secretNameColor : nameColor);
    [_firstName drawInRect:CGRectMake(1.0f, 1.0f, firstNameSize.width, firstNameSize.height) withFont:regularNameFont lineBreakMode:NSLineBreakByTruncatingTail];
    [_lastName drawInRect:CGRectMake(1.0f + firstNameSize.width + nameSpacing, TGRetinaPixel, lastNameSize.width, lastNameSize.height) withFont:boldNameFont lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize statusSize = [_status sizeWithFont:statusFont];
    CGContextSetFillColorWithColor(context, _statusIsActive ? activeStatusColor : regularStatusColor);
    [_status drawInRect:CGRectMake(1.0f, 23.0f - TGRetinaPixel, MIN(statusSize.width, availableWidth), statusSize.height) withFont:statusFont lineBreakMode:NSLineBreakByTruncatingTail];
}

@end

@interface TGGroupInfoUserCollectionItemView ()
{
    int32_t _uidForPlaceholderCalculation;
    TGLetteredAvatarView *_avatarView;
    TGGroupInfoUserCollectionItemViewContent *_content;
    UISwitch *_switchView;
    UIImageView *_checkView;
    
    UIView *_disabledOverlayView;
    bool _requiresFullSeparator;
    
    TGDialogListCellEditingControls *_wrapView;
}

@end

@implementation TGGroupInfoUserCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _wrapView = [[TGDialogListCellEditingControls alloc] init];
        
        _wrapView.clipsToBounds = true;
        [_wrapView setLabelOnly:true];
        [_wrapView setOffsetLabels:true];
        [self.contentView addSubview:_wrapView];
        
        _avatarView = [[TGLetteredAvatarView alloc] init];
        [_avatarView setSingleFontSize:18.0f doubleFontSize:18.0f useBoldFont:true];
        _avatarView.fadeTransition = true;
        [_wrapView addSubview:_avatarView];
        
        _content = [[TGGroupInfoUserCollectionItemViewContent alloc] init];
        
        [self.editingContentView removeFromSuperview];
        
        [_wrapView addSubview:_content];
        [_wrapView addSubview:self.editingContentView];
        
        self.disableControls = true;
        __weak TGGroupInfoUserCollectionItemView *weakSelf = self;
        self.customOpenControls = ^{
            __strong TGGroupInfoUserCollectionItemView *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_wrapView setExpanded:true animated:true];
            }
        };
        
        _wrapView.requestDelete = ^{
            __strong TGGroupInfoUserCollectionItemView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_requestDelete) {
                [strongSelf setShowsEditingOptions:false animated:true];
                strongSelf->_requestDelete();
            }
        };
        
        _wrapView.requestPromote = ^{
            __strong TGGroupInfoUserCollectionItemView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_requestPromote) {
                [strongSelf setShowsEditingOptions:false animated:true];
                strongSelf->_requestPromote();
            }
        };
        
        _wrapView.requestRestrict = ^{
            __strong TGGroupInfoUserCollectionItemView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_requestRestrict) {
                [strongSelf setShowsEditingOptions:false animated:true];
                strongSelf->_requestRestrict();
            }
        };
        
        _wrapView.expandedUpdated = ^(bool value) {
            __strong TGGroupInfoUserCollectionItemView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_requestRestrict) {
                [[strongSelf _collectionMenuView] _setEditingCell:strongSelf editing:value];
            }
        };
    }
    return self;
}

- (void)prepareForReuse
{
    [_wrapView setExpanded:false animated:false];
    
    [super prepareForReuse];
}

- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName uidForPlaceholderCalculation:(int32_t)uidForPlaceholderCalculation canPromote:(bool)canPromote canRestrict:(bool)canRestrict canBan:(bool)canBan canDelete:(bool)canDelete
{
    if (firstName.length != 0)
    {
        _content.firstName = firstName;
        _content.lastName = lastName;
    }
    else
    {
        _content.firstName = lastName;
        _content.lastName = nil;
    }
    
    _uidForPlaceholderCalculation = uidForPlaceholderCalculation;
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    if (canPromote) {
        [actions addObject:@(TGDialogListCellEditingControlsPromote)];
    }
    if (canRestrict) {
        [actions addObject:@(TGDialogListCellEditingControlsRestrict)];
    }
    if (canBan) {
        [actions addObject:@(TGDialogListCellEditingControlsBan)];
    }
    if (canDelete) {
        [actions addObject:@(TGDialogListCellEditingControlsDelete)];
    }
    [_wrapView setSmallLabels:actions.count > 1];
    [_wrapView setButtonBytes:actions];
    
    [_content setNeedsDisplay];
}

- (void)setStatus:(NSString *)status active:(bool)active
{
    if (!TGStringCompare(_content.status, status) || _content.statusIsActive != active)
    {
        _content.status = status;
        _content.statusIsActive = active;
        [_content setNeedsDisplay];
    }
}

- (void)setAvatarUri:(NSString *)avatarUri
{
    static UIImage *placeholder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(40.0f, 40.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //!placeholder
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, 40.0f, 40.0f));
        CGContextSetStrokeColorWithColor(context, UIColorRGB(0xd9d9d9).CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, 39.0f, 39.0f));
        
        placeholder = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    if (avatarUri.length == 0)
        [_avatarView loadUserPlaceholderWithSize:CGSizeMake(40.0f, 40.0f) uid:_uidForPlaceholderCalculation firstName:_content.firstName lastName:_content.lastName placeholder:placeholder];
    else if (!TGStringCompare([_avatarView currentUrl], avatarUri))
        [_avatarView loadImage:avatarUri filter:@"circle:40x40" placeholder:placeholder];
}

- (void)setIsSecretChat:(bool)isSecretChat
{
    if (_content.isSecretChat != isSecretChat)
    {
        _content.isSecretChat = isSecretChat;
        [_content setNeedsDisplay];
    }
}

- (void)setCustomLabel:(NSString *)customLabel {
    if (!TGStringCompare(customLabel, _content.label)) {
        _content.label = customLabel;
        [_content setNeedsDisplay];
    }
}

- (void)setDisplaySwitch:(bool)displaySwitch {
    if (displaySwitch && _switchView == nil) {
        _switchView = [[UISwitch alloc] init];
        _switchView.layer.allowsGroupOpacity = true;
        [_switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    if (displaySwitch) {
        if (_switchView.superview == nil) {
            [self addSubview:_switchView];
            [self setNeedsLayout];
        }
    } else {
        if (_switchView.superview != nil) {
            [_switchView removeFromSuperview];
        }
    }
}

- (void)switchValueChanged {
    id<TGGroupInfoUserCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(switchValueChanged:)]) {
        [delegate switchValueChanged:_switchView.on];
    }
}

- (void)setEnableSwitch:(bool)enableSwitch animated:(bool)animated {
    _switchView.userInteractionEnabled = enableSwitch;
    if (animated) {
         [UIView animateWithDuration:0.3 animations:^{
            _switchView.alpha = enableSwitch ? 1.0f : 0.4f;
         }];
    } else {
        _switchView.alpha = enableSwitch ? 1.0f : 0.4f;
    }
}

- (void)setSwitchIsOn:(bool)switchIsOn animated:(bool)animated {
    if (switchIsOn != _switchView.isOn) {
        [_switchView setOn:switchIsOn animated:animated];
    }
}

- (void)setDisplayCheck:(bool)displayCheck {
    if (displayCheck && _checkView == nil) {
        _checkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ModernMenuCheck.png"]];
    }
    if (displayCheck) {
        if (_checkView.superview == nil) {
            [self addSubview:_checkView];
            [self setNeedsLayout];
        }
    } else {
        if (_checkView.superview != nil) {
            [_checkView removeFromSuperview];
        }
    }
}

- (void)setCheckIsOn:(bool)checkIsOn {
    _checkView.hidden = !checkIsOn;
}

- (void)setRequiresFullSeparator:(bool)requiresFullSeparator {
    _requiresFullSeparator = requiresFullSeparator;
    self.separatorInset = requiresFullSeparator ? 0.0f : 65.0f;
}

- (void)setDisabled:(bool)disabled animated:(bool)animated
{
    if (disabled)
    {
        if (_disabledOverlayView == nil)
        {
            _disabledOverlayView = [[UIView alloc] init];
            _disabledOverlayView.backgroundColor = UIColorRGBA(0xffffff, 0.7f);
            _disabledOverlayView.alpha = 0.0f;
            _disabledOverlayView.userInteractionEnabled = false;
            [self addSubview:_disabledOverlayView];
            [self setNeedsLayout];
        }
        
        if (animated)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                _disabledOverlayView.alpha = 1.0f;
            }];
        }
        else
            _disabledOverlayView.alpha = 1.0f;
    }
    else if (_disabledOverlayView != nil)
    {
        if (animated)
        {
            UIView *view = _disabledOverlayView;
            _disabledOverlayView = nil;
            
            [UIView animateWithDuration:0.3 animations:^
            {
                view.alpha = 0.0f;
            } completion:^(__unused BOOL finished)
            {
                [view removeFromSuperview];
            }];
        }
        else
        {
            [_disabledOverlayView removeFromSuperview];
            _disabledOverlayView = nil;
        }
    }
}

- (void)layoutSubviews
{
    CGFloat contentOffset = self.contentView.frame.origin.x;
    [_wrapView setExpandable:contentOffset <= FLT_EPSILON];
    
    CGSize size = self.bounds.size;
    
    _wrapView.frame = CGRectMake(contentOffset, 0.0f, size.width, size.height);
    
    CGFloat leftInset = 0.0f;
    
    if (self.showsDeleteIndicator) {
        leftInset = 38.0f;
    }
    
    if (self.showsDeleteIndicator != _content.editing) {
        _content.editing = self.showsDeleteIndicator;
        [_content setNeedsDisplay];
    }
    
    if (_requiresFullSeparator) {
        self.separatorInset = 0.0f;
    } else {
        self.separatorInset = 65.0f + leftInset;
    }
    
    CGFloat rightInset = 0.0f;
    if (_switchView != nil && _switchView.superview != nil) {
        rightInset = _switchView.frame.size.width + 20.0f;
        
        CGSize switchSize = _switchView.bounds.size;
        _switchView.frame = CGRectMake(self.bounds.size.width - switchSize.width - 15.0f, 6.0f, switchSize.width, switchSize.height);
    }
    
    if (_checkView != nil && _checkView.superview != nil) {
        rightInset = _checkView.frame.size.width + 22.0f;
        
        CGSize checkSize = _checkView.frame.size;
        _checkView.frame = CGRectMake(self.bounds.size.width - 15.0f - checkSize.width, 16.0f, checkSize.width, checkSize.height);
    }
    
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    if (_disabledOverlayView != nil)
        [_disabledOverlayView setFrame:CGRectInset(bounds, 0.0f, 1.0f)];
    
    _avatarView.frame = CGRectMake(leftInset + 14.0f, 4.0f + TGRetinaPixel, 40.0f, 40.0f);
    
    CGRect contentFrame = CGRectMake(65.0f + leftInset, 4.0f, bounds.size.width - 65.0f - rightInset, bounds.size.height - 8.0f);
    if (!CGSizeEqualToSize(_content.frame.size, contentFrame.size))
        [_content setNeedsDisplay];
    _content.frame = contentFrame;
}

#pragma mark -

- (void)deleteAction
{
    //[self setShowsEditingOptions:false animated:true];
    
    id<TGGroupInfoUserCollectionItemViewDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(groupInfoUserItemViewRequestedDeleteAction:)])
        [delegate groupInfoUserItemViewRequestedDeleteAction:self];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *indicator = [(TGEditableCollectionItemView *)self hitTestDeleteIndicator:point];
    if (indicator != nil) {
        return indicator;
    }
    return [super hitTest:point withEvent:event];
}

- (void)setShowsEditingOptions:(bool)showsEditingOptions animated:(bool)animated {
    [super setShowsEditingOptions:showsEditingOptions animated:animated];
    
    [_wrapView setExpanded:showsEditingOptions animated:animated];
}

@end
