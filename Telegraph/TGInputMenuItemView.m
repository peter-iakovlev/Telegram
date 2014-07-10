#import "TGInputMenuItemView.h"

#import "TGImageUtils.h"

#import "TGStringUtils.h"

@interface TGInputMenuItemView () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *labelView;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation TGInputMenuItemView

@synthesize watcherHandle = _watcherHandle;

@synthesize itemTag = _itemTag;

@synthesize label = _label;
@synthesize text = _text;

@synthesize disabled = _disabled;
@synthesize returnKeyType = _returnKeyType;

@synthesize disableNonPrintable = _disableNonPrintable;
@synthesize maxLength = _maxLength;

@synthesize labelView = _labelView;
@synthesize textField = _textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _labelView = [[UILabel alloc] initWithFrame:CGRectMake(11, 12, 96, 20)];
        _labelView.font = [UIFont boldSystemFontOfSize:16];
        _labelView.backgroundColor = [UIColor whiteColor];
        _labelView.textColor = [UIColor blackColor];
        _labelView.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:_labelView];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(11 + 96 + 2, TGIsRetina() ? 11.5f : 12.0f, self.contentView.frame.size.width - (11 + 96 + 2) - 11, 22)];
        _textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _textField.contentMode = UIViewContentModeLeft;
        _textField.font = [UIFont systemFontOfSize:16];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.textColor = UIColorRGB(0x516691);
        _textField.delegate = self;
        [self.contentView addSubview:_textField];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)]];
    }
    return self;
}

- (void)dealloc
{
    _textField.delegate = nil;
}

- (void)setLabel:(NSString *)label
{
    _label = label;
    _labelView.text = label;
}

- (void)setText:(NSString *)text
{
    _textField.text = text;
}

- (void)setDisabled:(bool)disabled
{
    if (disabled)
    {
        _textField.textColor = UIColorRGB(0xbbbbbb);
        if ([_textField isFirstResponder])
            [_textField resignFirstResponder];
    }
    else
    {
        _textField.textColor = UIColorRGB(0x516691);
    }
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
    _returnKeyType = returnKeyType;
    
    _textField.returnKeyType = returnKeyType;
}

- (void)takeFocus
{
    [_textField becomeFirstResponder];
}

- (bool)hasFocus
{
    return _textField.isFirstResponder;
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized)
    {
        if (![self hasFocus])
            [self takeFocus];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)rawString
{
    if (textField == _textField)
    {
        NSString *string = [[rawString componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
        
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (_maxLength > 0 && (int)newText.length > _maxLength)
            newText = [newText substringToIndex:_maxLength];
        
        id<ASWatcher> watcher = _watcherHandle.delegate;
        if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
            [watcher actionStageActionRequested:@"inputMenuItemChanged" options:[[NSDictionary alloc] initWithObjectsAndKeys:newText, @"text", [[NSNumber alloc] initWithInt:_itemTag], @"itemTag", nil]];
        
        textField.text = newText;
            
        return false;
    }
    
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)__unused textField
{
    id<ASWatcher> watcher = _watcherHandle.delegate;
    if (watcher != nil && [watcher respondsToSelector:@selector(actionStageActionRequested:options:)])
        [watcher actionStageActionRequested:@"inputMenuItemReturn" options:[[NSDictionary alloc] initWithObjectsAndKeys:[[NSNumber alloc] initWithInt:_itemTag], @"itemTag", nil]];
    
    return false;
}

@end
