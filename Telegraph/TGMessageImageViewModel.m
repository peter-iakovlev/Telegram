/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageImageViewModel.h"

#import "TGMessageImageView.h"

@interface TGMessageImageViewContainerWithExtendedEdges : TGMessageImageViewContainer

@end

@implementation TGMessageImageViewContainerWithExtendedEdges

@end

@interface TGMessageImageViewModel ()
{
    TGMessageImageViewTimestampPosition _timestampPosition;
    UIColor *_timestampColor;
    NSString *_timestampString;
    NSString *_signatureString;
    bool _displayCheckmarks;
    int _checkmarkValue;
    bool _displayViews;
    int _viewsValue;
    bool _displayTimestampProgress;
    NSString *_additionalDataString;
    TGMessageImageViewTimestampPosition _additionalDataPosition;
    CGPoint _timestampOffset;
    NSTimeInterval _completeDuration;
    bool _blurless;
}

@end

@implementation TGMessageImageViewModel

- (Class)viewClass
{
    return _expectExtendedEdges ? [TGMessageImageViewContainerWithExtendedEdges class] : [TGMessageImageViewContainer class];
}

- (instancetype)initWithUri:(NSString *)uri
{
    self = [super init];
    if (self != nil)
    {
        _mediaVisible = true;
        
        _overlayDiameter = 50.0f;
        
        _uri = uri;
        [self _updateViewStateIdentifier];
        
        _inlineVideoInsets = UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f);
    }
    return self;
}

- (instancetype)init
{
    return [self initWithUri:nil];
}

- (void)_updateViewStateIdentifier
{
    self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGMessageImageView/%@", _uri];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];

    [((TGMessageImageViewContainer *)self.boundView).imageView setExpectExtendedEdges:_expectExtendedEdges];
    [((TGMessageImageViewContainer *)self.boundView).imageView setFlexibleTimestamp:_flexibleTimestamp];
    
    if (!TGStringCompare(self.viewStateIdentifier, self.boundView.viewStateIdentifier))
        [((TGMessageImageViewContainer *)self.boundView).imageView loadUri:_uri withOptions:nil];

    [((TGMessageImageViewContainer *)self.boundView).imageView setInlineVideoInsets:_inlineVideoInsets];
    [((TGMessageImageViewContainer *)self.boundView).imageView setInlineVideoSize:_inlineVideoSize];
    [((TGMessageImageViewContainer *)self.boundView).imageView setInlineVideoCornerRadius:_inlineVideoCornerRadius];
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setBlurlessOverlay:_blurless];
    [((TGMessageImageViewContainer *)self.boundView).imageView setOverlayDiameter:_overlayDiameter];
    [((TGMessageImageViewContainer *)self.boundView).imageView setOverlayBackgroundColorHint:_overlayBackgroundColorHint];
    [((TGMessageImageViewContainer *)self.boundView).imageView setProgress:_progress animated:false];
    [((TGMessageImageViewContainer *)self.boundView).imageView setOverlayType:_overlayType animated:false];
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampPosition:(int)_timestampPosition];
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampColor:_timestampColor];
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampHidden:_timestampHidden];
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampString:_timestampString signatureString:_signatureString displayCheckmarks:_displayCheckmarks checkmarkValue:_checkmarkValue displayViews:_displayViews viewsValue:_viewsValue animated:false];
    [((TGMessageImageViewContainer *)self.boundView).imageView setDisplayTimestampProgress:_displayTimestampProgress];
    [((TGMessageImageViewContainer *)self.boundView).imageView setAdditionalDataString:_additionalDataString animated:false];
    [((TGMessageImageViewContainer *)self.boundView).imageView setAdditionalDataPosition:_additionalDataPosition];
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampOffset:_timestampOffset];
    [((TGMessageImageViewContainer *)self.boundView).imageView setIsBroadcast:_isBroadcast];
    [((TGMessageImageViewContainer *)self.boundView).imageView setDetailStrings:_detailStrings detailStringsEdgeInsets:_detailStringsInsets animated:false];
    [((TGMessageImageViewContainer *)self.boundView).imageView setCompletionBlock:_completionBlock];
    [((TGMessageImageViewContainer *)self.boundView).imageView setProgressBlock:_progressBlock];
    
    //((TGMessageImageViewContainer *)self.boundView).imageView.alpha = _mediaVisible ? 1.0f : 0.0f;
    ((TGMessageImageViewContainer *)self.boundView).alpha = _mediaVisible ? 1.0f : 0.0f;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [((TGMessageImageViewContainer *)self.boundView).imageView setCompletionBlock:nil];
    [((TGMessageImageViewContainer *)self.boundView).imageView setProgressBlock:nil];
    
    [super unbindView:viewStorage];
}

- (void)setMediaVisible:(bool)mediaVisible
{
    _mediaVisible = mediaVisible;
    
    //((TGMessageImageViewContainer *)self.boundView).imageView.alpha = _mediaVisible ? 1.0f : 0.0f;
    ((TGMessageImageViewContainer *)self.boundView).alpha = _mediaVisible ? 1.0f : 0.0f;
}

- (void)setUri:(NSString *)uri
{
    if (!TGStringCompare(_uri, uri))
    {
        _uri = uri;
        [self _updateViewStateIdentifier];
        
        [((TGMessageImageViewContainer *)self.boundView).imageView loadUri:_uri withOptions:@{
            TGImageViewOptionKeepCurrentImageAsPlaceholder: @true,
            TGImageViewOptionSynchronous: @false
        }];
    }
}

- (void)setProgress:(CGFloat)progress animated:(bool)animated
{
    if (ABS(_progress - progress) > FLT_EPSILON)
    {
        _progress = progress;
        
        [((TGMessageImageViewContainer *)self.boundView).imageView setProgress:_progress animated:animated];
    }
}

- (void)setSecretProgress:(CGFloat)progress completeDuration:(NSTimeInterval)completeDuration animated:(bool)animated
{
    if (ABS(_progress - progress) > FLT_EPSILON || ABS(completeDuration - _completeDuration) > DBL_EPSILON)
    {
        _progress = progress;
        _completeDuration = completeDuration;
        
        [((TGMessageImageViewContainer *)self.boundView).imageView setSecretProgress:_progress completeDuration:_completeDuration animated:animated];
    }
}

- (void)setBlurlessOverlay:(bool)blurless
{
    _blurless = blurless;
    [((TGMessageImageViewContainer *)self.boundView).imageView setBlurlessOverlay:blurless];
}

- (void)setOverlayType:(int)overlayType
{
    [self setOverlayType:overlayType animated:false];
}

- (void)setOverlayType:(int)overlayType animated:(bool)animated
{
    if (_overlayType != overlayType)
    {
        _overlayType = overlayType;
        
        [((TGMessageImageViewContainer *)self.boundView).imageView setOverlayType:_overlayType animated:animated];
    }
}

- (void)setTimestampColor:(UIColor *)color
{
    _timestampColor = color;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampColor:_timestampColor];
}

- (void)setTimestampString:(NSString *)timestampString signatureString:(NSString *)signatureString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue displayViews:(bool)displayViews viewsValue:(int)viewsValue animated:(bool)animated
{
    _timestampString = timestampString;
    _signatureString = signatureString;
    _displayCheckmarks = displayCheckmarks;
    _checkmarkValue = checkmarkValue;
    _displayViews = displayViews;
    _viewsValue = viewsValue;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampString:_timestampString signatureString:_signatureString displayCheckmarks:_displayCheckmarks checkmarkValue:_checkmarkValue displayViews:_displayViews viewsValue:_viewsValue animated:animated];
}

- (void)setTimestampPosition:(TGMessageImageViewTimestampPosition)timestampPosition
{
    _timestampPosition = timestampPosition;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampPosition:(int)timestampPosition];
}

- (void)setDisplayTimestampProgress:(bool)displayTimestampProgress
{
    _displayTimestampProgress = displayTimestampProgress;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setDisplayTimestampProgress:_displayTimestampProgress];
}

- (void)setTimestampOffset:(CGPoint)timestampOffset
{
    _timestampOffset = timestampOffset;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampOffset:_timestampOffset];
}

- (void)setAdditionalDataString:(NSString *)additionalDataString
{
    [self setAdditionalDataString:additionalDataString animated:false];
}

- (void)setAdditionalDataString:(NSString *)additionalDataString animated:(bool)animated
{
    _additionalDataString = additionalDataString;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setAdditionalDataString:_additionalDataString animated:animated];
}

- (void)setAdditionalDataPosition:(TGMessageImageViewTimestampPosition)additionalDataPosition
{
    _additionalDataPosition = additionalDataPosition;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setAdditionalDataPosition:_additionalDataPosition];
}

- (void)setIsBroadcast:(bool)isBroadcast
{
    _isBroadcast = isBroadcast;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setIsBroadcast:_isBroadcast];
}

- (void)setDetailStrings:(NSArray *)detailStrings
{
    [self setDetailStrings:detailStrings detailStringsInsets:_detailStringsInsets animated:false];
}

- (void)setDetailStrings:(NSArray *)detailStrings detailStringsInsets:(UIEdgeInsets)detailStringsInsets animated:(bool)animated
{
    _detailStrings = detailStrings;
    _detailStringsInsets = detailStringsInsets;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setDetailStrings:detailStrings detailStringsEdgeInsets:detailStringsInsets animated:animated];
}

- (void)reloadImage:(bool)synchronous
{
    [((TGMessageImageViewContainer *)self.boundView).imageView loadUri:_uri withOptions:@{
        TGImageViewOptionKeepCurrentImageAsPlaceholder: @true,
        TGImageViewOptionSynchronous: @(synchronous)
    }];
}

- (void)setInlineVideoInsets:(UIEdgeInsets)inlineVideoInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_inlineVideoInsets, inlineVideoInsets)) {
        _inlineVideoInsets = inlineVideoInsets;
        
        [((TGMessageImageViewContainer *)self.boundView).imageView setInlineVideoInsets:_inlineVideoInsets];
    }
}

- (void)setInlineVideoCornerRadius:(CGFloat)inlineVideoCornerRadius {
    _inlineVideoCornerRadius = inlineVideoCornerRadius;
    [((TGMessageImageViewContainer *)self.boundView).imageView setInlineVideoCornerRadius:_inlineVideoCornerRadius];
}

@end
