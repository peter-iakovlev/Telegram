#import "TGAttachmentFileTipView.h"

#import <LegacyComponents/LegacyComponents.h>

#import <LegacyComponents/TGModernButton.h>

#import "TGAppDelegate.h"

@interface TGAttachmentFileTipView ()
{
    TGModernButton *_closeButton;
    UIImageView *_imageView;
    UILabel *_label;
    
    CGFloat _labelHeight;
}
@end

@implementation TGAttachmentFileTipView

- (instancetype)init
{
    self = [super initWithType:TGMenuSheetItemTypeHeader];
    if (self != nil)
    {
        _imageView = [[UIImageView alloc] initWithImage:TGComponentsImageNamed(@"AttachmentTipIcons")];
        [self addSubview:_imageView];
        
        NSString *text = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.FileHowToText"), [TGStringUtils stringForDeviceType]];
        _label = [[UILabel alloc] init];
        _label.attributedText = [text attributedFormattedStringWithRegularFont:TGSystemFontOfSize(15.0f) boldFont:TGBoldSystemFontOfSize(15.0f) lineSpacing:1.0f paragraphSpacing:-1.0f alignment:NSTextAlignmentCenter];
        _label.numberOfLines = 0;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_label];
        
        _closeButton = [[TGModernButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        _closeButton.exclusiveTouch = true;
        [_closeButton setImage:[self _dismissImage] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeButton];
    }
    return self;
}

- (void)closeButtonPressed
{
    [self dismissAnimated:true];
}

- (void)dismissAnimated:(bool)animated
{
    if (animated)
    {
        self.superview.hidden = true;
        
        UIView *snapshotView = [self.superview snapshotViewAfterScreenUpdates:false];
        snapshotView.frame = self.superview.bounds;
        
        UIView *animationContainer = [[UIView alloc] initWithFrame:CGRectMake(self.superview.frame.origin.x, self.superview.frame.origin.y, self.superview.frame.size.width, self.superview.frame.size.height + 24)];
        animationContainer.clipsToBounds = true;
        animationContainer.userInteractionEnabled = false;
        [animationContainer addSubview:snapshotView];
        [self.superview.superview insertSubview:animationContainer atIndex:0];
        
        void (^changeBlock)(void) = ^
        {
            snapshotView.frame = CGRectMake(snapshotView.frame.origin.x, snapshotView.frame.origin.y + snapshotView.frame.size.height + 55, snapshotView.frame.size.width, snapshotView.frame.size.height);
            snapshotView.alpha = 0.0f;
        };
        
        void (^completionBlock)(BOOL) = ^(__unused BOOL finished)
        {
            [snapshotView removeFromSuperview];
            [animationContainer removeFromSuperview];
            
            if (self.didClose != nil)
                self.didClose();
        };
        
        UIViewAnimationOptions options = (iosMajorVersion() >= 7) ? 7 << 16 : UIViewAnimationOptionCurveEaseInOut;
        [UIView animateWithDuration:0.3 delay:0.0 options:options animations:changeBlock completion:completionBlock];
    }
    else
    {
        if (self.didClose != nil)
            self.didClose();
    }
}

- (bool)isCondensedLayout
{
    bool isCompact = TGAppDelegateInstance.rootController.currentSizeClass == UIUserInterfaceSizeClassCompact;
    bool isIpad = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    bool isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    
    return isCompact && isLandscape && !isIpad;
}

- (CGFloat)_sideInset
{
    CGFloat value = 21;
    if ([self isCondensedLayout])
        value -= 2;
    return value;
}

- (CGFloat)_topInset
{
    CGFloat value = 26;
    if ([self isCondensedLayout])
        value -= 12;
    return value;
}

- (CGFloat)_labelMargin
{
    CGFloat value = 20;
    if ([self isCondensedLayout])
        value -= 10;
    return value;
}

- (CGFloat)_bottomInset
{
    CGFloat value = 23;
    if ([self isCondensedLayout])
        value -= 11;
    return value;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width screenHeight:(CGFloat)__unused screenHeight
{
    CGRect rect = [_label.attributedText boundingRectWithSize:CGSizeMake(width - [self _sideInset] * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _labelHeight = ceil(rect.size.height);
    CGFloat height = [self _topInset] + _imageView.frame.size.height + [self _labelMargin] + _labelHeight + [self _bottomInset];
    return height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _imageView.frame = CGRectMake((self.frame.size.width - _imageView.frame.size.width) / 2.0f, [self _topInset], _imageView.frame.size.width, _imageView.frame.size.height);
    _label.frame = CGRectMake([self _sideInset], CGRectGetMaxY(_imageView.frame) + [self _labelMargin], self.frame.size.width - [self _sideInset] * 2, _labelHeight);
    _closeButton.frame = CGRectMake(self.frame.size.width - _closeButton.frame.size.width, 6, _closeButton.frame.size.width, _closeButton.frame.size.height);
}

- (UIImage *)_dismissImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGSize size = CGSizeMake(14.0f, 14.0f);
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, TGAccentColor().CGColor);
        CGFloat lineWidth = 1.5f;
        CGFloat lineInset = lineWidth / 2.0f;
        CGContextSetLineWidth(context, lineWidth);
        CGPoint lineSegments[4] =
        {
            CGPointMake(lineInset, lineInset),
            CGPointMake(size.width - lineInset, size.height - lineInset),
            CGPointMake(size.width - lineInset, lineInset),
            CGPointMake(lineInset, size.height - lineInset)
        };
        CGContextStrokeLineSegments(context, lineSegments, 4);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

@end
