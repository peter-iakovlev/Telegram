#import "TGInstantPageController.h"

#import <SafariServices/SafariServices.h>

#import "TGInstantPageControllerView.h"
#import "TGTelegraph.h"
#import "TGApplication.h"
#import "TGAppDelegate.h"
#import "TGHacks.h"
#import "TGDatabase.h"

#import "TGModernGalleryController.h"
#import "TGItemCollectionGalleryModel.h"
#import "TGOverlayControllerWindow.h"
#import "TGItemCollectionGalleryItem.h"

#import "TGItemCollectionGalleryVideoItemView.h"

#import "TGEmbedPlayerView.h"
#import "TGEmbedPlayerController.h"
#import "TGEmbedPIPController.h"
#import "TGEmbedPIPPlaceholderView.h"

#import "TGActionSheet.h"
#import "TGOpenInMenu.h"
#import "TGShareMenu.h"
#import "TGProgressWindow.h"
#import "TGCallStatusBarView.h"
#import "TGSendMessageSignals.h"
#import "TGChannelManagementSignals.h"

#import "TGSendMessageSignals.h"
#import "TGWebpageSignals.h"

#import "TGNavigationBar.h"

#import "TGStringUtils.h"

#import "TGGenericPeerPlaylistSignals.h"

@interface TGInstantPageController () {
    TGInstantPageScrollState *_initialState;
    
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
    
    SMetaDisposable *_joinChannelDisposable;
    
    TGPIPSourceLocation *_targetPIPLocation;
    NSString *_initialAnchor;
    
    bool _autoNightEnabled;
    NSCalendar *_calendar;
}

@end

@implementation TGInstantPageController

- (instancetype)initWithWebPage:(TGWebPageMediaAttachment *)webPage anchor:(NSString *)anchor peerId:(int64_t)peerId messageId:(int32_t)messageId {
    self = [super init];
    if (self != nil) {
        _webPage = webPage;
        _peerId = peerId;
        _messageId = messageId;
        self.navigationBarShouldBeHidden = true;
        _statusBarStyle = UIStatusBarStyleLightContent;
        _shareDisposable = [[SMetaDisposable alloc] init];
        _openWebpageDisposable = [[SMetaDisposable alloc] init];
        _joinChannelDisposable = [[SMetaDisposable alloc] init];
        _initialAnchor = anchor;
        
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
        
        _initialState = [TGDatabaseInstance() loadInstantPageScrollState:webPage.webPageId];
    }
    return self;
}

- (void)dealloc {
    [_shareDisposable dispose];
    [_openWebpageDisposable dispose];
    [_joinChannelDisposable dispose];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}

- (void)loadView {
    [super loadView];
    
    _autoNightEnabled = [self presentationAutoNightTheme];
    
    _pageView = [[TGInstantPageControllerView alloc] initWithFrame:self.view.bounds];
    _pageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pageView.peerId = _peerId;
    _pageView.messageId = _messageId;
    _pageView.autoNightThemeEnabled = _autoNightEnabled;
    [self processThemeChangeAnimated:false];
    _pageView.webPage = _webPage;
    _pageView.statusBarHeight = [self controllerStatusBarHeight];
    _pageView.initialAnchor = _initialAnchor;
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
                            [TGAppDelegateInstance.rootController pushContentController:[[TGInstantPageController alloc] initWithWebPage:webPage anchor:[url urlAnchorPart] peerId:0 messageId:0]];
                        } else {
                            [(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] forceNative:false keepStack:true];
                        }
                    }
                } error:^(__unused id error) {
                    __strong TGInstantPageController *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] forceNative:false keepStack:true];
                    }
                } completed:nil]];
            } else {
                [(TGApplication *)[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] forceNative:false keepStack:true];
            }
        }
    };
    _pageView.openUrlOptions = ^(NSString *url, __unused int64_t webpageId) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSURL *link = [NSURL URLWithString:url];
            bool useOpenIn = false;
            bool isWeblink = false;
            if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"])
            {
                isWeblink = true;
                if ([TGOpenInMenu hasThirdPartyAppsForURL:link])
                    useOpenIn = true;
            }
            
            NSMutableArray *actions = [[NSMutableArray alloc] init];
            if (useOpenIn)
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.FileOpenIn") action:@"openIn"]];
            else
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogOpen") action:@"open"]];
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.LinkDialogCopy") action:@"copy"]];
            
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.ContextMenuShare") action:@"share"]];
            
            if (isWeblink && iosMajorVersion() >= 7)
                [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Conversation.AddToReadingList") action:@"addToReadingList"]];
            
            [actions addObject:[[TGActionSheetAction alloc] initWithTitle:TGLocalized(@"Common.Cancel") action:@"cancel" type:TGActionSheetActionTypeCancel]];
            
            NSString *displayString = url;
            TGActionSheet *actionSheet = [[TGActionSheet alloc] initWithTitle:displayString.length < 70 ? displayString : [[displayString substringToIndex:70] stringByAppendingString:@"..."] actions:actions actionBlock:^(__unused TGInstantPageController *controller, NSString *action)
            {
                if ([action isEqualToString:@"open"])
                {
                    [(TGApplication *)[TGApplication sharedApplication] openURL:[NSURL URLWithString:url] forceNative:true];
                }
                else if ([action isEqualToString:@"openIn"])
                {
                    [TGOpenInMenu presentInParentController:strongSelf menuController:nil title:TGLocalized(@"Map.OpenIn") url:link buttonTitle:nil buttonAction:nil sourceView:strongSelf.view sourceRect:nil barButtonItem:nil];
                }
                else if ([action isEqualToString:@"copy"])
                {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    if (pasteboard != nil)
                    {
                        NSString *copyString = url;
                        if ([url hasPrefix:@"mailto:"])
                            copyString = [url substringFromIndex:7];
                        else if ([url hasPrefix:@"tel:"])
                            copyString = [url substringFromIndex:4];
                        else if ([url hasPrefix:@"hashtag://"])
                            copyString = [@"#" stringByAppendingString:[url substringFromIndex:@"hashtag://".length]];
                        else if ([url hasPrefix:@"mention://"])
                            copyString = [@"@" stringByAppendingString:[url substringFromIndex:@"mention://".length]];
                        [pasteboard setString:copyString];
                    }
                }
                else if ([action isEqualToString:@"addToReadingList"])
                {
                    [[SSReadingList defaultReadingList] addReadingListItemWithURL:[NSURL URLWithString:url] title:url previewText:nil error:NULL];
                }
                else if ([action isEqualToString:@"share"])
                {
                    [TGShareMenu presentInParentController:strongSelf menuController:nil buttonTitle:nil buttonAction:nil shareAction:^(NSArray *peerIds, NSString *caption) {
                        [[TGShareSignals shareText:url toPeerIds:peerIds caption:caption] startWithNext:nil];
                    } externalShareItemSignal:[SSignal single:url] sourceView:strongSelf.view sourceRect:nil barButtonItem:nil];
                }
            } target:strongSelf];
            [actionSheet showInView:strongSelf.view];
        }
    };
    _pageView.shareText = ^(NSString *text) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSString *url = strongSelf->_webPage.url;
            NSString *shareText = [NSString stringWithFormat:@"\"%@\"\n\n%@", text, url];
            NSArray *entities = @[ [[TGMessageEntityItalic alloc] initWithRange:NSMakeRange(0, text.length + 2)] ];
            NSString *externalText = [NSString stringWithFormat:@"%@\n%@", text, url];
            
            [TGShareMenu presentInParentController:strongSelf menuController:nil buttonTitle:nil buttonAction:nil shareAction:^(NSArray *peerIds, NSString *caption) {
                [[TGShareSignals shareText:shareText entities:entities toPeerIds:peerIds caption:caption] startWithNext:nil];
            } externalShareItemSignal:[SSignal single:externalText] sourceView:strongSelf.view sourceRect:nil barButtonItem:nil];
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
    _pageView.openAudio = ^(NSArray<TGDocumentMediaAttachment *> *audios, TGDocumentMediaAttachment *centralItem) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            
            TGMusicPlayerItem *selectedCentralItem = nil;
            
            NSMutableSet *seenIds = [[NSMutableSet alloc] init];
            
            for (TGDocumentMediaAttachment *audio in audios) {
                if ([seenIds containsObject:@(audio.documentId)]) {
                    continue;
                }
                [seenIds addObject:@(audio.documentId)];
                TGMusicPlayerItem *item = [TGMusicPlayerItem itemWithInstantDocument:audio];
                if (item != nil) {
                    if (centralItem.documentId == audio.documentId) {
                        selectedCentralItem = item;
                    }
                    [items addObject:item];
                }
            }
            
            if (items.count != 0) {
                if (selectedCentralItem == nil) {
                    selectedCentralItem = items.firstObject;
                }
                [TGTelegraphInstance.musicPlayer setPlaylist:[TGGenericPeerPlaylistSignals playlistForItemList:items voice:false] initialItemKey:selectedCentralItem.key metadata:nil];
            }
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
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://t.me/previews?start=webpage%lld", strongSelf->_webPage.webPageId]]];
        }
    };
    _pageView.openChannel = ^(TGConversation *channel) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [ActionStageInstance() requestActor:[[NSString alloc] initWithFormat:@"/resolveDomain/(%@,profile)", channel.username] options:@{@"domain": channel.username, @"profile": @true, @"keepStack": @true} flags:0 watcher:TGTelegraphInstance];
        }
    };
    _pageView.joinChannel = ^(TGConversation *channel) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            SSignal *channelSignal = [SSignal defer:^SSignal *{
                bool exists = [TGDatabaseInstance() _channelExists:channel.conversationId] || channel.accessHash != 0;
                if (exists)
                    return [SSignal single:@(channel.conversationId)];
                else
                    return [[TGChannelManagementSignals resolveChannelWithUsername:channel.username] map:^NSNumber *(TGConversation *conversation) {
                        return @(conversation.conversationId);
                    }];
            }];
            
            [strongSelf->_joinChannelDisposable setDisposable:[[channelSignal mapToSignal:^SSignal *(NSNumber *peerId) {
                return [TGChannelManagementSignals joinTemporaryChannel:peerId.int64Value];
            }] startWithNext:nil]];
        }
    };
    _pageView.fontSizeChanged = ^(CGFloat multiplier) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            TGInstantPagePresentationTheme theme = [strongSelf presentationTheme];
            bool fontSerif = [strongSelf presentationFontSerif];
            [strongSelf storePresentationFontSizeMultiplier:multiplier fontSerif:fontSerif theme:theme];
            [strongSelf processThemeChangeAnimated:false];
        }
    };
    _pageView.fontSerifChanged = ^(bool serif) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            CGFloat fontSizeMultiplier = [strongSelf presentationFontSizeMultiplier];
            TGInstantPagePresentationTheme theme = [strongSelf presentationTheme];
            [strongSelf storePresentationFontSizeMultiplier:fontSizeMultiplier fontSerif:serif theme:theme];
            [strongSelf processThemeChangeAnimated:false];
        }
    };
    _pageView.themeChanged = ^(TGInstantPagePresentationTheme theme) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            CGFloat fontSizeMultiplier = [strongSelf presentationFontSizeMultiplier];
            bool fontSerif = [strongSelf presentationFontSerif];
            strongSelf->_autoNightEnabled = false;
            [strongSelf storePresentationFontSizeMultiplier:fontSizeMultiplier fontSerif:fontSerif theme:theme];
            [strongSelf processThemeChangeAnimated:true];
        }
    };
    _pageView.autoNightThemeChanged = ^(bool enabled) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil) {
            [strongSelf storeAutoNightTheme:enabled];
            [strongSelf processThemeChangeAnimated:true];
        }
    };
    
    [_pageView applyScrollState:_initialState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_targetPIPLocation != nil) {
        [_pageView scrollToEmbedIndex:_targetPIPLocation.localId animated:false completion:nil];
        _targetPIPLocation = nil;
    } else if (_initialState != nil) {
        [_pageView applyScrollState:_initialState];
        _initialState = nil;
    }
    
    __weak TGInstantPageController *weakSelf = self;
    _pageView.statusBarOffsetUpdated = ^(CGFloat offset) {
        __strong TGInstantPageController *strongSelf = weakSelf;
        if (strongSelf != nil)
            [strongSelf setStatusBarOffset:offset];
    };
    [UIView animateWithDuration:0.2 animations:^{
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
    
    if (iosMajorVersion() >= 7) {
        _statusBarStyle = UIStatusBarStyleDefault;
        [self setNeedsStatusBarAppearanceUpdate];
    
        [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            if (![context isInteractive] && changeStatusBar) {
                [UIView animateWithDuration:0.2 animations:^{
                    [self setStatusBarAlpha:1.0f];
                    [self setStatusBarOffset:0.0f];
                }];
            }
        } completion:nil];
    }
    
    TGInstantPageScrollState *scrollState = [_pageView currentScrollState];
    [TGDatabaseInstance() storeInstantPageScrollState:_webPage.webPageId scrollState:scrollState];
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

- (void)storePresentationFontSizeMultiplier:(CGFloat)fontSizeMultiplier fontSerif:(bool)fontSerif theme:(TGInstantPagePresentationTheme)theme {
    [[NSUserDefaults standardUserDefaults] setObject:@(fontSizeMultiplier) forKey:@"instantPage_fontMultiplier_v0"];
    [[NSUserDefaults standardUserDefaults] setObject:@(fontSerif) forKey:@"instantPage_fontSerif_v0"];
    [[NSUserDefaults standardUserDefaults] setObject:@(theme) forKey:@"instantPage_theme_v0"];
}

- (void)storeAutoNightTheme:(bool)autoNight {
    _autoNightEnabled = autoNight;
    [[NSUserDefaults standardUserDefaults] setObject:@(autoNight) forKey:@"instantPage_autoNightTheme_v0"];
}

- (CGFloat)presentationFontSizeMultiplier {
    NSNumber *storedFontSizeMultiplier = [[NSUserDefaults standardUserDefaults] objectForKey:@"instantPage_fontMultiplier_v0"];
    if (storedFontSizeMultiplier) {
        return storedFontSizeMultiplier.doubleValue;
    }
    return 1.0f;
}

- (bool)presentationFontSerif {
    NSNumber *storedFontSerif = [[NSUserDefaults standardUserDefaults] objectForKey:@"instantPage_fontSerif_v0"];
    if (storedFontSerif) {
        return storedFontSerif.boolValue;
    }
    return false;
}

- (TGInstantPagePresentationTheme)presentationTheme {
    NSNumber *storedTheme = [[NSUserDefaults standardUserDefaults] objectForKey:@"instantPage_theme_v0"];
    if (storedTheme) {
        return (TGInstantPagePresentationTheme)storedTheme.integerValue;
    }
    return TGInstantPagePresentationThemeDefault;
}

- (bool)presentationAutoNightTheme {
    NSNumber *storedAutoNightTheme = [[NSUserDefaults standardUserDefaults] objectForKey:@"instantPage_autoNightTheme_v0"];
    if (storedAutoNightTheme) {
        return storedAutoNightTheme.boolValue;
    }
    return true;
}

- (bool)isDarkTimeOfDay {
    if (_calendar == nil) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    
    NSDateComponents *dateComponents = [_calendar components:NSCalendarUnitHour fromDate:[NSDate date]];
    return dateComponents.hour >= 22 || dateComponents.hour <= 6;
}

- (void)processThemeChangeAnimated:(bool)animated {
    bool autoNightEnabled = _autoNightEnabled;
    TGInstantPagePresentationTheme targetTheme = [self presentationTheme];
    bool forceAutoNight = autoNightEnabled && [self isDarkTimeOfDay];
    [_pageView setPresentation:[TGInstantPagePresentation presentationWithFontSizeMultiplier:[self presentationFontSizeMultiplier] fontSerif:[self presentationFontSerif] theme:targetTheme forceAutoNight:forceAutoNight] animated:animated];
}

@end
