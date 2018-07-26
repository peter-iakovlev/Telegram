#import "TGMessageReplyButtonsModel.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGModernButtonViewModel.h"

#import "TGModernView.h"
#import "TGModernViewContext.h"

#import "TGPresentation.h"

@interface TGMessageReplyButtonsView : UIView <TGModernView> {
    
}

@property (nonatomic, strong) NSString *viewIdentifier;
@property (nonatomic, strong) NSString *viewStateIdentifier;

@end

@implementation TGMessageReplyButtonsView

- (void)willBecomeRecycled {
}

@end

@interface TGMessageReplyButtonsModel () {
    NSMutableArray<TGModernButtonViewModel *> *_buttons;
    
    TGModernViewContext *_context;
}

@property (nonatomic, strong) TGBotReplyMarkup *replyMarkup;

@end

@implementation TGMessageReplyButtonsModel

- (instancetype)initWithContext:(TGModernViewContext *)context {
    self = [super init];
    if (self != nil) {
        self.hasNoView = false;
        self.skipDrawInContext = true;
        
        _context = context;
        _buttons = [[NSMutableArray alloc] init];
    
        _buttonIndexInProgress = NSNotFound;
    }
    return self;
}

- (Class)viewClass {
    return [TGMessageReplyButtonsView class];
}

- (void)setReplyMarkup:(TGBotReplyMarkup *)replyMarkup hasReceipt:(bool)hasReceipt {
    _replyMarkup = replyMarkup;
    
    while (_buttons.count != 0) {
        [self removeSubmodel:_buttons.lastObject viewStorage:nil];
        [_buttons removeLastObject];
    }
    
    __weak TGMessageReplyButtonsModel *weakSelf = self;
    NSInteger index = -1;
    for (TGBotReplyMarkupRow *row in _replyMarkup.rows) {
        for (TGBotReplyMarkupButton *button in row.buttons) {
            index++;
            NSString *text = button.text;
            if (hasReceipt && [button.action isKindOfClass:[TGBotReplyMarkupButtonActionPurchase class]]) {
                text = TGLocalized(@"Message.ReplyActionButtonShowReceipt");
            }
            
            TGModernButtonViewModel *buttonModel = [self makeButton:text action:button.action];
            buttonModel.pressed = ^{
                __strong TGMessageReplyButtonsModel *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (strongSelf.buttonActivated) {
                        strongSelf.buttonActivated(button, index);
                    }
                }
            };
            [self addSubmodel:buttonModel];
            [_buttons addObject:buttonModel];
        }
    }
    
    [self updateButtonIndexInProgress:false];
}

- (TGModernButtonViewModel *)makeButton:(NSString *)title action:(id)action {
    TGModernButtonViewModel *button = [[TGModernButtonViewModel alloc] init];
    button.presentation = _context.presentation;
    button.backgroundImage = _context.presentation.images.chatReplyButtonBackgroundImage;
    button.highlightedBackgroundImage = _context.presentation.images.chatReplyButtonHighlightedBackgroundImage;
    //button.modernHighlight = true;
    button.title = title;
    button.titleColor = _context.presentation.pallete.chatReplyButtonIconColor;
    button.font = TGMediumSystemFontOfSize(16.0f);
    if ([action isKindOfClass:[TGBotReplyMarkupButtonActionUrl class]]) {
        button.supplementaryIcon = _context.presentation.images.chatReplyButtonUrlIcon;
    } else if ([action isKindOfClass:[TGBotReplyMarkupButtonActionRequestPhone class]]) {
        button.supplementaryIcon = _context.presentation.images.chatReplyButtonPhoneIcon;
    } else if ([action isKindOfClass:[TGBotReplyMarkupButtonActionRequestLocation class]]) {
        button.supplementaryIcon = _context.presentation.images.chatReplyButtonLocationIcon;
    } else if ([action isKindOfClass:[TGBotReplyMarkupButtonActionSwitchInline class]]) {
        button.supplementaryIcon = _context.presentation.images.chatReplyButtonSwitchInlineIcon;
    } else if (action == nil) {
        button.supplementaryIcon = _context.presentation.images.chatReplyButtonActionIcon;
    }
    return button;
}

- (UIEdgeInsets)insets
{
    return UIEdgeInsetsMake(6.0f, 6.0f, 5.0f, 6.0f);
}

- (CGSize)buttonSize
{
    return CGSizeMake(151.0f, 43.0f);
}

- (CGFloat)rowSpacing
{
    return 6.0f;
}

- (CGFloat)columnSpacing
{
    return 6.0f;
}

- (CGFloat)minimumWidth {
    UIEdgeInsets insets = [self insets];
    CGFloat columnSpacing = [self columnSpacing];
    
    NSInteger buttonIndex = 0;
    CGFloat maxRowWidth = 0.0f;
    for (TGBotReplyMarkupRow *row in _replyMarkup.rows)
    {
        NSInteger columnCount = row.buttons.count;
        
        CGFloat rowWidth = 0.0f;
        NSInteger columnIndex = 0;
        for (__unused TGBotReplyMarkupButton *button in row.buttons)
        {
            TGModernButtonViewModel *buttonModel = _buttons[buttonIndex];
            rowWidth += [buttonModel.title sizeWithFont:buttonModel.font].width + 38.0f;
            
            buttonIndex++;
            columnIndex++;
        }
        
        rowWidth += MAX(0, columnCount - 1) * columnSpacing;
        maxRowWidth = MAX(maxRowWidth, rowWidth);
    }
    
    return maxRowWidth + insets.left + insets.right;
}

- (void)layoutForContainerSize:(CGSize)containerSize
{
    int rowCount = (int)_replyMarkup.rows.count;
    
    CGSize contentSize = CGSizeZero;
    contentSize.width = containerSize.width;
    UIEdgeInsets insets = [self insets];
    CGSize buttonSize = [self buttonSize];
    
    CGFloat rowSpacing = [self rowSpacing];
    CGFloat columnSpacing = [self columnSpacing];
    
    contentSize.height = insets.top + insets.bottom + _replyMarkup.rows.count * buttonSize.height + MAX((int)_replyMarkup.rows.count - 1, 0) * rowSpacing;
    
    /*if (contentSize.height < self.frame.size.height)
    {
        CGFloat spacingHeight = 0.0f;
        CGFloat availableHeight = self.frame.size.height - contentSize.height - spacingHeight;
        buttonSize.height += CGFloor(availableHeight / _replyMarkup.rows.count);
        
        contentSize.height = insets.top + insets.bottom + _replyMarkup.rows.count * buttonSize.height + MAX((int)_replyMarkup.rows.count - 1, 0) * rowSpacing;
    }*/
    
    NSInteger buttonIndex = 0;
    NSInteger rowIndex = 0;
    for (TGBotReplyMarkupRow *row in _replyMarkup.rows)
    {
        NSInteger columnCount = row.buttons.count;
        buttonSize.width = CGFloor(((containerSize.width - insets.left - insets.right) + columnSpacing - columnCount * columnSpacing) / columnCount);
        
        CGFloat topEdge = insets.top + rowIndex * (buttonSize.height + rowSpacing);
        NSInteger columnIndex = 0;
        for (__unused TGBotReplyMarkupButton *button in row.buttons)
        {
            CGFloat leftEdge = insets.left + columnIndex * (buttonSize.width + columnSpacing);
            
            TGModernButtonViewModel *buttonModel = _buttons[buttonIndex];
            buttonModel.frame = CGRectMake(leftEdge, topEdge, buttonSize.width, buttonSize.height);
            
            buttonIndex++;
            columnIndex++;
        }
        rowIndex++;
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, containerSize.width, [self buttonSize].height * rowCount + MAX(rowCount - 1, 0) * [self rowSpacing] + [self insets].top + [self insets].bottom);
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition {
    [self bindViewToContainer:container viewStorage:viewStorage];
    self.boundView.frame = CGRectOffset(self.frame, itemPosition.x, itemPosition.y);
}

- (void)setButtonIndexInProgress:(NSUInteger)buttonIndexInProgress {
    if (_buttonIndexInProgress != buttonIndexInProgress) {
        _buttonIndexInProgress = buttonIndexInProgress;
        
        [self updateButtonIndexInProgress:true];
    }
}

- (void)updateButtonIndexInProgress:(bool)animated {
    NSUInteger index = 0;
    for (TGModernButtonViewModel *button in _buttons) {
        [button setDisplayProgress:index == _buttonIndexInProgress animated:animated];
        index++;
    }
}

@end
