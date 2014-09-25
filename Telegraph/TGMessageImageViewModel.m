/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGMessageImageViewModel.h"

#import "TGMessageImageView.h"

@interface TGMessageImageViewModel ()
{
    NSString *_timestampString;
    bool _displayCheckmarks;
    int _checkmarkValue;
    bool _displayTimestampProgress;
    NSString *_additionalDataString;
}

@end

@implementation TGMessageImageViewModel

- (Class)viewClass
{
    return [TGMessageImageViewContainer class];
}

- (instancetype)initWithUri:(NSString *)uri
{
    self = [super init];
    if (self != nil)
    {
        _mediaVisible = true;
        
        _uri = uri;
        [self _updateViewStateIdentifier];
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
    
    if (!TGStringCompare(self.viewStateIdentifier, self.boundView.viewStateIdentifier))
        [((TGMessageImageViewContainer *)self.boundView).imageView loadUri:_uri withOptions:nil];

    [((TGMessageImageViewContainer *)self.boundView).imageView setProgress:_progress animated:false];
    [((TGMessageImageViewContainer *)self.boundView).imageView setOverlayType:_overlayType animated:false];
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampHidden:_timestampHidden];
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampString:_timestampString displayCheckmarks:_displayCheckmarks checkmarkValue:_checkmarkValue animated:false];
    [((TGMessageImageViewContainer *)self.boundView).imageView setDisplayTimestampProgress:_displayTimestampProgress];
    [((TGMessageImageViewContainer *)self.boundView).imageView setAdditionalDataString:_additionalDataString];
    [((TGMessageImageViewContainer *)self.boundView).imageView setIsBroadcast:_isBroadcast];
    
    //((TGMessageImageViewContainer *)self.boundView).imageView.alpha = _mediaVisible ? 1.0f : 0.0f;
    ((TGMessageImageViewContainer *)self.boundView).alpha = _mediaVisible ? 1.0f : 0.0f;
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
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

- (void)setProgress:(float)progress animated:(bool)animated
{
    if (ABS(_progress - progress) > FLT_EPSILON)
    {
        _progress = progress;
        
        [((TGMessageImageViewContainer *)self.boundView).imageView setProgress:_progress animated:animated];
    }
}

- (void)setSecretProgress:(float)progress animated:(bool)animated
{
    if (ABS(_progress - progress) > FLT_EPSILON)
    {
        _progress = progress;
        
        [((TGMessageImageViewContainer *)self.boundView).imageView setSecretProgress:_progress animated:animated];
    }
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

- (void)setTimestampString:(NSString *)timestampString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue animated:(bool)animated
{
    _timestampString = timestampString;
    _displayCheckmarks = displayCheckmarks;
    _checkmarkValue = checkmarkValue;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setTimestampString:_timestampString displayCheckmarks:_displayCheckmarks checkmarkValue:_checkmarkValue animated:animated];
}

- (void)setDisplayTimestampProgress:(bool)displayTimestampProgress
{
    _displayTimestampProgress = displayTimestampProgress;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setDisplayTimestampProgress:_displayTimestampProgress];
}

- (void)setAdditionalDataString:(NSString *)additionalDataString
{
    _additionalDataString = additionalDataString;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setAdditionalDataString:_additionalDataString];
}

- (void)setIsBroadcast:(bool)isBroadcast
{
    _isBroadcast = isBroadcast;
    
    [((TGMessageImageViewContainer *)self.boundView).imageView setIsBroadcast:_isBroadcast];
}

- (void)reloadImage:(bool)synchronous
{
    [((TGMessageImageViewContainer *)self.boundView).imageView loadUri:_uri withOptions:@{
        TGImageViewOptionKeepCurrentImageAsPlaceholder: @true,
        TGImageViewOptionSynchronous: @(synchronous)
    }];
}

@end
