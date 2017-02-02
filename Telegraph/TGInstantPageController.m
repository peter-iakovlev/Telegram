#import "TGInstantPageController.h"

#import "TGInstantPageControllerView.h"
#import "TGApplication.h"
#import "TGAppDelegate.h"
#import "TGHacks.h"

#import "TGModernGalleryController.h"
#import "TGItemCollectionGalleryModel.h"
#import "TGOverlayControllerWindow.h"
#import "TGItemCollectionGalleryItem.h"

#import "TGItemCollectionGalleryVideoItemView.h"

#import "TGEmbedPlayerView.h"
#import "TGEmbedPlayerController.h"
#import "TGEmbedPIPController.h"
#import "TGEmbedPIPPlaceholderView.h"

#import "TGShareMenu.h"
#import "TGProgressWindow.h"
#import "TGCallStatusBarView.h"
#import "TGSendMessageSignals.h"

#import "TGSendMessageSignals.h"
#import "TGWebpageSignals.h"

#import "TGNavigationBar.h"

@interface TGInstantPageController () {
    TGWebPageMediaAttachment *_webPage;
    int64_t _peerId;
    int32_t _messageId;
    TGInstantPageControllerView *_pageView;
    TGMenuSheetController *_menuController;
    
    UIStatusBarStyle _statusBarStyle;
    SMetaDisposable *_shareDisposable;
    id<SDisposable> _updatePageDisposable;
    
    __weak UINavigationController *_previousNavigationController;
    SMetaDisposable *_openWebpageDisposable;
    
    TGPIPSourceLocation *_targetPIPLocation;
}

@end

@implementation TGInstantPageController

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage peerId:(int64_t)peerId messageId:(int32_t)messageId {
    self = [super init];
    if (self != nil) {
        _webPage = webPage;
        _peerId = peerId;
        _messageId = messageId;
        self.navigationBarShouldBeHidden = true;
        _statusBarStyle = UIStatusBarStyleLightContent;
        _shareDisposable = [[SMetaDisposable alloc] init];
        _openWebpageDisposable = [[SMetaDisposable alloc] init];
        
        __weak TGInstantPageController *weakSelf = self;
        _updatePageDisposable = [[[TGWebpageSignals updatedWebpage:webPage] deliverOn:[SQueue mainQueue]] startWithNext:^(TGWebPageMediaAttachment *updatedWebPage) {
            __strong TGInstantPageController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                strongSelf->_webPage = updatedWebPage;
                if (strongSelf->_pageView != nil) {
                    [strongSelf->_pageView setWebPage:updatedWebPage];
                }
            }
        }];
    }
    return self;
}

- (void)dealloc {
    [_shareDisposable dispose];
    [_openWebpageDisposable dispose];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}

- (void)loadView {
    [super loadView];
    
    _pageView = [[TGInstantPageControllerView alloc] initWithFrame:self.view.bounds];
    _pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pageView.peerId = _peerId;
    _pageView.messageId = _messageId;
    _pageView.webPage = _webPage;
    _pageView.statusBarHeight = [self controllerStatusBarHeight];
    [self.view addSubview:_pageView];
    
    __weak TGInstantPageController *weakSelf = self;
    _pageView.backPressed = ^{
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf.navigationController popViewControllerAnimated:true];
        }
    };
    _pageView.sharePressed = ^{
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf presentShare];
        }
    };
    _pageView.openUrl = ^(NSString *url, int64_t webpageId) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            if (webpageId != 0) {
                TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
                [progressWindow showWithDelay:0.2];
                [strongSelf->_openWebpageDisposable setDisposable:[[[[TGWebpageSignals cachedOrRemoteWebpage:webpageId url:url] deliverOn:[SQueue mainQueue]] onDispose:^{
                    TGDispatchOnMainThread(^{
                        [progressWindow dismiss:true];
                    });
                }] startWithNext:^(TGWebPageMediaAttachment *webPage) {
                    __strong TGInstantPageController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        if (webPage != nil) {
                            [strongSelf.navigationController pushViewController:[[TGInstantPageController alloc] initWithWebPage:webPage peerId:0 messageId:0] animated:true];
                        } else {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                        }
                    }
                } error:^(__unused id error) {
                    __strong TGInstantPageController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    }
                } completed:nil]];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
        }
    };
    _pageView.openMedia = ^(NSArray<TGInstantPageMedia *> *medias, TGInstantPageMedia *centralMedia) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            TGModernGalleryController *galleryController = [[TGModernGalleryController alloc] init];
            TGItemCollectionGalleryModel *model = [[TGItemCollectionGalleryModel alloc] initWithMedias:medias centralMedia:centralMedia];
            galleryController.model = model;
            galleryController.asyncTransitionIn = true;
            galleryController.defaultStatusBarStyle = UIStatusBarStyleLightContent;
            galleryController.shouldAnimateStatusBarStyleTransition = false;
            
            __block TGInstantPageMedia *hiddenMedia = nil;
            __block bool beganTransition = false;
            
            galleryController.itemFocused = ^(id<TGModernGalleryItem> item) {
                __strong TGInstantPageController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    TGInstantPageMedia *media = nil;
                    if ([item isKindOfClass:[TGItemCollectionGalleryItem class]]) {
                        media = ((TGItemCollectionGalleryItem *)item).media;
                    }
                    hiddenMedia = media;
                    if (beganTransition) {
                        [strongSelf->_pageView updateHiddenMedia:media];
                    }
                }
            };
            
            galleryController.beginTransitionIn = ^UIView *(id<TGModernGalleryItem> item, TGModernGalleryItemView *itemView) {
                __strong TGInstantPageController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    if (strongSelf->_pageView.statusBarOffset <= -20.0f + FLT_EPSILON) {
                        [strongSelf setStatusBarOffset:0.0f];
                        [strongSelf setStatusBarAlpha:0.0f];
                        [UIView animateWithDuration:0.3 animations:^{
                            [strongSelf setStatusBarAlpha:1.0f];
                        }];
                    } else {
                        [UIView animateWithDuration:0.3 animations:^{
                            [strongSelf setStatusBarOffset:0.0f];
                        }];
                    }
                    strongSelf->_pageView.statusBarOffsetUpdated = nil;
                    
                    if ([itemView isKindOfClass:[TGItemCollectionGalleryVideoItemView class]]) {
                        [((TGItemCollectionGalleryVideoItemView *)itemView) hidePlayButton];
                    }
                
                    if ([item isKindOfClass:[TGItemCollectionGalleryItem class]]) {
                        return [strongSelf->_pageView transitionViewForMedia:((TGItemCollectionGalleryItem *)item).media];
                    }
                }
                
                return nil;
            };
            
            galleryController.startedTransitionIn = ^{
                __strong TGInstantPageController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    beganTransition = true;
                    [strongSelf->_pageView updateHiddenMedia:hiddenMedia];
                }
            };
            
            galleryController.beginTransitionOut = ^UIView *(id<TGModernGalleryItem> item, TGModernGalleryItemView *itemView) {
                __strong TGInstantPageController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    strongSelf->_pageView.statusBarOffsetUpdated = ^(CGFloat offset) {
                        __strong TGInstantPageController *strongSelf = weakSelf;
                        [strongSelf setStatusBarOffset:offset];
                    };
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (strongSelf->_pageView.statusBarOffset <= -20.0f + FLT_EPSILON) {
                            [UIView animateWithDuration:0.3 animations:^{
                                [strongSelf setStatusBarAlpha:0.0f];
                            } completion:^(__unused BOOL finished) {
                                __strong TGInstantPageController *strongSelf = weakSelf;
                                if (strongSelf != nil) {
                                    [strongSelf setStatusBarAlpha:1.0f];
                                    [strongSelf setStatusBarOffset:strongSelf->_pageView.statusBarOffset];
                                }
                            }];
                        } else {
                            [UIView animateWithDuration:0.3 animations:^{
                                [strongSelf setStatusBarOffset:strongSelf->_pageView.statusBarOffset];
                            }];
                        }
                    });
                    
                    if ([itemView isKindOfClass:[TGItemCollectionGalleryVideoItemView class]]) {
                        [((TGItemCollectionGalleryVideoItemView *)itemView) hidePlayButton];
                    }
                    
                    if ([item isKindOfClass:[TGItemCollectionGalleryItem class]]) {
                        return [strongSelf->_pageView transitionViewForMedia:((TGItemCollectionGalleryItem *)item).media];
                    }
                }
                
                return nil;
            };
            
            galleryController.finishedTransitionIn = ^(__unused id<TGModernGalleryItem> item, TGModernGalleryItemView *itemView)
            {
                if ([itemView isKindOfClass:[TGItemCollectionGalleryVideoItemView class]]) {
                    [((TGItemCollectionGalleryVideoItemView *)itemView) play];
                    [((TGItemCollectionGalleryVideoItemView *)itemView) showPlayButton];
                }
            };
            
            galleryController.completedTransitionOut = ^{
                __strong TGInstantPageController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    [strongSelf->_pageView updateHiddenMedia:nil];
                    [strongSelf setNeedsStatusBarAppearanceUpdate];
                }
            };
            
            TGOverlayControllerWindow *controllerWindow = [[TGOverlayControllerWindow alloc] initWithParentController:strongSelf contentController:galleryController];
            controllerWindow.hidden = false;
        }
    };
    _pageView.openEmbedFullscreen = ^TGEmbedPlayerController *(TGEmbedPlayerView *playerView, UIView *view) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            TGEmbedPlayerController *controller = [[TGEmbedPlayerController alloc] initWithParentController:strongSelf playerView:playerView transitionSourceFrame:^CGRect {
                return [view convertRect:playerView.initialFrame toView:nil];
            }];
            controller.embedWrapperView = (UIView <TGEmbedPlayerWrapperView> *)view;
            return controller;
        }
        return nil;
    };
    _pageView.openEmbedPIP = ^TGEmbedPIPPlaceholderView *(TGEmbedPlayerView *playerView, UIView *view, TGPIPSourceLocation *location, TGEmbedPIPCorner corner, TGEmbedPlayerController *controller) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            TGEmbedPIPPlaceholderView *placeholderView = [[TGEmbedPIPPlaceholderView alloc] initWithFrame:view.bounds];
            placeholderView.location = location;
            placeholderView.containerView = (UIView<TGPIPAblePlayerContainerView> *)view;
            
            __weak UIView *weakView = view;
            placeholderView.onWillReattach = ^
            {
                __strong UIView *strongView = weakView;
                if (strongView == nil)
                    return;
                
                UIScrollView *scrollView = (UIScrollView *)strongView.superview;
                if (![scrollView isKindOfClass:[UIScrollView class]])
                    return;
                
                [scrollView setContentOffset:scrollView.contentOffset animated:false];
            };
            [view insertSubview:placeholderView atIndex:0];
            [TGEmbedPIPController registerPlaceholderView:placeholderView];
            
            [TGEmbedPIPController startPictureInPictureWithPlayerView:playerView location:location corner:corner onTransitionBegin:^{
                if (controller != nil)
                    [controller dismissForPIP];
            } onTransitionFinished:^{}];
            
            return placeholderView;
        }
        return nil;
    };
    _pageView.openFeedback = ^{
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://telegram.me/previews?start=webpage%lld", strongSelf->_webPage.webPageId]]];
        }
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_targetPIPLocation != nil) {
        [_pageView scrollToEmbedIndex:_targetPIPLocation.localId animated:false completion:nil];
    }
    
    __weak TGInstantPageController *weakSelf = self;
    _pageView.statusBarOffsetUpdated = ^(CGFloat offset) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf setStatusBarOffset:offset];
    };
    [UIView animateWithDuration:0.2 animations:^{
        //[self setStatusBarAlpha:0.0f];
        [self setStatusBarOffset:_pageView.statusBarOffset];
    }];
    if (iosMajorVersion() >= 7) {
        _statusBarStyle = UIStatusBarStyleLightContent;
        [TGHacks animateApplicationStatusBarStyleTransitionWithDuration:0.3];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UINavigationController *navigationController = self.navigationController;
    if (navigationController == nil) {
        navigationController = _previousNavigationController;
    }
    
    bool changeStatusBar = true;
    if ([navigationController.topViewController isKindOfClass:[TGInstantPageController class]] && navigationController.topViewController != self) {
        changeStatusBar = false;
    } else {
        ((TGNavigationBar *)navigationController.navigationBar).keepAlpha = false;
        navigationController.navigationBar.alpha = 1.0f;
        [navigationController setNavigationBarHidden:true animated:false];
    }
    
    /*[UIView animateWithDuration:0.2 animations:^{
        [self setStatusBarAlpha:1.0f];
        [self setStatusBarOffset::0.0f];
    }];*/
    
    if (iosMajorVersion() >= 7) {
        _statusBarStyle = UIStatusBarStyleDefault;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (![context isInteractive] && changeStatusBar) {
            [UIView animateWithDuration:0.2 animations:^{
                [self setStatusBarAlpha:1.0f];
                [self setStatusBarOffset:0.0f];
            }];
        }
    } completion:^(__unused id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    UINavigationController *navigationController = self.navigationController;
    if (navigationController == nil) {
        navigationController = _previousNavigationController;
    }
    
    bool changeStatusBar = true;
    if ([navigationController.topViewController isKindOfClass:[TGInstantPageController class]] && navigationController.topViewController != self) {
        changeStatusBar = false;
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            [self setStatusBarAlpha:1.0f];
        	[self setStatusBarOffset:0.0f];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:false animated:false];
    ((TGNavigationBar *)self.navigationController.navigationBar).keepAlpha = false;
    self.navigationController.navigationBar.alpha = 0.0f;
    ((TGNavigationBar *)self.navigationController.navigationBar).keepAlpha = true;
    _previousNavigationController = self.navigationController;
    
    if (_targetPIPLocation != nil) {
        [_pageView cancelPIPWithEmbedIndex:_targetPIPLocation.localId];
        _targetPIPLocation = nil;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.navigationController.navigationBar.alpha = 0.0f;
}

- (void)setStatusBarAlpha:(CGFloat)alpha {
    [TGHacks setApplicationStatusBarAlpha:alpha];
    [TGAppDelegateInstance.rootController.callStatusBarView setAlpha:alpha];
}

- (void)setStatusBarOffset:(CGFloat)offset {
    [TGHacks setApplicationStatusBarOffset:offset];
    [TGAppDelegateInstance.rootController.callStatusBarView setOffset:offset];
}

- (bool)_updateControllerInsetForOrientation:(UIInterfaceOrientation)orientation force:(bool)force notify:(bool)notify {
    bool result = [super _updateControllerInsetForOrientation:orientation force:force notify:notify];
    _pageView.statusBarHeight = [self controllerStatusBarHeight];
    return result;
}

- (void)presentShare {
    __weak TGInstantPageController *weakSelf = self;
    _menuController = [TGShareMenu presentInParentController:self menuController:nil buttonTitle:TGLocalized(@"ShareMenu.CopyShareLink") buttonAction:^{
        [[UIPasteboard generalPasteboard] setString:_webPage.url];
    } shareAction:^(NSArray *peerIds, NSString *caption)
    {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf == nil || peerIds.count == 0) {
            return;
        }
        
        TGProgressWindow *progressWindow = [[TGProgressWindow alloc] init];
        [progressWindow showWithDelay:0.1];
        
        NSString *text = strongSelf->_webPage.url;
        if (caption.length != 0) {
            text = [[text stringByAppendingString:@"\n"] stringByAppendingString:caption];
        }
        
        NSMutableArray *signals = [[NSMutableArray alloc] init];
        for (NSNumber *nPeerId in peerIds) {
            [signals addObject:[TGSendMessageSignals sendTextMessageWithPeerId:[nPeerId longLongValue] text:text replyToMid:0]];
        }
        
        NSMutableArray *captionSignals = [[NSMutableArray alloc] init];
        
        SSignal *combined = [[SSignal combineSignals:signals] then:[SSignal combineSignals:captionSignals]];
        
        [strongSelf->_shareDisposable setDisposable:[[[combined deliverOn:[SQueue mainQueue]] onDispose:^{
            TGDispatchOnMainThread(^{
                [progressWindow dismiss:true];
            });
        }] startWithNext:nil error:nil completed:^{
            [progressWindow dismissWithSuccess];
        }]];
    } externalShareItemSignal:[SSignal single:_webPage.url] sourceView:self.view sourceRect:^CGRect {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            return strongSelf.view.bounds;
        }
        return CGRectZero;
    } barButtonItem:nil];
}

- (void)scrollToPIPLocation:(TGPIPSourceLocation *)location {
    if (_pageView == nil) {
        _targetPIPLocation = location;
    } else {
        __weak TGInstantPageController *weakSelf = self;
        [_pageView scrollToEmbedIndex:location.localId animated:true completion:^{
            __strong TGInstantPageController *strongSelf = weakSelf;
            if (strongSelf != nil) {
                [strongSelf->_pageView cancelPIPWithEmbedIndex:location.localId];
            }
        }];
    }
}

@end
