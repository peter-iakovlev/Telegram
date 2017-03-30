#import "TGSharedMediaLinkItemView.h"

#import "TGMessage.h"
#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGModernFlatteningViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGModernViewStorage.h"
#import "TGReusableLabel.h"
#import "TGImageView.h"
#import "TGModernButton.h"
#import "TGActionSheet.h"
#import "TGAppDelegate.h"
#import "TGSharedMediaCheckButton.h"

@interface TGSharedMediaLinkItemView ()
{
    TGMessage *_message;
    NSArray *_links;
    TGWebPageMediaAttachment *_webPage;
    
    UIView *_separatorView;
    UILabel *_titleLabel;
    TGImageView *_imageView;
    UIImageView *_alternativeImageBackgroundView;
    UILabel *_alternativeImageLabel;
    
    TGModernFlatteningViewModel *_contentModel;
    TGModernTextViewModel *_textModel;
    TGModernViewStorage *_viewStorage;
    
    NSArray *_linkButtons;
    
    CGFloat _lastWidth;
    
    TGSharedMediaCheckButton *_checkButton;
    UIGestureRecognizer *_tapRecognizer;
}

@end

@implementation TGSharedMediaLinkItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TGSeparatorColor();
        [self.contentView addSubview:_separatorView];
        
        self.selectedBackgroundView = [[UIView alloc] init];
        self.selectedBackgroundView.backgroundColor = TGSelectionColor();
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = TGMediumSystemFontOfSize(15.0f);
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_titleLabel];
        
        _viewStorage = [[TGModernViewStorage alloc] init];
        _contentModel = [[TGModernFlatteningViewModel alloc] initWithContext:nil];
        
        [_contentModel bindViewToContainer:self.contentView viewStorage:_viewStorage];
        
        static UIImage *alternativeImageBackground = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            CGFloat diameter = 4.0;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColorRGB(0xdfdfdf).CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, diameter, diameter));
            alternativeImageBackground = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)(diameter / 2.0) topCapHeight:(NSInteger)(diameter / 2.0)];
            UIGraphicsEndImageContext();
        });
        
        _alternativeImageBackgroundView = [[UIImageView alloc] initWithImage:alternativeImageBackground];
        [self.contentView addSubview:_alternativeImageBackgroundView];
        _alternativeImageLabel = [[UILabel alloc] init];
        _alternativeImageLabel.backgroundColor = [UIColor clearColor];
        _alternativeImageLabel.font = TGSystemFontOfSize(25.0f);
        _alternativeImageLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_alternativeImageLabel];
        
        _imageView = [[TGImageView alloc] init];
        [self.contentView addSubview:_imageView];
        
        _checkButton = [[TGSharedMediaCheckButton alloc] init];
        _checkButton.userInteractionEnabled = false;
        [self.contentView addSubview:_checkButton];
        
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        _tapRecognizer.enabled = false;
        _tapRecognizer.cancelsTouchesInView = true;
        [self.contentView addGestureRecognizer:_tapRecognizer];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [_imageView reset];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted)
    {
        UIView *topSibling = nil;
        for (UIView *view in self.superview.subviews.reverseObjectEnumerator)
        {
            if (view != self)
            {
                topSibling = view;
                break;
            }
        }
        if (topSibling != nil)
        {
            [self.superview exchangeSubviewAtIndex:[self.superview.subviews indexOfObject:self] withSubviewAtIndex:[self.superview.subviews indexOfObject:topSibling]];
        }
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected)
    {
        UIView *topSibling = nil;
        for (UIView *view in self.superview.subviews.reverseObjectEnumerator)
        {
            if (view != self)
            {
                topSibling = view;
                break;
            }
        }
        if (topSibling != nil)
        {
            [self.superview exchangeSubviewAtIndex:[self.superview.subviews indexOfObject:self] withSubviewAtIndex:[self.superview.subviews indexOfObject:topSibling]];
        }
    }
}

- (NSString *)capitalizeTitle:(NSString *)title
{
    if (title.length == 0)
        return @"";
    else if (title.length == 1)
        return [title capitalizedString];
    else
        return [[[title substringToIndex:1] capitalizedString] stringByAppendingString:[title substringFromIndex:1]];
}

- (void)setMessage:(TGMessage *)message date:(int)__unused date lastInSection:(bool)__unused lastInSection textModel:(TGModernTextViewModel *)textModel imageSignal:(SSignal *)imageSignal links:(NSArray *)links webPage:(TGWebPageMediaAttachment *)webPage
{
    _separatorView.hidden = false;
    
    _message = message;
    _links = links;
    _webPage = webPage;
    
    NSString *host = nil;
    if (links.count != 0)
    {
        NSURL *url = [NSURL URLWithString:links[0]];
        if (url != nil)
        {
            host = url.host;
            NSRange lastDot = [host rangeOfString:@"." options:NSBackwardsSearch];
            if (lastDot.location != NSNotFound)
            {
                NSRange previousDot = [host rangeOfString:@"." options:NSBackwardsSearch range:NSMakeRange(0, lastDot.location - 1)];
                if (previousDot.location == NSNotFound)
                    host = [host substringToIndex:lastDot.location];
                else
                {
                    host = [host substringWithRange:NSMakeRange(previousDot.location + 1, lastDot.location - previousDot.location - 1)];
                }
            }
        }
    }
    
    NSString *title = webPage.title;
    if (title == nil && host.length != 0)
        title = [self capitalizeTitle:host];
    
    if (title == nil)
        title = message.text;
    
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    
    [_contentModel removeSubmodel:_textModel viewStorage:nil];
    _textModel = textModel;
    [_contentModel addSubmodel:textModel];
    
    _lastWidth = self.contentView.frame.size.width;
    [_contentModel setNeedsSubmodelContentsUpdate];
    
    [_imageView setSignal:imageSignal];
    
    if (imageSignal == nil)
    {
        _imageView.hidden = true;
        _alternativeImageLabel.hidden = false;
        if (host.length >= 1)
            _alternativeImageLabel.text = [[host substringToIndex:1] uppercaseString];
        else
            _alternativeImageLabel.text = @"";
        [_alternativeImageLabel sizeToFit];
    }
    else
    {
        _imageView.hidden = false;
        _alternativeImageLabel.hidden = true;
    }
    
    for (UIView *view in _linkButtons)
    {
        [view removeFromSuperview];
    }
    
    NSMutableArray *linkButtons = [[NSMutableArray alloc] init];
    for (NSString *link in _links)
    {
        TGModernButton *button = [[TGModernButton alloc] init];
        [button setTitleColor:TGAccentColor()];
        [button setTitle:link forState:UIControlStateNormal];
        button.extendedEdgeInsets = UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f);
        button.titleLabel.font = TGSystemFontOfSize(13.0f);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [button addTarget:self action:@selector(linkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        button.userInteractionEnabled = !self.editing;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.cancelsTouchesInView = true;
        [button addGestureRecognizer:longPress];
        
        [self.contentView addSubview:button];
        [linkButtons addObject:button];
    }
    _linkButtons = linkButtons;
    
    [self setNeedsLayout];
}

- (CGFloat)editingInset
{
    return 44.0f;
}

- (void)setEditing:(bool)editing animated:(bool)animated delay:(NSTimeInterval)delay
{
    [super setEditing:editing animated:animated delay:delay];
    
    if (animated)
    {
        [UIView animateWithDuration:0.3 delay:delay options:[TGViewController preferredAnimationCurve] << 16 animations:^
         {
             [self layoutSubviews];
         } completion:nil];
    }
    
    for (TGModernButton *button in _linkButtons)
    {
        button.userInteractionEnabled = !self.editing;
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
    
    CGFloat separatorHeight = TGScreenPixel;
    UIEdgeInsets insets = UIEdgeInsetsMake(8.0f, 65.0f, 6.0f, 10.0f);
    CGFloat editingOffset = self.editing ? [self editingInset] : 0.0f;
    
    _separatorView.frame = CGRectMake(insets.left + editingOffset, self.frame.size.height - separatorHeight, self.frame.size.width - insets.left - editingOffset, separatorHeight);
    
    self.selectedBackgroundView.frame = CGRectMake(0.0f, -separatorHeight, self.frame.size.width, self.frame.size.height + separatorHeight);
    
    CGSize titleSize = [_titleLabel.text sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - insets.left - insets.right - 1.0f, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    titleSize.width = CGCeil(titleSize.width);
    titleSize.height = MIN(21.0f, CGCeil(titleSize.height));
    _titleLabel.frame = CGRectMake(editingOffset + insets.left + 1.0f, insets.top + TGRetinaPixel, titleSize.width, titleSize.height);
    
    _contentModel.frame = CGRectMake(editingOffset + insets.left + 1.0f, insets.top + titleSize.height + 1.0f, _textModel.frame.size.width, _textModel.frame.size.height + 2.0f);
    
    if (ABS(_lastWidth - self.contentView.frame.size.width) > FLT_EPSILON)
    {
        _lastWidth = self.contentView.frame.size.width;
        [_contentModel setNeedsSubmodelContentsUpdate];
    }
    [_contentModel updateSubmodelContentsIfNeeded];
    
    _imageView.frame = CGRectMake(editingOffset + 9.0f, 12.0f, 42.0f, 42.0f);
    _alternativeImageBackgroundView.frame = _imageView.frame;
    _alternativeImageLabel.frame = CGRectMake(_imageView.frame.origin.x + CGFloor((_imageView.frame.size.width - _alternativeImageLabel.frame.size.width) / 2.0f), _imageView.frame.origin.y + CGFloor((_imageView.frame.size.height - _alternativeImageLabel.frame.size.height) / 2.0f), _alternativeImageLabel.frame.size.width, _alternativeImageLabel.frame.size.height);
    
    CGFloat startY = CGRectGetMaxY(_contentModel.frame) - 3.0f;
    if (_textModel.frame.size.height < FLT_EPSILON)
        startY += 3.0f;
    CGFloat buttonHeight = 20.0f;
    for (TGModernButton *button in _linkButtons)
    {
        CGSize buttonSize = [[button titleForState:UIControlStateNormal] sizeWithFont:button.titleLabel.font];
        button.frame = CGRectMake(editingOffset + insets.left + 1.0f, startY, MIN(self.bounds.size.width - insets.left - insets.right, buttonSize.width), buttonHeight);
        startY += buttonHeight;
    }
    
    _checkButton.frame = CGRectMake(self.editing ? 14.0f : -100.0f, CGFloor((self.bounds.size.height - 24.0f) / 2.0f), 24.0f, 24.0f);
}

- (void)linkButtonPressed:(TGModernButton *)button
{
    NSInteger index = -1;
    for (TGModernButton *listButton in _linkButtons)
    {
        index++;
        if (listButton == button)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_links[index]]];
            
            break;
        }
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    if (!self.editing) {
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            NSInteger index = -1;
            for (TGModernButton *listButton in _linkButtons)
            {
                index++;
                if (listButton == recognizer.view)
                {
                    [self showActionsMenuForLink:_links[index]];
                    
                    break;
                }
            }
        }
    }
}

- (void)showActionsMenuForLink:(NSString *)url
{
    if ([url hasPrefix:@"tel:"])
    {
        TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:url.length < 70 ? url : [[url substringToIndex:70] stringByAppendingString:@"..."] actions:@[
               [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.Call") action:@"call"],
               [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogCopy") action:@"copy"],
               [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
           ] actionBlock:^(__unused id controller, NSString *action)
        {
            if ([action isEqualToString:@"call"])
            {
                [TGAppDelegateInstance performPhoneCall:[NSURL URLWithString:url]];
            }
            else if ([action isEqualToString:@"copy"])
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                if (pasteboard != nil)
                {
                    NSString *copyString = url;
                    if ([url hasPrefix:@"mailto:"])
                        copyString = [url substringFromIndex:7];
                    else if ([url hasPrefix:@"tel:"])
                        copyString = [url substringFromIndex:4];
                    [pasteboard setString:copyString];
                }
            }
        } target:self];
        UIView *alertViewHost = _alertViewHost;
        [actionSheet showInView:alertViewHost];
    }
    else
    {
        NSString *displayString = url;
        if ([url hasPrefix:@"hashtag://"])
            displayString = [@"#" stringByAppendingString:[url substringFromIndex:@"hashtag://".length]];
        else if ([url hasPrefix:@"mention://"])
            displayString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
        
        TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:displayString.length < 70 ? displayString : [[displayString substringToIndex:70] stringByAppendingString:@"..."] actions:@[
                 [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogOpen") action:@"open"],
                 [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogCopy") action:@"copy"],
                 [[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]
            ] actionBlock:^(__unused id controller, NSString *action)
        {
            if ([action isEqualToString:@"open"])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
            else if ([action isEqualToString:@"copy"])
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                if (pasteboard != nil)
                {
                    NSString *copyString = url;
                    if ([url hasPrefix:@"mailto:"])
                        copyString = [url substringFromIndex:7];
                    else if ([url hasPrefix:@"tel:"])
                        copyString = [url substringFromIndex:4];
                    else if ([url hasPrefix:@"hashtag://"])
                        copyString = [@"#" stringByAppendingString:[url substringFromIndex:@"hashtag://".length]];
                    else if ([url hasPrefix:@"mention://"])
                        copyString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
                    [pasteboard setString:copyString];
                }
            }
        } target:self];
        UIView *alertViewHost = _alertViewHost;
        [actionSheet showInView:alertViewHost];
    }
}

- (NSURL *)urlForLocation:(CGPoint)location
{
    if (_links.count == 0)
        return nil;
    
    NSInteger index = -1;
    for (TGModernButton *listButton in _linkButtons)
    {
        index++;
        if (CGRectContainsPoint(listButton.frame, location))
        {
            return [NSURL URLWithString:_links[index]];
        }
    }
    
    return [NSURL URLWithString:_links.firstObject];
}

@end
