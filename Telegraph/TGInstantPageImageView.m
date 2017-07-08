#import "TGInstantPageImageView.h"

#import "TGSignalImageView.h"
#import "TGSharedMediaSignals.h"
#import "TGImageMediaAttachment.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedMediaUtils.h"

#import "TransformImageView.h"

#import "TGTelegraph.h"
#import "TGImageUtils.h"
#import "PhotoResources.h"
#import "TGMessageImageViewOverlayView.h"

#import "TGVTAcceleratedVideoView.h"

#import "TGModernGalleryTransitionView.h"

@interface TGInstantPageImageView () <TGModernGalleryTransitionView> {
    TGInstantPageMediaArguments *_arguments;
    TransformImageView *_imageView;
    UIButton *_button;
    TGMessageImageViewOverlayView *_overlayView;
    id<SDisposable> _statusDisposable;
    id<MediaResource> _fullSizeResource;
    SMetaDisposable *_fetchDisposable;
    SVariable *_data;
    UIView<TGInlineVideoPlayerView> *_videoView;
    bool _isVisible;
    SMetaDisposable *_dataDisposable;
    MediaResourceStatus *_resourceStatus;
    CGSize _currentSize;
    void (^_openMedia)(id);
}

@end

@implementation TGInstantPageImageView

- (instancetype)initWithFrame:(CGRect)frame media:(TGInstantPageMedia *)media arguments:(TGInstantPageMediaArguments *)arguments {
    return [self initWithFrame:frame media:media arguments:arguments imageUpdated:nil];
}

- (instancetype)initWithFrame:(CGRect)frame media:(TGInstantPageMedia *)media arguments:(TGInstantPageMediaArguments *)arguments imageUpdated:(void (^)())imageUpdated {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _media = media;
        _arguments = arguments;
        _imageUpdated = [imageUpdated copy];
        
        _imageView = [[TransformImageView alloc] initWithFrame:self.bounds];
        __weak TGInstantPageImageView *weakSelf = self;
        _imageView.imageUpdated = ^{
            __strong TGInstantPageImageView *strongSelf = weakSelf;
            if (strongSelf != nil && strongSelf->_imageUpdated) {
                strongSelf->_imageUpdated();
            }
        };
        [self addSubview:_imageView];
        
        if ([media.media isKindOfClass:[TGImageMediaAttachment class]]) {
            TGImageMediaAttachment *image = media.media;
            [_imageView setSignal:imageMediaTransform(TGTelegraphInstance.mediaBox, image, true)];
            
            _fullSizeResource = imageFullSizeResource(image, nil);
            
            _statusDisposable = [[[TGTelegraphInstance.mediaBox resourceStatus:_fullSizeResource] deliverOn:[SQueue mainQueue]] startWithNext:^(MediaResourceStatus *status) {
                __strong TGInstantPageImageView *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_resourceStatus = status;
                    /*switch (status.status) {
                        case MediaResourceStatusLocal:
                            [strongSelf->_overlayView setNone];
                            strongSelf->_overlayView.hidden = true;
                            break;
                        case MediaResourceStatusRemote:
                            [strongSelf->_overlayView setDownload];
                            strongSelf->_overlayView.hidden = false;
                            break;
                        case MediaResourceStatusFetching:
                            [strongSelf->_overlayView setProgress:status.progress cancelEnabled:true animated:true];
                            strongSelf->_overlayView.hidden = false;
                            break;
                    }*/
                }
            }];
        } else if ([media.media isKindOfClass:[TGVideoMediaAttachment class]]) {
            _overlayView = [[TGMessageImageViewOverlayView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
            [_overlayView setRadius:44.0f];
            [self addSubview:_overlayView];
            
            TGVideoMediaAttachment *video = media.media;
            [_imageView setSignal:videoMediaTransform(TGTelegraphInstance.mediaBox, video)];
            
            _fullSizeResource = videoFullSizeResource(video);
            
            __weak TGInstantPageImageView *weakSelf = self;
            _statusDisposable = [[[TGTelegraphInstance.mediaBox resourceStatus:videoFullSizeResource(video)] deliverOn:[SQueue mainQueue]] startWithNext:^(MediaResourceStatus *status) {
                __strong TGInstantPageImageView *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_resourceStatus = status;
                    switch (status.status) {
                        case MediaResourceStatusLocal:
                            if ([strongSelf->_arguments isKindOfClass:[TGInstantPageVideoMediaArguments class]] && ((TGInstantPageVideoMediaArguments *)strongSelf->_arguments).autoplay) {
                                [strongSelf->_overlayView setNone];
                                strongSelf->_overlayView.hidden = true;
                            } else {
                                [strongSelf->_overlayView setPlay];
                                strongSelf->_overlayView.hidden = false;
                            }
                            break;
                        case MediaResourceStatusRemote:
                            [strongSelf->_overlayView setDownload];
                            strongSelf->_overlayView.hidden = false;
                            break;
                        case MediaResourceStatusFetching:
                            [strongSelf->_overlayView setProgress:status.progress cancelEnabled:true animated:true];
                            strongSelf->_overlayView.hidden = false;
                            break;
                    }
                }
            }];
            
            _data = [[SVariable alloc] init];
            [_data set:[TGTelegraphInstance.mediaBox resourceData:videoFullSizeResource(video) pathExtension:@"mp4"]];
            _dataDisposable = [[SMetaDisposable alloc] init];
            
            _fetchDisposable = [[SMetaDisposable alloc] init];
            if ([arguments isKindOfClass:[TGInstantPageVideoMediaArguments class]] && ((TGInstantPageVideoMediaArguments *)arguments).autoplay) {
                [_fetchDisposable setDisposable:[[TGTelegraphInstance.mediaBox fetchedResource:_fullSizeResource] startWithNext:nil]];
            }
        }
        
        if (arguments.interactive) {
            _button = [[UIButton alloc] initWithFrame:self.bounds];
            [self addSubview:_button];
            [_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

- (void)dealloc {
    [_statusDisposable dispose];
    [_fetchDisposable dispose];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    _button.frame = self.bounds;
    CGSize overlaySize = _overlayView.bounds.size;
    _overlayView.frame = CGRectMake(CGFloor((size.width - overlaySize.width) / 2.0f), CGFloor((size.height - overlaySize.height) / 2.0f), overlaySize.width, overlaySize.height);
    _imageView.frame = self.bounds;
    
    _videoView.frame = self.bounds;
    
    if (!CGSizeEqualToSize(_currentSize, size)) {
        _currentSize = size;
        
        if ([_media.media isKindOfClass:[TGImageMediaAttachment class]]) {
            TGImageMediaAttachment *image = _media.media;
            CGSize imageSize = TGFillSize([image dimensions], size);
            CGSize boundingSize = size;
            
            CGFloat radius = 0.0f;
            if ([_arguments isKindOfClass:[TGInstantPageImageMediaArguments class]]) {
                TGInstantPageImageMediaArguments *imageArguments = (TGInstantPageImageMediaArguments *)_arguments;
                if (imageArguments.fit) {
                    _imageView.contentMode = UIViewContentModeScaleAspectFit;
                    imageSize = TGFitSize([image dimensions], size);
                    boundingSize = imageSize;
                }
                radius = imageArguments.roundCorners ? CGFloor(MIN(size.width, size.height) / 2.0f) : 0.0f;
            }
            [_imageView setArguments:[[TransformImageArguments alloc] initWithImageSize:imageSize boundingSize:boundingSize cornerRadius:radius]];
        } else if ([_media.media isKindOfClass:[TGVideoMediaAttachment class]]) {
            TGVideoMediaAttachment *video = _media.media;
            CGSize imageSize = TGFillSize([video dimensions], size);
            [_imageView setArguments:[[TransformImageArguments alloc] initWithImageSize:imageSize boundingSize:size cornerRadius:0.0f]];
        }
    }
}

- (void)setIsVisible:(bool)isVisible {
    if (_isVisible != isVisible) {
        _isVisible = isVisible;
        
        if (_isVisible) {
            if ([_media.media isKindOfClass:[TGVideoMediaAttachment class]]) {
                if ([_arguments isKindOfClass:[TGInstantPageVideoMediaArguments class]] && ((TGInstantPageVideoMediaArguments *)_arguments).autoplay) {
                    if (_videoView == nil) {
                        _videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:self.bounds];
                        _videoView.userInteractionEnabled = false;
                        [self addSubview:_videoView];
                        __weak TGInstantPageImageView *weakSelf = self;
                        [_dataDisposable setDisposable:[[[[[_data signal] filter:^bool(ResourceData *data) {
                            return data.complete;
                        }] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(ResourceData *data) {
                            __strong TGInstantPageImageView *strongSelf = weakSelf;
                            if (strongSelf != nil) {
                                [strongSelf->_videoView setPath:data.path];
                            }
                        }]];
                    }
                }
            }
        } else {
            if (_videoView != nil) {
                [_videoView setPath:nil];
                [_videoView prepareForRecycle];
                [_videoView removeFromSuperview];
            }
        }
    }
}

- (void)buttonPressed {
    if (_fullSizeResource != nil && _resourceStatus != nil) {
        switch (_resourceStatus.status) {
            case MediaResourceStatusLocal:
                if (_media != nil && _openMedia) {
                    _openMedia(_media);
                }
                break;
            case MediaResourceStatusRemote:
                [_fetchDisposable setDisposable:nil];
                [_fetchDisposable setDisposable:[[TGTelegraphInstance.mediaBox fetchedResource:_fullSizeResource] startWithNext:nil]];
                break;
            case MediaResourceStatusFetching:
                [_fetchDisposable setDisposable:nil];
                [TGTelegraphInstance.mediaBox cancelInteractiveResourceFetch:_fullSizeResource];
                break;
        }
    }
}

- (void)setOpenMedia:(void (^)(id))openMedia {
    _openMedia = [openMedia copy];
}

- (UIView *)transitionViewForMedia:(TGInstantPageMedia *)media {
    if ([_media isEqual:media]) {
        return _imageView;
    }
    return nil;
}

- (void)updateHiddenMedia:(TGInstantPageMedia *)media {
    if ([_media isEqual:media]) {
        _imageView.hidden = true;
        _videoView.hidden = true;
    } else {
        _imageView.hidden = false;
        _videoView.hidden = false;
    }
}

- (UIImage *)transitionImage {
    return [(id<TGModernGalleryTransitionView>)_imageView transitionImage];
}

@end
