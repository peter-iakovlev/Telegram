#import "TGWebSearchGifItemView.h"

#import "TGWebSearchGifItem.h"

#import "TGStringUtils.h"

#import "TGImagePickerCellCheckButton.h"

#import "TGImageView.h"

@interface TGWebSearchGifItemView ()
{
    TGImagePickerCellCheckButton *_checkButton;
}

@property (nonatomic, copy) void (^itemSelected)(id<TGModernMediaListItem>);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGModernMediaListItem>);
@property (nonatomic, copy) bool (^isItemHidden)(id<TGModernMediaListItem>);

@end

@implementation TGWebSearchGifItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _checkButton = [[TGImagePickerCellCheckButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 33.0f, 33.0f)];
        [_checkButton setChecked:false animated:false];
        [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_checkButton];
    }
    return self;
}

- (void)setItem:(TGWebSearchGifItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    self.itemSelected = item.itemSelected;
    self.isItemSelected = item.isItemSelected;
    self.isItemHidden = item.isItemHidden;
    
    if (_isItemHidden)
        self.imageView.hidden = _isItemHidden(item);
    
    if (_isItemSelected)
        [_checkButton setChecked:_isItemSelected(item) animated:false];
    
    [self setImageUri:[[NSString alloc] initWithFormat:@"web-search-thumbnail://?url=%@&width=90&height=90", [TGStringUtils stringByEscapingForURL:item.previewUrl]] synchronously:synchronously];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _checkButton.frame = (CGRect){{self.frame.size.width - _checkButton.frame.size.width - 2.0f, 2.0f}, _checkButton.frame.size};
}

- (void)checkButtonPressed
{
    if (_isItemSelected && _itemSelected)
    {
        _itemSelected(self.item);
        [_checkButton setChecked:_isItemSelected(self.item) animated:true];
    }
}

- (void)updateItemHidden
{
    if (_isItemHidden)
        self.imageView.hidden = _isItemHidden(self.item);
}

- (void)updateItemSelected
{
    if (_isItemSelected)
        [_checkButton setChecked:_isItemSelected(self.item) animated:false];
}

@end
