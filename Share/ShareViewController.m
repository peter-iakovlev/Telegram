#import "ShareViewController.h"

#import <SSignalKit/SSignalKit.h>

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

#import "ApiLayer38.h"

#import "TGShareContextSignal.h"
#import "TGChatListSignal.h"
#import "TGSearchSignals.h"
#import "TGSendMessageSignals.h"
#import "TGUploadMediaSignals.h"

#import "TGShareChatListCell.h"

#import "TGChatModel.h"
#import "TGPrivateChatModel.h"
#import "TGGroupChatModel.h"
#import "TGUserModel.h"

#import "TGColor.h"
#import "TGGeometry.h"
#import "TGScaleImage.h"
#import "TGUploadedMessageContentText.h"
#import "TGUploadedMessageContentMedia.h"

#import "TGProgressAlert.h"

#import "TGSharePasscodeView.h"
#import "TGMimeTypeMap.h"

#import <objc/runtime.h>

@interface ShareViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    TGShareContext *_shareContext;
    
    NSArray *_chatModels;
    NSArray *_userModels;
    
    NSArray *_searchSections;
    
    UIActivityIndicatorView *_activityIndicator;
    
    UITableView *_tableView;
    UITableView *_searchResultsTableView;
    
    UISearchBar *_searchBar;
    UIView *_searchDimView;
    
    UINavigationBar *_navigationBar;
    
    TGProgressAlert *_progressAlert;
    TGSharePasscodeView *_passcodeView;
    
    id<SDisposable> _shareContextDisposable;
    SMetaDisposable *_chatListDisposable;
    SMetaDisposable *_searchDisposable;
    SMetaDisposable *_sendMessagesDisposable;
}

@end

@implementation ShareViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        self.title = NSLocalizedString(@"Share.Title", nil);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share.Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)];
    }
    return self;
}

- (void)dealloc
{
    [_shareContextDisposable dispose];
    [_chatListDisposable dispose];
    [_searchDisposable dispose];
    [_sendMessagesDisposable dispose];
}

- (void)animateDismiss
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:self.view.layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.layer.position.x, self.view.layer.position.y + self.view.frame.size.height)];
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeForwards;
    [self.view.layer addAnimation:animation forKey:@"position"];
    self.view.layer.position = CGPointMake(self.view.layer.position.x, self.view.layer.position.y + self.view.frame.size.height);
}

- (void)cancelPressed
{
    [self animateDismiss];
    
    self.view.userInteractionEnabled = false;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [self cancel];
    });
}

- (UITextField *)findTextField:(UIView *)view
{
    if ([view isKindOfClass:[UITextField class]])
        return (UITextField *)view;
    
    for (UIView *subview in view.subviews)
    {
        UITextField *result = [self findTextField:subview];
        if (result != nil)
            return result;
    }
    
    return nil;
}

static CGRect UISearchBarTextField_editingRectForBounds(__unused id self, __unused SEL cmd, CGRect bounds)
{
    bounds.origin.x += 28.0f;
    bounds.size.width -= 10.0f;
    return bounds;
}

- (void)loadView
{
    [super loadView];
    
    for (UIView *subview in self.view.subviews.copy)
    {
        [subview removeFromSuperview];
    }
    
    for (CALayer *layer in self.view.layer.sublayers.copy)
    {
        [layer removeFromSuperlayer];
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setContentInset:UIEdgeInsetsMake(20.0f + 44.0f, 0.0f, 0.0f, 0.0f)];
    [_tableView setScrollIndicatorInsets:UIEdgeInsetsMake(20.0f + 44.0f, 0.0f, 0.0f, 0.0f)];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 47.0f;
    _tableView.separatorInset = UIEdgeInsetsMake(0.0f, 65.0f, 0.0f, 0.0f);
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.frame.size.width, 44.0f)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar setPlaceholder:NSLocalizedString(@"Share.Search", nil)];
    _searchBar.delegate = self;

    static UIImage *searchBarBackgroundImage = nil;
    static UIImage *searchFieldBackgroundImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        {
            CGFloat radius = 4.0f;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f + 2.0f, 28.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, TGColorWithHex(0xededed).CGColor);
            CGContextFillRect(context, CGRectMake(radius, 0.0f, 2.0f, 28.0f));
            CGContextFillRect(context, CGRectMake(0.0f, radius, radius * 2.0f + 2.0f, 28.0f - radius * 2.0f));
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius * 2.0f, radius * 2.0f));
            CGContextFillEllipseInRect(context, CGRectMake(radius * 2.0f + 2.0f - radius * 2.0f, 0.0f, radius * 2.0f, radius * 2.0f));
            CGContextFillEllipseInRect(context, CGRectMake(0.0f, 28.0f - radius * 2.0f, radius * 2.0f, radius * 2.0f));
            CGContextFillEllipseInRect(context, CGRectMake(radius * 2.0f + 2.0f - radius * 2.0f, 28.0f - radius * 2.0f, radius * 2.0f, radius * 2.0f));
            searchFieldBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(2.0f, 44.0f), false, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillRect(context, CGRectMake(0.0f, 0.0f, 2.0f, 44.0f));
            searchBarBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    });
    [_searchBar setBackgroundImage:searchBarBackgroundImage forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [_searchBar setSearchFieldBackgroundImage:searchFieldBackgroundImage forState:UIControlStateNormal];
    UITextField *searchTextField = [self findTextField:_searchBar];
    if (searchTextField != nil)
    {
        Class newClass = objc_allocateClassPair([searchTextField class], "UISearchBarTextFieldWithInset", 0);
        Method method_editingRectForBounds = class_getInstanceMethod([UITextField class], @selector(editingRectForBounds:));
        if (method_editingRectForBounds != NULL)
        {
            if (!class_addMethod(newClass, @selector(editingRectForBounds:), (IMP)&UISearchBarTextField_editingRectForBounds, method_getTypeEncoding(method_editingRectForBounds)))
            {
                NSLog(@"failed to swizzle");
            }
        }
        object_setClass(searchTextField, newClass);
    }
    
    _tableView.tableHeaderView = _searchBar;
    
    _searchDimView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 20.0f + 44.0f + 44.0f, self.view.frame.size.width, self.view.frame.size.height + 44.0f)];
    _searchDimView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    _searchDimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_searchDimView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchDimViewTapped:)]];
     _searchDimView.alpha = 0.0f;
    [self.view addSubview:_searchDimView];
    
    _searchResultsTableView = [[UITableView alloc] initWithFrame:_searchDimView.frame style:UITableViewStylePlain];
    [_searchResultsTableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    _searchResultsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _searchResultsTableView.dataSource = self;
    _searchResultsTableView.delegate = self;
    _searchResultsTableView.rowHeight = 47.0f;
    _searchResultsTableView.separatorInset = UIEdgeInsetsMake(0.0f, 65.0f, 0.0f, 0.0f);
    _searchResultsTableView.tableFooterView = [[UIView alloc] init];
    _searchResultsTableView.hidden = true;
    [self.view addSubview:_searchResultsTableView];
    
    if (_chatModels == nil)
    {
        _tableView.userInteractionEnabled = false;
        _searchBar.hidden = true;
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityIndicator.frame = CGRectMake((CGFloat)floor((self.view.frame.size.width - _activityIndicator.frame.size.width) / 2.0f), (CGFloat)floor((self.view.frame.size.height - _activityIndicator.frame.size.height) / 2.0f), _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
    }
    
    _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 20.0f + 44.0f)];
    _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_navigationBar pushNavigationItem:self.navigationItem animated:false];
    [self.view addSubview:_navigationBar];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.view.layer.position.x, self.view.layer.position.y + self.view.frame.size.height)];
    animation.toValue = [NSValue valueWithCGPoint:self.view.layer.position];
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.removedOnCompletion = true;
    animation.fillMode = kCAFillModeForwards;
    [self.view.layer addAnimation:animation forKey:@"position"];
    
    __weak ShareViewController *weakSelf = self;
    [_shareContextDisposable dispose];
    _shareContextDisposable = [[[TGShareContextSignal shareContext] deliverOn:[SQueue mainQueue]] startWithNext:^(id next)
    {
        __strong ShareViewController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            if ([next isKindOfClass:[TGShareContext class]])
            {
                if (strongSelf->_passcodeView != nil)
                {
                    UIView *passcodeView = strongSelf->_passcodeView;
                    strongSelf->_passcodeView = nil;
                    
                    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^
                    {
                        passcodeView.frame = CGRectOffset(passcodeView.frame, 0.0f, passcodeView.frame.size.height);
                    } completion:^(BOOL finished)
                    {
                        [passcodeView removeFromSuperview];
                    }];
                }
                
                [strongSelf setShareContext:next];
            }
            else if ([next isKindOfClass:[TGEncryptedShareContext class]])
            {
                TGEncryptedShareContext *encryptedShareContext = next;
                
                if (strongSelf->_passcodeView == nil)
                {
                    strongSelf->_passcodeView = [[TGSharePasscodeView alloc] initWithSimpleMode:encryptedShareContext.simplePassword cancel:^
                    {
                        __strong ShareViewController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                            [strongSelf cancelPressed];
                    } verify:^(NSString *passcode, void (^result)(bool))
                    {
                        result(encryptedShareContext.verifyPassword(passcode));
                    } alertPresentationController:self];
                    
                    strongSelf->_passcodeView.frame = strongSelf.view.bounds;
                    strongSelf->_passcodeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [strongSelf.view addSubview:strongSelf->_passcodeView];

                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                    {
                        __strong ShareViewController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            [strongSelf->_passcodeView showKeyboard];
                        }
                    });
                }
            }
        }
    }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)setShareContext:(TGShareContext *)shareContext
{
    _shareContext = shareContext;
    
    _chatListDisposable = [[SMetaDisposable alloc] init];
    
    __weak ShareViewController *weakSelf = self;
    [_chatListDisposable setDisposable:[[[TGChatListSignal remoteChatListWithContext:_shareContext] deliverOn:[SQueue mainQueue]] startWithNext:^(NSDictionary *next)
    {
        __strong ShareViewController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            _searchBar.hidden = false;
            [_activityIndicator stopAnimating];
            [_activityIndicator removeFromSuperview];
            _tableView.userInteractionEnabled = true;
            
            [strongSelf setChatModels:next[@"chats"] userModels:next[@"users"]];
        }
    }]];
}

- (void)setChatModels:(NSArray *)chatModels userModels:(NSArray *)userModels
{
    _chatModels = chatModels;
    _userModels = userModels;
    
    [_tableView reloadData];
}

- (void)setSearchResultsSections:(NSArray *)sections
{
    _searchSections = sections;
    [_searchResultsTableView reloadData];
}

- (BOOL)isContentValid
{
    return true;
}

- (NSArray *)configurationItems
{
    return @[];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView)
        return 1;
    else if (tableView == _searchResultsTableView)
        return _searchSections.count;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView)
        return _chatModels.count;
    else if (tableView == _searchResultsTableView)
        return [(NSArray *)(_searchSections[section][@"chats"]) count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TGShareChatListCell *cell = (TGShareChatListCell *)[tableView dequeueReusableCellWithIdentifier:@"TGShareChatListCell"];
    if (cell == nil)
    {
        cell = [[TGShareChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TGShareChatListCell"];
    }
    
    if (tableView == _tableView)
        [cell setChatModel:_chatModels[indexPath.row] associatedUsers:_userModels shareContext:_shareContext];
    else if (tableView == _searchResultsTableView)
    {
        [cell setChatModel:_searchSections[indexPath.section][@"chats"][indexPath.row] associatedUsers:_searchSections[indexPath.section][@"users"] shareContext:_shareContext];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    TGChatModel *selectedModel = nil;
    NSArray *selectedModelUsers = nil;
    
    if (tableView == _tableView)
    {
        selectedModel = _chatModels[indexPath.row];
        selectedModelUsers = _userModels;
    }
    else if (tableView == _searchResultsTableView)
    {
        selectedModel = _searchSections[indexPath.section][@"chats"][indexPath.row];
        selectedModelUsers = _searchSections[indexPath.section][@"users"];
    }
    
    if (selectedModel != nil)
    {
        NSString *format = @"";
        NSString *title = @"";
        if ([selectedModel isKindOfClass:[TGPrivateChatModel class]])
        {
            format = NSLocalizedString(@"Share.ShareWithPerson", nil);
            for (TGUserModel *user in selectedModelUsers)
            {
                if (user.userId == selectedModel.peerId.peerId)
                {
                    title = user.displayName;
                    break;
                }
            }
        }
        else if ([selectedModel isKindOfClass:[TGGroupChatModel class]])
        {
            format = NSLocalizedString(@"Share.ShareWithGroup", nil);
            title = ((TGGroupChatModel *)selectedModel).title;
        }
        
        NSString *message = [[NSString alloc] initWithFormat:format, title];
        
        __weak ShareViewController *weakSelf = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Share.Cancel", nil) style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action)
        {
            
        }]];
        TGPeerId peerId = selectedModel.peerId;
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Share.OK", nil) style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action)
        {
            __strong ShareViewController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf sendItemsToPeerWithId:peerId users:selectedModelUsers];
        }]];
        [self presentViewController:alertController animated:true completion:nil];
    }
}

- (void)sendItemsToPeerWithId:(TGPeerId)peerId users:(NSArray *)users
{
    __weak ShareViewController *weakSelf = self;
    
    
    NSMutableArray *providers = [[NSMutableArray alloc] init];

    for (NSExtensionItem *item in self.extensionContext.inputItems)
    {
        for (NSItemProvider *provider in item.attachments)
        {
            if ([provider hasItemConformingToTypeIdentifier:@"public.file-url"])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:@"public.text"])
                [providers addObject:provider];
            else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudio])
                [providers addObject:provider];
        }
    }
    
    SSignal *itemsSignal = [SSignal complete];
    
    NSInteger providerIndex = -1;
    for (NSItemProvider *provider in providers)
    {
        providerIndex++;
        
        SSignal *dataSignal = nil;
        if ([provider hasItemConformingToTypeIdentifier:@"public.file-url"])
        {
            SSignal *urlSignal = [self signalForUrlItemProvider:provider];
            dataSignal = [urlSignal mapToSignal:^SSignal *(NSURL *url)
            {
                NSData *data = [[NSData alloc] initWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:nil];
                if (data == nil)
                    return [SSignal fail:nil];
                NSString *fileName = [[url pathComponents] lastObject];
                if (fileName.length == 0)
                    fileName = @"file.bin";
                NSString *extension = [fileName pathExtension];
                NSString *mimeType = [TGMimeTypeMap mimeTypeForExtension:[extension lowercaseString]];
                if (mimeType == nil)
                    mimeType = @"application/octet-stream";
                return [SSignal single:@{@"data": data, @"fileName": fileName, @"mimeType": mimeType}];
            }];
        }
        else if ([provider hasItemConformingToTypeIdentifier:@"public.text"])
            dataSignal = [self signalForTextItemProvider:provider];
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage])
            dataSignal = [self signalForImageItemProvider:provider];
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL])
            dataSignal = [self signalForTextUrlItemProvider:provider];
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudio])
            dataSignal = [self signalForDataItemProvider:provider];
        
        if (dataSignal != nil)
        {
            SSignal *sendMessageSignal = nil;
            
            sendMessageSignal = [dataSignal mapToSignal:^SSignal *(id next)
            {
                __strong ShareViewController *strongSelf = weakSelf;
                if (strongSelf != nil)
                {
                    SSignal *uploadMediaSignal = nil;
                    
                    if ([next respondsToSelector:@selector(objectForKey:)] && [next[@"image"] isKindOfClass:[UIImage class]])
                    {
                        UIImage *image = next[@"image"];
                        if (image != nil)
                        {
                            image = TGScaleImage(image, TGFitSize(CGSizeMake(image.size.width * image.scale, image.size.height * image.scale), CGSizeMake(1280.0f, 1280.0f)));
                            NSData *imageData = UIImageJPEGRepresentation(image, 0.54f);
                            uploadMediaSignal = [TGUploadMediaSignals uploadPhotoWithContext:strongSelf->_shareContext data:imageData];
                        }
                    }
                    else if ([next respondsToSelector:@selector(objectForKey:)])
                    {
                        NSData *data = next[@"data"];
                        
                        UIImage *image = [[UIImage alloc] initWithData:data];
                        if (image != nil)
                        {
                            bool isGif = false;
                            if (data.length > 4)
                            {
                                uint8_t header[4];
                                [data getBytes:header length:4];
                                if (header[0] == 'G' && header[1] == 'I' && header[2] == 'F' && header[3] == '8')
                                    isGif = true;
                            }
                            if (isGif)
                            {
                                uploadMediaSignal = [TGUploadMediaSignals uploadFileWithContext:strongSelf->_shareContext data:data name:next[@"fileName"] == nil ? @"animation.gif" : next[@"fileName"] mimeType:@"image/gif" attributes:@[
                                    [Api38_DocumentAttribute documentAttributeAnimated],
                                    [Api38_DocumentAttribute documentAttributeImageSizeWithW:@((int32_t)image.size.width) h:@((int32_t)image.size.height)]
                                ]];
                            }
                            else
                            {
                                image = TGScaleImage(image, TGFitSize(CGSizeMake(image.size.width * image.scale, image.size.height * image.scale), CGSizeMake(1280.0f, 1280.0f)));
                                NSData *imageData = UIImageJPEGRepresentation(image, 0.54f);
                                uploadMediaSignal = [TGUploadMediaSignals uploadPhotoWithContext:strongSelf->_shareContext data:imageData];
                            }
                        }
                        else
                        {
                            uploadMediaSignal = [TGUploadMediaSignals uploadFileWithContext:strongSelf->_shareContext data:data name:next[@"fileName"] mimeType:next[@"mimeType"] attributes:@[]];
                        }
                    }
                    else if ([next respondsToSelector:@selector(characterAtIndex:)])
                        return [SSignal single:[[TGUploadedMessageContentText alloc] initWithText:next]];
                    else
                        return [SSignal fail:nil];
                    
                    if (uploadMediaSignal == nil)
                        return [SSignal fail:nil];
                    
                    return [uploadMediaSignal mapToSignal:^SSignal *(id next)
                    {
                        __strong ShareViewController *strongSelf = weakSelf;
                        if (strongSelf != nil)
                        {
                            if ([next isKindOfClass:[Api38_InputMedia class]])
                            {
                                return [SSignal single:[[TGUploadedMessageContentMedia alloc] initWithInputMedia:next]];
                            }
                            else
                                return [SSignal single:@((providerIndex + [next floatValue]) / providers.count)];
                        }
                        else
                            return [SSignal fail:nil];
                    }];
                }
                else
                    return [SSignal fail:nil];
            }];
            
            if (sendMessageSignal != nil)
                itemsSignal = [itemsSignal then:sendMessageSignal];
        }
    }
    
    itemsSignal = [itemsSignal reduceLeftWithPassthrough:@[] with:^id (NSArray *currentUploadedMessageContents, id next, void (^passthrough)(id))
    {
        if ([next isKindOfClass:[TGUploadedMessageContent class]])
            return [currentUploadedMessageContents arrayByAddingObject:next];
        else
            passthrough(next);
        
        return currentUploadedMessageContents;
    }];
    
    itemsSignal = [itemsSignal mapToSignal:^SSignal *(id next)
    {
        if ([next respondsToSelector:@selector(floatValue)])
            return [SSignal single:next];
        else
        {
            __strong ShareViewController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                SSignal *sendMessages = [SSignal complete];
                for (id content in next)
                {
                    if ([content isKindOfClass:[TGUploadedMessageContentText class]])
                    {
                        sendMessages = [sendMessages then:[TGSendMessageSignals sendTextMessageWithContext:strongSelf->_shareContext peerId:peerId users:users text:((TGUploadedMessageContentText *)content).text]];
                    }
                    else if ([content isKindOfClass:[TGUploadedMessageContentMedia class]])
                    {
                        sendMessages = [sendMessages then:[TGSendMessageSignals sendMediaWithContext:strongSelf->_shareContext peerId:peerId users:users inputMedia:((TGUploadedMessageContentMedia *)content).inputMedia]];
                    }
                }
                
                return sendMessages;
            }
            else
            return [SSignal fail:nil];
        }
    }];
    
    if (_sendMessagesDisposable == nil)
        _sendMessagesDisposable = [[SMetaDisposable alloc] init];

    _progressAlert = [[TGProgressAlert alloc] initWithFrame:self.view.bounds];
    _progressAlert.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _progressAlert.text = NSLocalizedString(@"Share.Sharing", nil);
    _progressAlert.alpha = 0.0f;
    [self.view addSubview:_progressAlert];
    [UIView animateWithDuration:0.3 animations:^
    {
        _progressAlert.alpha = 1.0f;
    }];
    
    _progressAlert.cancel = ^
    {
        __strong ShareViewController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf->_sendMessagesDisposable setDisposable:nil];
            
            [UIView animateWithDuration:0.3 animations:^
            {
                strongSelf->_progressAlert.alpha = 0.0f;
            } completion:^(BOOL finished)
            {
                [strongSelf->_progressAlert removeFromSuperview];
                strongSelf->_progressAlert = nil;
            }];
        }
    };
    
    itemsSignal = [[itemsSignal then:[SSignal single:@(1.0f)]] then:[[SSignal complete] delay:0.4 onQueue:[SQueue mainQueue]]];
    
    [_sendMessagesDisposable setDisposable:[[[itemsSignal deliverOn:[SQueue mainQueue]] onDispose:^
    {
    }] startWithNext:^(id next)
    {
        if ([next respondsToSelector:@selector(floatValue)])
        {
            __strong ShareViewController *strongSelf = weakSelf;
            if (strongSelf != nil)
                [strongSelf->_progressAlert setProgress:[next floatValue] animated:true];
        }
    } error:^(id error)
    {
        NSLog(@"error: %@", error);
        
        __strong ShareViewController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                strongSelf->_progressAlert.alpha = 0.0f;
            } completion:^(BOOL finished)
            {
                [strongSelf->_progressAlert removeFromSuperview];
                strongSelf->_progressAlert = nil;
            }];
        }
    } completed:^
    {
        __strong ShareViewController *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf animateDismiss];
            
            self.view.userInteractionEnabled = false;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
            {
                [strongSelf didSelectPost];
            });
        }
    }]];
}

- (SSignal *)signalForDataItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeData options:nil completionHandler:^(NSData *imageData, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                [subscriber putNext:@{@"data": imageData}];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

- (SSignal *)signalForImageItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeData options:nil completionHandler:^(UIImage *image, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                [subscriber putNext:@{@"image": image}];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

- (SSignal *)signalForUrlItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:@"public.file-url" options:nil completionHandler:^(NSURL *url, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                [subscriber putNext:url];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

- (SSignal *)signalForTextItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:@"public.text" options:nil completionHandler:^(NSString *text, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                [subscriber putNext:text];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

- (SSignal *)signalForTextUrlItemProvider:(NSItemProvider *)itemProvider
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber)
    {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error)
        {
            if (error != nil)
                [subscriber putError:nil];
            else
            {
                [subscriber putNext:[url absoluteString]];
                [subscriber putCompletion];
            }
        }];
        
        return nil;
    }];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing)
    {
        [UIView animateWithDuration:0.25 animations:^
        {
            _navigationBar.frame = CGRectMake(0.0f, -_navigationBar.frame.size.height, _navigationBar.frame.size.width, _navigationBar.frame.size.height);
            [_tableView setContentInset:UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f)];
            [_tableView setScrollIndicatorInsets:UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f)];
            [_tableView setScrollEnabled:false];
            _searchDimView.frame = CGRectMake(0.0f, 20.0f + 44.0f, _searchDimView.frame.size.width, _searchDimView.frame.size.height);
            _searchResultsTableView.frame = CGRectMake(0.0f, 20.0f + 44.0f, _searchDimView.frame.size.width, _searchDimView.frame.size.height - 20.0f - 44.0f - 44.0f);
            _searchDimView.alpha = 1.0f;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^
        {
            _navigationBar.frame = CGRectMake(0.0f, 0.0f, _navigationBar.frame.size.width, _navigationBar.frame.size.height);
            [_tableView setScrollEnabled:true];
            [_tableView setContentInset:UIEdgeInsetsMake(20.0f + 44.0f, 0.0f, 0.0f, 0.0f)];
            [_tableView setScrollIndicatorInsets:UIEdgeInsetsMake(20.0f + 44.0f, 0.0f, 0.0f, 0.0f)];
            [_tableView setContentOffset:CGPointMake(0.0f, -20.0f - 44.0f) animated:false];
            _searchDimView.frame = CGRectMake(0.0f, 20.0f + 44.0f + 44.0f, _searchDimView.frame.size.width, _searchDimView.frame.size.height);
            _searchResultsTableView.frame = CGRectMake(0.0f, 20.0f + 20.0f + 44.0f, _searchDimView.frame.size.width, _searchDimView.frame.size.height - 20.0f - 44.0f - 44.0f);
            _searchResultsTableView.hidden = true;
            _searchDimView.alpha = 0.0f;
        }];
    }
}
     
- (void)searchDimViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self searchBarCancelButtonClicked:_searchBar];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:true animated:true];
    [self setEditing:true animated:true];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setText:@""];
    [searchBar endEditing:true];
    [searchBar setShowsCancelButton:false animated:true];
    [self setEditing:false animated:true];
    
    _searchSections = nil;
    _searchResultsTableView.hidden = true;
    [_searchResultsTableView reloadData];
    [_searchDisposable setDisposable:nil];
}

- (void)searchBar:(UISearchBar *)__unused searchBar textDidChange:(NSString *)searchText
{
    NSString *text = searchText;
    if (text.length == 0)
    {
        _searchSections = nil;
        _searchResultsTableView.hidden = true;
        [_searchResultsTableView reloadData];
        [_searchDisposable setDisposable:nil];
    }
    else
    {
        _searchResultsTableView.hidden = false;
        if (_searchDisposable == nil)
            _searchDisposable = [[SMetaDisposable alloc] init];
        
        __weak ShareViewController *weakSelf = self;
        
        SSignal *searchChatsSignal = [TGSearchSignals searchChatsWithContext:_shareContext chats:_chatModels users:_userModels query:text];
        SSignal *searchRemoteSignal = [[[SSignal complete] delay:0.1 onQueue:[SQueue concurrentDefaultQueue]] then:[TGSearchSignals searchUsersWithContext:_shareContext query:text]];
        SSignal *searchSignal = [SSignal combineSignals:@[searchRemoteSignal, searchChatsSignal] withInitialStates:@[@{@"chats": @[], @"users": @[]}]];
        
        [_searchDisposable setDisposable:[[searchSignal deliverOn:[SQueue mainQueue]] startWithNext:^(NSArray *results)
        {
            __strong ShareViewController *strongSelf = weakSelf;
            if (strongSelf != nil)
            {
                NSMutableArray *sections = [[NSMutableArray alloc] init];
                if (((NSArray *)results[1][@"chats"]).count != 0)
                    [sections addObject:@{@"chats": results[1][@"chats"], @"users": results[1][@"users"]}];
                if (((NSArray *)results[0][@"chats"]).count != 0)
                    [sections addObject:@{@"chats": results[0][@"chats"], @"users": results[0][@"users"]}];
                
                [strongSelf setSearchResultsSections:sections];
            }
        }]];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _searchResultsTableView)
    {
        [self.view endEditing:true];
    }
}

@end
