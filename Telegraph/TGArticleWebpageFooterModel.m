#import "TGArticleWebpageFooterModel.h"

#import "TGWebPageMediaAttachment.h"

#import "TGModernTextViewModel.h"
#import "TGSignalImageViewModel.h"
#import "TGModernFlatteningViewModel.h"
#import "TGModernImageViewModel.h"
#import "TGModernTextViewModel.h"
#import "TGModernButtonViewModel.h"

#import "TGFont.h"
#import "TGImageUtils.h"

#import "TGSharedMediaUtils.h"
#import "TGSharedMediaSignals.h"
#import "TGSharedPhotoSignals.h"
#import "TGSharedFileSignals.h"

#import "TGReusableLabel.h"

#import "TGMessage.h"

#import "TGImageManager.h"

#import "TGPreparedLocalDocumentMessage.h"
#import "TGTelegraph.h"
#import "TGGifConverter.h"

#import "TGViewController.h"

#import "TGAppDelegate.h"

#import "TGTextCheckingResult.h"

#import "TGCurrencyFormatter.h"

#import "TGAnimationUtils.h"

static UIImage *instantPageButtonBackground(UIColor *color, bool fill) {
    CGFloat diameter = 14.0f;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(diameter, diameter), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextStrokeEllipseInRect(context, CGRectMake(0.5f, 0.5f, diameter - 1.0f, diameter - 1.0f));
    if (fill) {
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.5f, 0.5f, diameter - 1.0f, diameter - 1.0f));
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image stretchableImageWithLeftCapWidth:(int)(diameter / 2.0f) topCapHeight:(int)(diameter / 2.0f)];
}

static UIImage *instantPageButtonContent(UIColor *color, UIColor *backgroundColor, NSString *title, UIImage *iconImage) {
    if (iconImage && ![color isEqual:[UIColor clearColor]])
        iconImage = TGTintedImage(iconImage, color);
    
    UIFont *buttonFont = TGMediumSystemFontOfSize(13.0f);
    CGFloat buttonWidth = (iosMajorVersion() >= 7 ? [title sizeWithAttributes:@{NSFontAttributeName: buttonFont}].width : [title sizeWithFont:buttonFont].width) + (iconImage ? (iconImage.size.width + 7.0f) : 0);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(buttonWidth, 33.0f), false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();

    if (![backgroundColor isEqual:[UIColor clearColor]]) {
        CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
        CGContextFillRect(context, CGRectMake(0.0f, 0.0f, buttonWidth, 33.0f));
    }
    
    if ([color isEqual:[UIColor clearColor]]) {
        CGContextSetBlendMode(context, kCGBlendModeClear);
    }
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    if (iconImage)
        [iconImage drawAtPoint:CGPointMake(0.0f, 11.0f)];
    [title drawAtPoint:CGPointMake(iconImage ? (iconImage.size.width + 7.0f) : 0.0f, 8.5f) withFont:buttonFont];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@interface TGArticleWebpageFooterModel ()
{
    TGWebPageMediaAttachment *_webPage;
    TGModernTextViewModel *_siteModel;
    TGModernTextViewModel *_titleModel;
    TGModernTextViewModel *_textModel;
    TGSignalImageViewModel *_imageViewModel;
    TGModernFlatteningViewModel *_durationModel;
    TGModernImageViewModel *_durationBackgroundModel;
    TGModernTextViewModel *_durationLabelModel;
    TGModernImageViewModel *_serviceIconModel;
    TGModernButtonViewModel *_actionButtonModel;
    bool _imageInText;
    
    NSString *_imageDataInvalidationUrl;
    void (^_imageDataInvalidationBlock)();
    
    bool _isAnimation;
    bool _isVideo;
    bool _activatedMedia;
    bool _isGame;
    bool _isInvoice;
}

@end

@implementation TGArticleWebpageFooterModel

static CTFontRef titleFont()
{
    static CTFontRef font = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGCoreTextMediumFontOfSize(14.0f);
    });
    
    return font;
}

static CTFontRef textFont()
{
    static CTFontRef font = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGCoreTextSystemFontOfSize(14.0f);
    });
    
    return font;
}

static CTFontRef durationFont()
{
    static CTFontRef font = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        font = TGCoreTextSystemFontOfSize(11.0f);
    });
    
    return font;
}

static UIImage *durationBackgroundImage()
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat radius = 2.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.6f).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius * 2.0f, radius * 2.0f));
        
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSInteger)radius];
        UIGraphicsEndImageContext();
    });
    return image;
}

static UIImage *durationGameBackgroundImage()
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        CGFloat radius = 9.0f;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2.0f, radius * 2.0f), false, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, UIColorRGBA(0x000000, 0.35f).CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0f, 0.0f, radius * 2.0f, radius * 2.0f));
        
        image = [UIGraphicsGetImageFromCurrentImageContext() stretchableImageWithLeftCapWidth:(NSInteger)radius topCapHeight:(NSInteger)radius];
        UIGraphicsEndImageContext();
    });
    return image;
}

- (instancetype)initWithContext:(TGModernViewContext *)context incoming:(bool)incoming webPage:(TGWebPageMediaAttachment *)webPage imageInText:(bool)imageInText invoice:(TGInvoiceMediaAttachment *)invoice
{
    self = [super initWithContext:context incoming:incoming webpage:webPage];
    if (self != nil)
    {
        _webPage = webPage;
        
        _imageInText = imageInText;
        if (webPage.pageDescription.length == 0) {
            _imageInText = false;
        }
        
        if (webPage.document != nil && ([webPage.document.mimeType isEqualToString:@"image/gif"] || [webPage.document.mimeType isEqualToString:@"video/mp4"])) {
            _imageInText = false;
        }
        
        if (webPage.siteName.length != 0)
        {
            _siteModel = [[TGModernTextViewModel alloc] initWithText:webPage.siteName font:titleFont()];
            _siteModel.textColor = [TGWebpageFooterModel colorForAccentText:incoming];
            [self addSubmodel:_siteModel];
        }
        
        NSNumber *nDuration = webPage.duration;
        
        if (webPage.document != nil) {
            for (id attribute in webPage.document.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                    nDuration = @(((TGDocumentAttributeVideo *)attribute).duration);
                }
            }
        }
        
        if ([webPage.document isAnimated]) {
            nDuration = nil;
        }
        
        NSString *title = webPage.title;
        if (title.length == 0)
            title = webPage.author;
        
        if (title.length != 0)
        {
            _titleModel = [[TGModernTextViewModel alloc] initWithText:title font:titleFont()];
            _titleModel.layoutFlags = TGReusableLabelLayoutMultiline;
            _titleModel.maxNumberOfLines = 4;
            _titleModel.textColor = [UIColor blackColor];
            [self addSubmodel:_titleModel];
        }
        
        bool isInstagram = [webPage.siteName.lowercaseString isEqualToString:@"instagram"];
        bool isCoub = [webPage.siteName.lowercaseString isEqualToString:@"coub"];
        bool isGame = [webPage.pageType isEqualToString:@"game"];
        bool isInvoice = [webPage.pageType isEqualToString:@"invoice"];
        _isGame = isGame;
        _isInvoice = isInvoice;
        
        if (webPage.pageDescription.length != 0)
        {
            if (isInvoice && webPage.photo == nil && invoice.currency.length != 0) {
                NSMutableString *updatedString = [[NSMutableString alloc] initWithString:webPage.pageDescription];
                NSString *priceString = [NSString stringWithFormat:@"\n%@", [[TGCurrencyFormatter shared] formatAmount:invoice.totalAmount currency:invoice.currency]];
                NSString *shipmentString = @"";
                if (invoice.receiptMessageId != 0) {
                    shipmentString = [@" " stringByAppendingString:TGLocalized(@"Checkout.Receipt.Title")];
                } else {
                    shipmentString = [@" " stringByAppendingString:TGLocalized(@"Message.InvoiceLabel")];
                }
                if (invoice.isTest) {
                    shipmentString = [shipmentString stringByAppendingString:@" (Test)"];
                }
                [updatedString appendString:priceString];
                [updatedString appendString:shipmentString];
                
                NSArray *currentCheckingResults = [TGMessage textCheckingResultsForText:webPage.pageDescription highlightMentionsAndTags:false highlightCommands:false entities:webPage.pageDescriptionEntities];
                NSMutableArray *textCheckingResults = [[NSMutableArray alloc] initWithArray:currentCheckingResults != nil ? currentCheckingResults : @[]];
                
                [textCheckingResults addObject:[[TGTextCheckingResult alloc] initWithRange:NSMakeRange(updatedString.length - shipmentString.length - priceString.length, priceString.length) type:TGTextCheckingResultTypeBold contents:@""]];
                
                UIColor *labelColor = nil;
                if (incoming) {
                    labelColor = UIColorRGBA(0x525252, 0.6f);
                } else {
                    labelColor = UIColorRGBA(0x008c09, 0.8f);
                }
                
                [textCheckingResults addObject:[[TGTextCheckingResult alloc] initWithRange:NSMakeRange(updatedString.length - shipmentString.length, shipmentString.length) type:TGTextCheckingResultTypeColor contents:@"" value:labelColor highlightAsLink:false]];
                
                _textModel = [[TGModernTextViewModel alloc] initWithText:updatedString font:textFont()];
                _textModel.textCheckingResults = textCheckingResults;
                _textModel.layoutFlags |= TGReusableLabelLayoutOffsetLastLine;
            } else {
                _textModel = [[TGModernTextViewModel alloc] initWithText:webPage.pageDescription font:textFont()];
                _textModel.textCheckingResults = [TGMessage textCheckingResultsForText:webPage.pageDescription highlightMentionsAndTags:false highlightCommands:false entities:webPage.pageDescriptionEntities];
            }
            
            _textModel.layoutFlags |= TGReusableLabelLayoutMultiline | TGReusableLabelLayoutHighlightLinks;
            _textModel.maxNumberOfLines = (_isGame || _isInvoice) ? 1000 : 16;
            _textModel.textColor = [UIColor blackColor];
            if (_imageInText)
            {
                _textModel.linesInset = [[TGModernTextViewLinesInset alloc] initWithNumberOfLinesToInset:_titleModel != nil ? 2 : 3 inset:60.0f];
            }
            [self addSubmodel:_textModel];
        }
        
        CGSize imageSize = CGSizeZero;
        
        bool hasSize = false;
        
        if (!_imageInText && webPage.document != nil && ([webPage.document.mimeType isEqualToString:@"image/gif"] || [webPage.document.mimeType isEqualToString:@"video/mp4"]) && !isInstagram) {
            
            if ([webPage.document isAnimated]) {
                _isAnimation = true;
            } else {
                _isVideo = true;
            }
            
            for (id attribute in webPage.document.attributes) {
                if ([attribute isKindOfClass:[TGDocumentAttributeImageSize class]]) {
                    imageSize = ((TGDocumentAttributeImageSize *)attribute).size;
                    hasSize = imageSize.width > 1.0f && imageSize.height >= 1.0f;
                    break;
                } else if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                    imageSize = ((TGDocumentAttributeVideo *)attribute).size;
                    hasSize = imageSize.width > 1.0f && imageSize.height >= 1.0f;
                    break;
                }
            }
            
            if (!hasSize) {
                [webPage.document.thumbnailInfo imageUrlForLargestSize:&imageSize];
                hasSize = imageSize.width > 1.0f && imageSize.height >= 1.0f;
            }
        } else if (!_imageInText && webPage.photo != nil) {
            [webPage.photo.imageInfo closestImageUrlWithSize:CGSizeMake(1136, 1136) resultingSize:&imageSize];
        } else if (_imageInText) {
            [webPage.photo.imageInfo closestImageUrlWithSize:CGSizeMake(50.0f, 50.0f) resultingSize:&imageSize];
        }
        
        if (_isAnimation || _isVideo) {
            _imageDataInvalidationUrl = [webPage.document.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        } else {
            _imageDataInvalidationUrl = [webPage.photo.imageInfo closestImageUrlWithSize:CGSizeZero resultingSize:NULL];
        }
        
        if (imageSize.width > FLT_EPSILON)
        {
            CGRect contentFrame = CGRectZero;
            if (_imageInText)
                imageSize = CGSizeMake(50.0f, 50.0f);
            else
            {
                if (_isAnimation || _isVideo || isGame || isInvoice) {
                    static CGSize fitSize;
                    static CGSize fitSizeGame;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        if ([TGViewController hasLargeScreen]) {
                            fitSize = CGSizeMake(220.0f, 220.0f);
                            fitSizeGame = CGSizeMake(240.0f, 240.0f);
                        } else {
                            fitSize = CGSizeMake(200.0f, 200.0f);
                            fitSizeGame = CGSizeMake(200.0f, 200.0f);
                        }
                    });
                    CGSize currentFitSize = fitSize;
                    if (isGame || isInvoice) {
                        currentFitSize = fitSizeGame;
                    }
                    imageSize = TGFitSize(TGScaleToFill(imageSize, currentFitSize), currentFitSize);
                    contentFrame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
                } else {
                    CGFloat imageAspect = imageSize.width / imageSize.height;
                    static CGSize defaultFitSize;
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                        if ([TGViewController hasLargeScreen]) {
                            defaultFitSize = CGSizeMake(225.0f, 220.0f);
                        } else {
                            defaultFitSize = CGSizeMake(200.0f, 200.0f);
                        }
                    });
                    CGSize fitSize = defaultFitSize;
                    if (ABS(imageAspect - 1.0f) < FLT_EPSILON) {
                        fitSize = CGSizeMake(fitSize.width, fitSize.width);
                    }
                    
                    imageSize = TGScaleToFit(imageSize, fitSize);
                    CGSize completeSize = imageSize;
                    imageSize = TGCropSize(imageSize, fitSize);
                    contentFrame = CGRectMake((imageSize.width - completeSize.width) / 2.0f, (imageSize.height - completeSize.height) / 2.0f, completeSize.width, completeSize.height);
                }
            }
            _imageViewModel = [[TGSignalImageViewModel alloc] init];
            _imageViewModel.viewUserInteractionDisabled = false;
            _imageViewModel.transitionContentRect = contentFrame;
            if (_isAnimation || _isVideo) {
                NSString *key = [[NSString alloc] initWithFormat:@"webpage-animation-thumbnail-%" PRId64 "", webPage.document.documentId];
                __weak TGArticleWebpageFooterModel *weakSelf = self;
                _imageDataInvalidationBlock = ^{
                    __strong TGArticleWebpageFooterModel *strongSelf = weakSelf;
                    if (strongSelf != nil) {
                        [strongSelf->_imageViewModel reload];
                    }
                };
                [_imageViewModel setSignalGenerator:^SSignal *{
                    return [TGSharedFileSignals squareFileThumbnail:webPage.document ofSize:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:8.0f]];
                } identifier:key];
            } else {
                if (_imageInText) {
                    NSString *key = [[NSString alloc] initWithFormat:@"webpage-image-small-thumbnail-%" PRId64 "", webPage.photo.imageId];
                    __weak TGArticleWebpageFooterModel *weakSelf = self;
                    _imageDataInvalidationBlock = ^{
                        __strong TGArticleWebpageFooterModel *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            [strongSelf->_imageViewModel reload];
                        }
                    };
                    [_imageViewModel setSignalGenerator:^SSignal *
                    {
                        return [TGSharedPhotoSignals sharedPhotoImage:webPage.photo size:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:8.0f] cacheKey:key];
                    } identifier:key];
                } else {
                    NSString *key;
                    if (webPage.photo.imageId != 0) {
                        key = [[NSString alloc] initWithFormat:@"webpage-image-thumbnail-%" PRId64 "", webPage.photo.imageId];
                    } else {
                        key = [[NSString alloc] initWithFormat:@"webpage-image-thumbnail-local%" PRId64 "", webPage.photo.localImageId];
                    }
                    __weak TGArticleWebpageFooterModel *weakSelf = self;
                    _imageDataInvalidationBlock = ^{
                        __strong TGArticleWebpageFooterModel *strongSelf = weakSelf;
                        if (strongSelf != nil) {
                            [strongSelf->_imageViewModel reload];
                        }
                    };
                    [_imageViewModel setSignalGenerator:^SSignal *
                    {
                        return [TGSharedPhotoSignals squarePhotoThumbnail:webPage.photo ofSize:imageSize threadPool:[TGSharedMediaUtils sharedMediaImageProcessingThreadPool] memoryCache:[TGSharedMediaUtils sharedMediaMemoryImageCache] pixelProcessingBlock:[TGSharedMediaSignals pixelProcessingBlockForRoundCornersOfRadius:8.0f] downloadLargeImage:isInstagram || isGame || isInvoice placeholder:nil];
                    } identifier:key];
                }
            }
            _imageViewModel.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
            _imageViewModel.skipDrawInContext = true;
            if (_imageInText || _isGame || isInvoice) {
                _imageViewModel.showProgress = false;
            } else {
                [_imageViewModel setManualProgress:true];
                [_imageViewModel setNone];
            }
            
            [self addSubmodel:_imageViewModel];
            
            if (!_imageInText)
            {
                if (imageSize.width >= 30.0f && imageSize.height >= 26.0f)
                {
                    if (nDuration != nil)
                    {
                        _durationModel = [[TGModernFlatteningViewModel alloc] init];
                        
                        _durationBackgroundModel = [[TGModernImageViewModel alloc] initWithImage:isGame ? durationGameBackgroundImage() : durationBackgroundImage()];
                        [_durationModel addSubmodel:_durationBackgroundModel];
                        
                        NSString *durationText = @"";
                        if (isCoub)
                        {
                            durationText = TGLocalized(@"Coub.TapForSound");
                        }
                        else
                        {
                            int duration = [nDuration intValue];
                            if (duration >= 60 * 60)
                                durationText = [[NSString alloc] initWithFormat:@"%d:%02d:%02d", duration / (60 * 60), (duration % (60 * 60)) / 60, duration % 60];
                            else
                                durationText = [[NSString alloc] initWithFormat:@"%d:%02d", duration / 60, duration % 60];
                        }
                        
                        _durationLabelModel = [[TGModernTextViewModel alloc] initWithText:durationText font:durationFont()];
                        _durationLabelModel.textColor = [UIColor whiteColor];
                        [_durationLabelModel layoutForContainerSize:CGSizeMake(200.0f, 200.0f)];
                        [_durationModel addSubmodel:_durationLabelModel];
                        
                        [_imageViewModel addSubmodel:_durationModel];
                    }
                    else if ([webPage.pageType isEqualToString:@"video"] && isInstagram)
                    {
                        _serviceIconModel = [[TGModernImageViewModel alloc] initWithImage:[UIImage imageNamed:@"InlineMediaInstagramVideoIcon.png"]];
                        [_serviceIconModel sizeToFit];
                        [_imageViewModel addSubmodel:_serviceIconModel];
                    } else if (isInvoice) {
                        _durationModel = [[TGModernFlatteningViewModel alloc] init];
                        
                        _durationBackgroundModel = [[TGModernImageViewModel alloc] initWithImage:(isGame || isInvoice) ? durationGameBackgroundImage() : durationBackgroundImage()];
                        [_durationModel addSubmodel:_durationBackgroundModel];
                        
                        NSMutableString *updatedString = [[NSMutableString alloc] init];
                        NSString *priceString = [NSString stringWithFormat:@"%@", [[TGCurrencyFormatter shared] formatAmount:invoice.totalAmount currency:invoice.currency]];
                        NSString *shipmentString = @"";
                        if (invoice.receiptMessageId != 0) {
                            shipmentString = [@" " stringByAppendingString:TGLocalized(@"Checkout.Receipt.Title")];
                        } else {
                            shipmentString = [@" " stringByAppendingString:TGLocalized(@"Message.InvoiceLabel")];
                        }
                        if (invoice.isTest) {
                            shipmentString = [shipmentString stringByAppendingString:@" (Test)"];
                        }
                        [updatedString appendString:priceString];
                        [updatedString appendString:shipmentString];
                        
                        _durationLabelModel = [[TGModernTextViewModel alloc] initWithText:updatedString font:durationFont()];
                        _durationLabelModel.textCheckingResults = @[[[TGTextCheckingResult alloc] initWithRange:NSMakeRange(0, priceString.length) type:TGTextCheckingResultTypeBold contents:@""]];
                        _durationLabelModel.textColor = [UIColor whiteColor];
                        [_durationLabelModel layoutForContainerSize:CGSizeMake(200.0f, 200.0f)];
                        [_durationModel addSubmodel:_durationLabelModel];
                        
                        [_imageViewModel addSubmodel:_durationModel];
                    }
                }
            }
        }
        
        NSString *buttonType = nil;
        if (_webPage.instantPage != nil)
            buttonType = @"instantPage";
        else if ([_webPage.pageType isEqualToString:@"telegram_channel"])
            buttonType = @"viewChannel";
        else if ([_webPage.pageType isEqualToString:@"telegram_chat"] || [_webPage.pageType isEqualToString:@"telegram_megagroup"])
            buttonType = @"viewGroup";
        
        if (buttonType != nil) {
            static UIImage *incomingBackground = nil;
            static UIImage *incomingSolidBackground = nil;
            static UIImage *outgoingBackground = nil;
            static UIImage *outgoingSolidBackground = nil;
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                incomingBackground = instantPageButtonBackground(UIColorRGB(0x3ca7fe), false);
                incomingSolidBackground = instantPageButtonBackground(UIColorRGB(0x3ca7fe), true);
                outgoingBackground = instantPageButtonBackground(UIColorRGB(0x29cc10), false);
                outgoingSolidBackground = instantPageButtonBackground(UIColorRGB(0x29cc10), true);
            });
            
            static NSDictionary *cachedButtons = nil;
            if (cachedButtons == nil)
                cachedButtons = [[NSDictionary alloc] init];
            
            NSDictionary *button = cachedButtons[buttonType];
            if (button == nil || ![button[@"localeVersion"] isEqualToNumber:@(TGLocalizedStaticVersion)])
            {
                NSString *title = nil;
                UIImage *iconImage = nil;
                if ([buttonType isEqualToString:@"instantPage"])
                {
                    title = TGLocalized(@"Conversation.InstantPagePreview");
                    iconImage = [UIImage imageNamed:@"ConversationInstantPageButtonIconIncoming.png"];
                }
                else if ([buttonType isEqualToString:@"viewChannel"])
                {
                    title = TGLocalized(@"Conversation.ViewChannel");
                }
                else if ([buttonType isEqualToString:@"viewGroup"])
                {
                    title = TGLocalized(@"Conversation.ViewGroup");
                }
                
                button = [TGArticleWebpageFooterModel cachedActionButtonForTitle:title iconImage:iconImage];
                NSMutableDictionary *updatedCachedButtons = [cachedButtons mutableCopy];
                updatedCachedButtons[buttonType] = button;
                cachedButtons = updatedCachedButtons;
            }
            
            if (button != nil)
            {
                _actionButtonModel = [[TGModernButtonViewModel alloc] init];
                _actionButtonModel.image = incoming ? button[@"incoming"] : button[@"outgoing"];
                _actionButtonModel.highlightedImage = incoming ? button[@"incomingHighlighted"] : button[@"outgoingHighlighted"];
                _actionButtonModel.backgroundImage = incoming ? incomingBackground : outgoingBackground;
                _actionButtonModel.highlightedBackgroundImage = incoming ? incomingSolidBackground : outgoingSolidBackground;
                _actionButtonModel.skipDrawInContext = true;
                
                __weak TGArticleWebpageFooterModel *weakSelf = self;
                _actionButtonModel.pressed = ^{
                    __strong TGArticleWebpageFooterModel *strongSelf = weakSelf;
                    if (strongSelf != nil && strongSelf.instantPagePressed) {
                        if ([buttonType isEqualToString:@"instantPage"])
                            strongSelf.instantPagePressed();
                        else
                            strongSelf.viewGroupPressed();
                    }
                };
                [self addSubmodel:_actionButtonModel];
            }
        }
    }
    return self;
}

+ (NSDictionary *)cachedActionButtonForTitle:(NSString *)title iconImage:(UIImage *)iconImage
{
    UIImage *incomingImage = instantPageButtonContent(UIColorRGB(0x0b8bed), [UIColor clearColor], title, iconImage);
    UIImage *incomingSolidImage = instantPageButtonContent([UIColor whiteColor], UIColorRGB(0x3ca7fe), title, iconImage);
    UIImage *outgoingImage = instantPageButtonContent(UIColorRGB(0x17b300), [UIColor clearColor], title, iconImage);
    UIImage *outgoingSolidImage = instantPageButtonContent(UIColorRGB(0xe1ffc7), UIColorRGB(0x29cc10), title, iconImage);
    
    return @{ @"localeVersion": @(TGLocalizedStaticVersion), @"incoming": incomingImage, @"incomingHighlighted": incomingSolidImage, @"outgoing": outgoingImage, @"outgoingHighlighted": outgoingSolidImage };
}

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition
{
    _imageViewModel.parentOffset = itemPosition;
    [_imageViewModel bindViewToContainer:container viewStorage:viewStorage];
    
    _actionButtonModel.parentOffset = itemPosition;
    [_actionButtonModel bindViewToContainer:container viewStorage:viewStorage];
    _actionButtonModel.boundView.tag = 0xbeef;
    
    if (self.context.autoplayAnimations && self.mediaIsAvailable && self.boundToContainer) {
        [self activateWebpageContents];
    }
}

- (void)unbindView:(TGModernViewStorage *)viewStorage {
    [super unbindView:viewStorage];
    
    [_imageViewModel setVideoPathSignal:nil];
    _activatedMedia = false;
    [self updateOverlayAnimated:false];
}

- (void)updateSpecialViewsPositions:(CGPoint)itemPosition
{
    _imageViewModel.parentOffset = itemPosition;
    _actionButtonModel.parentOffset = itemPosition;
}

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize contentSize:(CGSize)topContentSize infoWidth:(CGFloat)infoWidth needsContentsUpdate:(bool *)needsContentsUpdate
{
    CGSize contentContainerSize = CGSizeMake(MAX(containerSize.width - 10.0f - 20.0f, topContentSize.width - 10.0f - 20.0f), containerSize.height);
    
    CGFloat imageInset = 0.0f;
    if (_imageInText)
    {
        imageInset = _imageViewModel.frame.size.width + 6.0f;
    }
    else if (_imageViewModel.frame.size.width >= 180.0f)
    {
        contentContainerSize.width = _imageViewModel.frame.size.width;
    }
    
    CGSize textContainerSize = CGSizeMake(contentContainerSize.width - imageInset, contentContainerSize.height);
    
    if (_actionButtonModel == nil) {
        if (_titleModel == nil && _textModel == nil) {
            _siteModel.additionalTrailingWidth = infoWidth;
        } else if (_textModel == nil && (_imageViewModel == nil || !_imageInText)) {
            _titleModel.additionalTrailingWidth = infoWidth;
        } else {
            _textModel.additionalTrailingWidth = infoWidth;
        }
    }
    
    if (_siteModel != nil && [_siteModel layoutNeedsUpdatingForContainerSize:textContainerSize])
    {
        if (needsContentsUpdate)
            *needsContentsUpdate = true;
        [_siteModel layoutForContainerSize:textContainerSize];
    }
    
    if ([_titleModel layoutNeedsUpdatingForContainerSize:textContainerSize])
    {
        if (needsContentsUpdate)
            *needsContentsUpdate = true;
        [_titleModel layoutForContainerSize:textContainerSize];
    }
    
    CGSize adjustedTextContainerSize = contentContainerSize;
    if (_textModel != nil && [_textModel layoutNeedsUpdatingForContainerSize:adjustedTextContainerSize])
    {
        if (needsContentsUpdate)
            *needsContentsUpdate = true;
        NSInteger numberOfLines = 3;
        numberOfLines = MAX(0, numberOfLines - (NSInteger)_titleModel.measuredNumberOfLines);
        if (!_imageInText)
            numberOfLines = 0;
        if (numberOfLines != 0)
            _textModel.linesInset = [[TGModernTextViewLinesInset alloc] initWithNumberOfLinesToInset:numberOfLines inset:60.0f];
        else
            _textModel.linesInset = nil;
        [_textModel layoutForContainerSize:adjustedTextContainerSize];
    }
    
    CGSize contentSize = CGSizeZero;
    
    contentSize.height += 2.0 + 2.0f;
    
    if (_siteModel != nil)
    {
        contentSize.width = MAX(contentSize.width, _siteModel.frame.size.width + 10.0f + imageInset);
        contentSize.height += _siteModel.frame.size.height;
        
        if (_titleModel == nil && _textModel == nil && _imageViewModel == nil) {
            contentSize.height += 14.0f;
        }
    }
    
    if (_titleModel != nil)
    {
        if (_siteModel != nil)
            contentSize.height += 3.0f;
        contentSize.width = MAX(contentSize.width, _titleModel.frame.size.width + 10.0f + imageInset);
        contentSize.height += _titleModel.frame.size.height;
    }
    
    if (_textModel != nil)
    {
        if (_siteModel != nil || _titleModel != nil)
            contentSize.height += 3.0f;
        contentSize.width = MAX(contentSize.width, _textModel.frame.size.width + 10.0f);
        contentSize.height += _textModel.frame.size.height;
    }
    
    if (_imageViewModel != nil)
    {
        if (!_imageInText)
        {
            if (_siteModel != nil || _titleModel != nil || _textModel != nil) {
                contentSize.height += 9.0f;
            } else if (!_actionButtonModel) {
                contentSize.height += 17.0f;
            }
        }
        
        contentSize.width = MAX(contentSize.width, _imageViewModel.frame.size.width + 10.0f);
        
        if (!_imageInText)
            contentSize.height += _imageViewModel.frame.size.height;
        else
            contentSize.height += MAX(0.0, _imageViewModel.frame.size.height - _textModel.frame.size.height - (_titleModel != nil ? _titleModel.frame.size.height + 3.0f : 0.0f));
        
        if (_imageInText && _imageViewModel != nil)
        {
            if (_actionButtonModel == nil)
                contentSize.height = MAX(contentSize.height, 91.0f);
            else
                contentSize.height = MAX(contentSize.height, 80.0f);
        }
    }
    
    if (_actionButtonModel != nil) {
        contentSize.height += 50.0f;
    }
    
    return contentSize;
}

- (bool)preferWebpageSize
{
    return _imageViewModel.frame.size.width >= 190.0f;
}

- (bool)fitContentToWebpage {
    return [_webPage.pageType isEqualToString:@"game"];
}

- (TGWebpageFooterModelAction)webpageActionAtPoint:(CGPoint)point
{
    if (_webPage.instantPage != nil && CGRectContainsPoint(self.bounds, point) && [self linkAtPoint:point regionData:NULL] == nil && (_imageViewModel == nil || !CGRectContainsPoint(_imageViewModel.frame, point) || _imageInText || self.mediaIsAvailable || self.mediaProgressVisible)) {
        return TGWebpageFooterModelActionGeneric;
    }
    
    bool result = _imageViewModel != nil && CGRectContainsPoint(_imageViewModel.frame, point);
    if (result && _imageInText) {
        return TGWebpageFooterModelActionOpenURL;
    }
    
    if (!result && [self linkAtPoint:point regionData:NULL] == nil && CGRectContainsPoint(self.bounds, point))
    {
        if ([_webPage.pageType isEqualToString:@"audio"])
            return TGWebpageFooterModelActionGeneric;
    }
    
    if (result) {
        if (!_imageInText) {
            if (!self.mediaIsAvailable) {
                return self.mediaProgressVisible ? TGWebpageFooterModelActionCancel : TGWebpageFooterModelActionDownload;
            } else {
                if (_isAnimation || _isVideo) {
                    return TGWebpageFooterModelActionPlay;
                }
            }
        }
        
        return TGWebpageFooterModelActionGeneric;
    }
    
    return TGWebpageFooterModelActionNone;
}

- (NSString *)linkAtPoint:(CGPoint)point regionData:(NSArray *__autoreleasing *)regionData
{
    NSArray *originalRegionData = nil;
    NSMutableArray *offsetRegionData = [[NSMutableArray alloc] init];
    
    NSString *link = [_textModel linkAtPoint:CGPointMake(point.x - _textModel.frame.origin.x, point.y - _textModel.frame.origin.y) regionData:&originalRegionData];
    
    if (link != nil && originalRegionData != nil)
    {
        for (NSValue *value in originalRegionData)
        {
            [offsetRegionData addObject:[NSValue valueWithCGRect:CGRectOffset([value CGRectValue], _textModel.frame.origin.x, _textModel.frame.origin.y)]];
        }
        
        if (regionData != nil)
            *regionData = offsetRegionData;
    }
    
    return link;
}

- (UIView *)referenceViewForImageTransition
{
    return _imageViewModel.boundView;
}

- (void)setMediaVisible:(bool)mediaVisible
{
    bool wasHidden = _imageViewModel.hidden;
    _imageViewModel.hidden = !mediaVisible;
    
    if (wasHidden && mediaVisible && _isInvoice) {
        [_durationModel.boundView.layer animateAlphaFrom:0.0f to:1.0f duration:0.2 timingFunction:kCAMediaTimingFunctionDefault removeOnCompletion:true completion:nil];
    }
}

- (void)layoutContentInRect:(CGRect)rect bottomInset:(CGFloat *)bottomInset
{
    CGFloat currentOffset = -4.0f;
    _siteModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _siteModel.frame.size.width, _siteModel.frame.size.height);
    
    if (_imageViewModel != nil && _imageInText)
    {
        _imageViewModel.frame = CGRectMake(rect.origin.x + rect.size.width - _imageViewModel.frame.size.width, rect.origin.y + 20.0f, _imageViewModel.frame.size.width, _imageViewModel.frame.size.height);
    }
    
    if (_siteModel != nil)
        currentOffset += 2.0f + _siteModel.frame.size.height;
    
    CGFloat finalBottomInset = 0.0f;
    
    currentOffset = MAX(currentOffset, 0.0f);
    
    if (_imageViewModel != nil && !_imageInText)
    {
        if (_siteModel != nil) {
            currentOffset += 4.0f;
        }
        _imageViewModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _imageViewModel.frame.size.width, _imageViewModel.frame.size.height);
        
        if (_titleModel != nil || _textModel != nil) {
            currentOffset += 3.0f;
        } else {
            finalBottomInset = 12.0f;
        }
        
        currentOffset += _imageViewModel.frame.size.height;
    }
    
    _titleModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _titleModel.frame.size.width, _titleModel.frame.size.height);
    
    if (_titleModel != nil)
        currentOffset += 2.0f + _titleModel.frame.size.height;
    
    _textModel.frame = CGRectMake(rect.origin.x + 10.0f, rect.origin.y + currentOffset, _textModel.frame.size.width, _textModel.frame.size.height);
    
    if (_textModel != nil)
        currentOffset += 7.0f + _textModel.frame.size.height;
    else
        currentOffset += 4.0f;
    
    if (_textModel != nil)
    {
        if (_textModel.containsEmptyNewline && _actionButtonModel == nil)
            finalBottomInset = 11.0f;
    }
    
    if (_durationModel != nil)
    {
        CGRect durationBackgroundFrame = CGRectMake(0.0f, 0.0f, _durationLabelModel.frame.size.width + 12.0f - ((_isGame || _isInvoice) ? 1.0f : 0.0f), 18.0f);
        if (!_isGame && !_isInvoice && _webPage.instantPage != nil) {
            durationBackgroundFrame.size.width += 20.0f;
            durationBackgroundFrame.size.height += 8.0f;
        }
        _durationBackgroundModel.frame = durationBackgroundFrame;
        CGRect durationModelFrame = CGRectMake(_imageViewModel.frame.size.width - _durationBackgroundModel.frame.size.width - 4.0f, _imageViewModel.frame.size.height - _durationBackgroundModel.frame.size.height - 4.0f, _durationBackgroundModel.frame.size.width, _durationBackgroundModel.frame.size.height);
        if (_isGame || _isInvoice) {
            durationModelFrame.origin = CGPointMake(4.0f, 4.0f);
        } else if (_webPage.instantPage != nil) {
            durationModelFrame.origin = CGPointMake(4.0f, 4.0f);
        }
        if (!CGSizeEqualToSize(_durationModel.frame.size, durationModelFrame.size))
            [_durationModel setNeedsSubmodelContentsUpdate];
        _durationModel.frame = durationModelFrame;
        
        CGRect durationLabelFrame = CGRectMake(5.0f, 0.0f, _durationLabelModel.frame.size.width, _durationLabelModel.frame.size.height);
        
        if (!_isGame && !_isInvoice && _webPage.instantPage != nil) {
            durationLabelFrame.origin.x += 16.0f;
            durationLabelFrame.origin.y += 2.0f;
        }
        _durationLabelModel.frame = durationLabelFrame;
        [_durationModel updateSubmodelContentsIfNeeded];
    }
    
    if (_serviceIconModel != nil)
    {
        _serviceIconModel.frame = CGRectMake(_imageViewModel.frame.size.width - _serviceIconModel.frame.size.width - 3.0f - TGRetinaPixel, 4.0f, _serviceIconModel.frame.size.width, _serviceIconModel.frame.size.height);
    }
    
    if (_actionButtonModel != nil) {
        CGFloat instantOffset = MAX(CGRectGetMaxY(_titleModel.frame), MAX(CGRectGetMaxY(_textModel.frame), CGRectGetMaxY(_imageViewModel.frame)));
        
        CGFloat instantPageButtonWidth = rect.size.width;
        _actionButtonModel.frame = CGRectMake(2.0f, instantOffset + 8.0f, instantPageButtonWidth, 33.0f);;
        finalBottomInset += _actionButtonModel.frame.size.height + (_imageInText ? 18.0f : 20.0f) - 11.0f;
        if (_textModel != nil) {
            finalBottomInset += 8.0f;
        }
    }
    
    if (bottomInset)
        *bottomInset = finalBottomInset;
}

- (bool)activateWebpageContents
{
    if (self.mediaIsAvailable && _isAnimation) {
        if (_activatedMedia && !self.context.autoplayAnimations) {
            _activatedMedia = false;
            [_imageViewModel setVideoPathSignal:nil];
            [self updateOverlayAnimated:false];
        } else {
            _activatedMedia = true;
            [self updateOverlayAnimated:false];
            
            TGDocumentMediaAttachment *document = _webPage.document;
            if (document != nil) {
                NSString *documentDirectory = nil;
                if (document.localDocumentId != 0) {
                    documentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version];
                } else {
                    documentDirectory = [TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version];
                }
                
                NSString *videoPath = nil;
                
                if ([document.mimeType isEqualToString:@"video/mp4"]) {
                    if (document.localDocumentId != 0) {
                        videoPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
                    } else {
                        videoPath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
                    }
                }
                
                if (videoPath != nil) {
                    [_imageViewModel setVideoPathSignal:[SSignal single:videoPath]];
                } else {
                    NSString *filePath = nil;
                    NSString *videoPath = nil;
                    
                    if (document.localDocumentId != 0)
                    {
                        filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForLocalDocumentId:document.localDocumentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
                        videoPath = [filePath stringByAppendingString:@".mov"];
                    }
                    else
                    {
                        filePath = [[TGPreparedLocalDocumentMessage localDocumentDirectoryForDocumentId:document.documentId version:document.version] stringByAppendingPathComponent:[document safeFileName]];
                        videoPath = [filePath stringByAppendingString:@".mov"];
                    }
                    
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
                    
                    [_imageViewModel setVideoPathSignal:videoSignal];
                }
            }
        }
    }
    
    return false;
}

- (bool)webpageContentsActivated
{
    return false;
}

- (void)setMediaIsAvailable:(bool)mediaIsAvailable {
    bool wasAvailable = self.mediaIsAvailable;
    
    [super setMediaIsAvailable:mediaIsAvailable];
    
    if (!wasAvailable && mediaIsAvailable && self.boundToContainer) {
        if ([_imageViewModel boundView] != nil && self.context.autoplayAnimations && mediaIsAvailable) {
            [self activateWebpageContents];
        }
    }
    
    [self updateOverlayAnimated:false];
}

- (void)updateMediaProgressVisible:(bool)mediaProgressVisible mediaProgress:(float)mediaProgress animated:(bool)animated {
    [super updateMediaProgressVisible:mediaProgressVisible mediaProgress:mediaProgress animated:animated];
    
    [self updateOverlayAnimated:animated];
}

- (void)imageDataInvalidated:(NSString *)imageUrl {
    if ([_imageDataInvalidationUrl isEqualToString:imageUrl]) {
        if (_imageDataInvalidationBlock) {
            _imageDataInvalidationBlock();
        }
    }
}

- (void)stopInlineMedia:(int32_t)__unused excludeMid
{
    [_imageViewModel setVideoPathSignal:nil];
    _activatedMedia = false;
    if (_isAnimation) {
        [self updateOverlayAnimated:false];
    }
}

- (void)updateOverlayAnimated:(bool)animated {
    bool isCoub = [[_webPage.siteName lowercaseString] isEqualToString:@"coub"];
    bool isInstagram = [[_webPage.siteName lowercaseString] isEqualToString:@"instagram"];
    
    if (!_isVideo && isInstagram) {
        [_imageViewModel setNone];
    }
    else if (_imageViewModel.manualProgress) {
        if (self.mediaProgressVisible) {
            [_imageViewModel setProgress:self.mediaProgress animated:animated];
        } else if (self.mediaIsAvailable) {
            if (_activatedMedia) {
                [_imageViewModel setNone];
            } else {
                if (_isVideo) {
                    [_imageViewModel setPlay];
                } else {
                    if (self.context.autoplayAnimations || isCoub) {
                        [_imageViewModel setNone];
                    } else if (_isAnimation) {
                        [_imageViewModel setPlay];
                    } else {
                        [_imageViewModel setNone];
                    }
                }
            }
        } else {
            [_imageViewModel setDownload];
        }
    }
}

- (void)resumeInlineMedia {
    if (_isAnimation && self.context.autoplayAnimations && self.mediaIsAvailable && !_activatedMedia) {
        [self activateWebpageContents];
    }
}

- (bool)isPreviewableAtPoint:(CGPoint)point
{
    if (_imageInText || _isAnimation || _isVideo || _webPage.embedUrl.length > 0 || _webPage.document != nil)
        return false;
    
    point = CGPointMake(point.x, point.y - self.frame.origin.y);
    
    return CGRectContainsPoint(_imageViewModel.frame, point);
}

@end
