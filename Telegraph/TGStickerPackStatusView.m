#import "TGStickerPackStatusView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGModernButton.h>

#import "TGPresentation.h"

static UIImage *plusImage() {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(18.0f, 18.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, TGAccentColor().CGColor);
        CGContextFillRect(context, CGRectMake((18.0f - 1.5f) / 2.0f, 0.0f, 1.5f, 18.0f));
        CGContextFillRect(context, CGRectMake(0.0f, (18.0f - 1.5f) / 2.0f, 18.0f, 1.5f));
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    });
    return image;
}

@interface TGStickerPackStatusView () {
    TGModernButton *_button;
    UIImageView *_checkView;
    UIImageView *_addView;
    
    TGStickerPackItemStatus _status;
}

@end

@implementation TGStickerPackStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _button = [[TGModernButton alloc] init];
        _button.modernHighlight = true;
        _button.extendedEdgeInsets = UIEdgeInsetsMake(15.0f, 15.0f, 15.0f, 15.0f);
        [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        _button.frame = CGRectMake(0.0f, 0.0f, 56.0f, 56.0f);
        [self addSubview:_button];
        
        _checkView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 14.0f, 11.0f)];
        _checkView.frame = CGRectMake(CGFloor((_button.bounds.size.width - _checkView.frame.size.width) / 2.0f), CGFloor((_button.bounds.size.height - _checkView.frame.size.height) / 2.0f), _checkView.frame.size.width, _checkView.frame.size.height);
        [self addSubview:_checkView];
        
        self.frame = _button.bounds;
    }
    return self;
}

- (void)setPresentation:(TGPresentation *)presentation
{
    if (presentation == nil || _presentation == presentation)
        return;
    
    _presentation = presentation;
    [_button setImage:presentation.images.collectionMenuAddImage forState:UIControlStateNormal];
    _checkView.image = presentation.images.collectionMenuUnimportantCheckImage;
}

- (void)setStatus:(TGStickerPackItemStatus)status {
    if (_status == status) {
        return;
    }
    
    _button.hidden = true;
    _checkView.hidden = true;
    
    switch (status) {
        case TGStickerPackItemStatusNone:
            break;
        case TGStickerPackItemStatusNotInstalled:
            _button.hidden = false;
            break;
        case TGStickerPackItemStatusInstalled:
            _checkView.hidden = false;
            break;
    }
}

- (void)buttonPressed {
    if (_install) {
        _install();
    }
}

@end
