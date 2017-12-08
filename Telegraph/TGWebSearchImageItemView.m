#import "TGWebSearchImageItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGMediaEditingContext.h>
#import "TGWebSearchImageItem.h"
#import <LegacyComponents/PGPhotoEditorValues.h>

#import <LegacyComponents/TGCheckButtonView.h>

#import <LegacyComponents/TGImageView.h>

@interface TGWebSearchImageItemView ()
{
    TGCheckButtonView *_checkButton;
    
    SMetaDisposable *_imageDisposable;
    SMetaDisposable *_itemSelectedDisposable;
}
@end

@implementation TGWebSearchImageItemView

- (void)dealloc
{
    [_imageDisposable dispose];
    [_itemSelectedDisposable dispose];
}

- (void)setItem:(TGWebSearchImageItem *)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    if (item.selectionContext != nil)
    {
        if (_checkButton == nil)
        {
            _checkButton = [[TGCheckButtonView alloc] initWithStyle:TGCheckButtonStyleMedia];
            [_checkButton addTarget:self action:@selector(checkButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_checkButton];
        }
        
        if (_itemSelectedDisposable == nil)
            _itemSelectedDisposable = [[SMetaDisposable alloc] init];
        
        __weak TGWebSearchImageItemView *weakSelf = self;
        [_checkButton setSelected:[item.selectionContext isItemSelected:item.selectableMediaItem] animated:false];
        [_itemSelectedDisposable setDisposable:[[item.selectionContext itemInformativeSelectedSignal:item.selectableMediaItem] startWithNext:^(TGMediaSelectionChange *next)
        {
            __strong TGWebSearchImageItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if (next.sender != strongSelf->_checkButton)
                [strongSelf->_checkButton setSelected:next.selected animated:next.animated];
        }]];
    }
    
    __weak TGWebSearchImageItemView *weakSelf = self;
    void (^setOriginalImage)(void) = ^
    {
        __strong TGWebSearchImageItemView *strongSelf = weakSelf;
        if (strongSelf == nil)
            return;
        
        [strongSelf.imageView loadUri:[[NSString alloc] initWithFormat:@"web-search-thumbnail://?url=%@&width=90&height=90", [TGStringUtils stringByEscapingForURL:item.previewUrl]] withOptions:nil];
    };
    
    if ([item conformsToProtocol:@protocol(TGModernMediaListEditableItem)])
    {
        id<TGMediaEditableItem> editableItem = item.editableMediaItem;
        
        if (_imageDisposable == nil)
            _imageDisposable = [[SMetaDisposable alloc] init];
        
        [_imageDisposable setDisposable:[[item.editingContext thumbnailImageSignalForItem:editableItem] startWithNext:^(id next)
        {
            __strong TGWebSearchImageItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            if ([next isKindOfClass:[UIImage class]])
                [strongSelf.imageView loadUri:@"embedded-image://" withOptions:@{ TGImageViewOptionEmbeddedImage: next }];
            else
                setOriginalImage();
        }]];
    }
    else
    {
        setOriginalImage();
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _checkButton.frame = (CGRect){{self.frame.size.width - _checkButton.frame.size.width - 2.0f, 2.0f}, _checkButton.frame.size};
}

- (void)checkButtonPressed
{
    TGWebSearchImageItem *item = (TGWebSearchImageItem *)self.item;
    
    [_checkButton setSelected:!_checkButton.selected animated:true];
    [item.selectionContext setItem:item.selectableMediaItem selected:_checkButton.selected animated:false sender:_checkButton];
}

- (void)setHidden:(bool)hidden animated:(bool)animated
{
    if (hidden == self.imageView.hidden)
        return;
    
    self.imageView.hidden = hidden;
    
    if (animated)
    {
        if (!hidden)
        {
            for (UIView *view in self.subviews)
            {
                if (view != self.imageView)
                    view.alpha = 0.0f;
            }
        }
        
        [UIView animateWithDuration:0.2 animations:^
        {
            if (!hidden)
            {
                for (UIView *view in self.subviews)
                {
                    if (view != self.imageView)
                        view.alpha = 1.0f;
                }
            }
        }];
    }
    else
    {
        for (UIView *view in self.subviews)
        {
            if (view != self.imageView)
                view.alpha = hidden ? 0.0f : 1.0f;
        }
    }
}

@end
