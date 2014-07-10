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
    return [TGMessageImageView class];
}

- (instancetype)initWithUri:(NSString *)uri
{
    self = [super init];
    if (self != nil)
    {
        _uri = uri;
        [self _updateViewStateIdentifier];
    }
    return self;
}

- (void)_updateViewStateIdentifier
{
    self.viewStateIdentifier = [[NSString alloc] initWithFormat:@"TGMessageImageView/%@", _uri];
}

- (void)bindViewToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage
{
    [super bindViewToContainer:container viewStorage:viewStorage];
    
    if (!TGStringCompare(self.viewStateIdentifier, self.boundView.viewStateIdentifier))
        [((TGMessageImageView *)self.boundView) loadUri:_uri withOptions:nil];

    [((TGMessageImageView *)self.boundView) setProgress:_progress animated:false];
    [((TGMessageImageView *)self.boundView) setOverlayType:_overlayType animated:false];
    [((TGMessageImageView *)self.boundView) setTimestampHidden:_timestampHidden];
    [((TGMessageImageView *)self.boundView) setTimestampString:_timestampString displayCheckmarks:_displayCheckmarks checkmarkValue:_checkmarkValue animated:false];
    [((TGMessageImageView *)self.boundView) setDisplayTimestampProgress:_displayTimestampProgress];
    [((TGMessageImageView *)self.boundView) setAdditionalDataString:_additionalDataString];
}

- (void)unbindView:(TGModernViewStorage *)viewStorage
{
    [super unbindView:viewStorage];
}

- (void)setUri:(NSString *)uri
{
    if (!TGStringCompare(_uri, uri))
    {
        _uri = uri;
        [self _updateViewStateIdentifier];
        
        [((TGMessageImageView *)self.boundView) loadUri:_uri withOptions:@{
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
        
        [((TGMessageImageView *)self.boundView) setProgress:_progress animated:animated];
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
        
        [((TGMessageImageView *)self.boundView) setOverlayType:_overlayType animated:animated];
    }
}

- (void)setTimestampString:(NSString *)timestampString displayCheckmarks:(bool)displayCheckmarks checkmarkValue:(int)checkmarkValue animated:(bool)animated
{
    _timestampString = timestampString;
    _displayCheckmarks = displayCheckmarks;
    _checkmarkValue = checkmarkValue;
    
    [((TGMessageImageView *)self.boundView) setTimestampString:_timestampString displayCheckmarks:_displayCheckmarks checkmarkValue:_checkmarkValue animated:animated];
}

- (void)setDisplayTimestampProgress:(bool)displayTimestampProgress
{
    _displayTimestampProgress = displayTimestampProgress;
    
    [((TGMessageImageView *)self.boundView) setDisplayTimestampProgress:_displayTimestampProgress];
}

- (void)setAdditionalDataString:(NSString *)additionalDataString
{
    _additionalDataString = additionalDataString;
    
    [((TGMessageImageView *)self.boundView) setAdditionalDataString:_additionalDataString];
}

- (void)reloadImage:(bool)synchronous
{
    [((TGMessageImageView *)self.boundView) loadUri:_uri withOptions:@{
        TGImageViewOptionKeepCurrentImageAsPlaceholder: @true,
        TGImageViewOptionSynchronous: @(synchronous)
    }];
}

@end
