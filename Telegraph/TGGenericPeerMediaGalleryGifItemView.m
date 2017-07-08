#import "TGGenericPeerMediaGalleryGifItemView.h"
#import "TGGenericPeerMediaGalleryGifItem.h"

#import "TGTelegraph.h"

#import "TGImageView.h"
#import "TGVTAcceleratedVideoView.h"
#import "TGModernGalleryZoomableScrollView.h"

#import "TGDocumentMediaAttachment.h"
#import "TGPreparedLocalDocumentMessage.h"

#import "TGGifGalleryAddAccessoryView.h"

#import "TGRecentGifsSignal.h"
#import "TGGifConverter.h"

@interface TGGenericPeerMediaGalleryGifItemView ()
{
    UIView *_wrapperView;
    UIView<TGInlineVideoPlayerView> *_videoView;
    
    SMetaDisposable *_converterDisposable;
}
@end

@implementation TGGenericPeerMediaGalleryGifItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        _wrapperView = [[UIView alloc] init];
        _wrapperView.clipsToBounds = true;
        [self.scrollView addSubview:_wrapperView];
    }
    return self;
}

- (CGSize)contentSize
{
    return ((TGGenericPeerMediaGalleryGifItem *)self.item).media.pictureSize;
}

- (UIView *)contentView
{
    return _wrapperView;
}

- (UIView *)transitionView
{
    return self.containerView;
}

- (CGRect)transitionViewContentRect
{
    return [_wrapperView convertRect:_wrapperView.bounds toView:[self transitionView]];
}

- (UIView *)footerView
{
    return nil;
}

- (void)setItem:(id<TGModernGalleryItem>)item synchronously:(bool)synchronously
{
    [super setItem:item synchronously:synchronously];
    
    [self checkAndPlay];
    
    TGGenericPeerMediaGalleryGifItem *gifItem = (TGGenericPeerMediaGalleryGifItem *)item;
    
    if (gifItem.media.documentId != 0)
    {
        __weak TGGenericPeerMediaGalleryGifItemView *weakSelf = self;
        [[[[TGRecentGifsSignal recentGifs] take:1] deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *documents)
        {
            __strong TGGenericPeerMediaGalleryGifItemView *strongSelf = weakSelf;
            if (strongSelf == nil)
                return;
            
            bool saved = false;
            for (TGDocumentMediaAttachment *document in documents)
            {
                if (document.documentId == gifItem.media.documentId)
                {
                    saved = true;
                    break;
                }
            }
            
            if ([[strongSelf defaultFooterAccessoryRightView] isKindOfClass:[TGGifGalleryAddAccessoryView class]])
                [strongSelf defaultFooterAccessoryRightView].hidden = saved;
        }];
    }
    else
    {
        [self defaultFooterAccessoryLeftView].hidden = true;
    }
    
    [self reset];
}

- (void)checkAndPlay
{
    __weak TGGenericPeerMediaGalleryGifItemView *weakSelf = self;
    
    TGGenericPeerMediaGalleryGifItem *item = (TGGenericPeerMediaGalleryGifItem *)self.item;
    
    TGDocumentMediaAttachment *document = item.media;
    [_converterDisposable setDisposable:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSString *filePath = nil;
        if ([document.mimeType isEqualToString:@"video/mp4"]) {
            if (document.localDocumentId != 0)
            {
                filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
            }
            else
            {
                filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
            }
        }
        
        bool exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        
        TGDispatchOnMainThread(^
        {
            __strong TGGenericPeerMediaGalleryGifItemView *strongSelf = weakSelf;
            if (strongSelf != nil && [document isEqual:((TGGenericPeerMediaGalleryGifItem *)strongSelf.item).media])
            {
                if (exists) {
                    if ([document.mimeType isEqualToString:@"video/mp4"]) {
                        [strongSelf->_videoView removeFromSuperview];
                        strongSelf->_videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:strongSelf->_wrapperView.bounds];
                        strongSelf->_videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                        [strongSelf->_wrapperView addSubview:strongSelf->_videoView];
                        [strongSelf->_videoView setPath:filePath];
                        [strongSelf reset];
                    } else if ([document.mimeType isEqualToString:@"image/gif"]) {
                        NSString *videoPath = [filePath stringByAppendingString:@".mov"];
                        
                        NSString *key = [@"gif-video-path:" stringByAppendingString:filePath];
                        
                        SSignal *videoSignal = [[SSignal defer:^SSignal *{
                            if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:NULL]) {
                                return [SSignal single:videoPath];
                            } else {
                                return [TGTelegraphInstance.genericTasksSignalManager multicastedSignalForKey:key producer:^SSignal *{
                                    SSignal *dataSignal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
                                        NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
                                        if (data != nil) {
                                            [subscriber putNext:data];
                                            [subscriber putCompletion];
                                        } else {
                                            [subscriber putError:nil];
                                        }
                                        return nil;
                                    }];
                                    return [dataSignal mapToSignal:^SSignal *(NSData *data) {
                                        return [[TGGifConverter convertGifToMp4:data] mapToSignal:^SSignal *(NSString *tempPath) {
                                            return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subsctiber) {
                                                NSError *error = nil;
                                                [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:videoPath error:&error];
                                                if (error != nil) {
                                                    [subsctiber putError:nil];
                                                } else {
                                                    [subsctiber putNext:videoPath];
                                                    [subsctiber putCompletion];
                                                }
                                                return nil;
                                            }];
                                        }];
                                    }];
                                }];
                            }
                        }] startOn:[SQueue concurrentDefaultQueue]];
                        
                        [strongSelf->_converterDisposable setDisposable:[[videoSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSString *path) {
                            __strong TGGenericPeerMediaGalleryGifItemView *strongSelf = weakSelf;
                            if (strongSelf != nil && [document isEqual:((TGGenericPeerMediaGalleryGifItem *)strongSelf.item).media])
                            {
                                [strongSelf->_videoView removeFromSuperview];
                                strongSelf->_videoView = [[[TGVTAcceleratedVideoView videoViewClass] alloc] initWithFrame:strongSelf->_wrapperView.bounds];
                                strongSelf->_videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                                [strongSelf->_wrapperView addSubview:strongSelf->_videoView];
                                [strongSelf->_videoView setPath:path];
                                [strongSelf reset];
                            }
                        }]];
                    }
                }
            }
        });
    });
}

@end
