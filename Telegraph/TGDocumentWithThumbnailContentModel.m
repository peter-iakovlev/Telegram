#import "TGDocumentWithThumbnailContentModel.h"

#import "TGDocumentMediaAttachment+Telegraph.h"

#import "TGModernLabelViewModel.h"
#import "TGMessageImageViewModel.h"
#import "TGStringUtils.h"

#import "TGModernFlatteningViewModel.h"

#import "TGFont.h"

@interface TGDocumentWithThumbnailContentModel () {
    TGDocumentMediaAttachment *_document;
    
    NSString *_legacyThumbnailCacheUri;
    bool _mediaIsAvailable;
    bool _progressVisible;
    float _progress;
    
    TGModernLabelViewModel *_documentNameModel;
    TGModernLabelViewModel *_documentSizeModel;
    TGMessageImageViewModel *_imageModel;
    
    NSString *_sizeText;
    
    TGModernFlatteningViewModel *_contentModel;
}

@end

@implementation TGDocumentWithThumbnailContentModel

- (instancetype)initWithDocument:(TGDocumentMediaAttachment *)document incomingAppearance:(bool)incomingAppearance {
    self = [super init];
    if (self != nil) {
        _contentModel = [[TGModernFlatteningViewModel alloc] init];
        [self addSubmodel:_contentModel];
        
        _document = document;
        
        CGSize dimensions = CGSizeZero;
        _legacyThumbnailCacheUri = [document.thumbnailInfo closestImageUrlWithSize:CGSizeZero resultingSize:&dimensions];
        dimensions.width *= 10.0f;
        dimensions.height *= 10.0f;
        
        NSString *filePreviewUri = nil;
        
        if ((document.documentId != 0 || document.localDocumentId != 0) && _legacyThumbnailCacheUri.length != 0)
        {
            NSMutableString *previewUri = [[NSMutableString alloc] initWithString:@"file-thumbnail://?"];
            if (document.documentId != 0)
                [previewUri appendFormat:@"id=%" PRId64 "", document.documentId];
            else
                [previewUri appendFormat:@"local-id=%" PRId64 "", document.localDocumentId];
            
            [previewUri appendFormat:@"&file-name=%@", [document.fileName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            CGSize thumbnailSize = CGSizeMake(86.0f, 86.0f);
            CGSize renderSize = CGSizeZero;
            if (dimensions.width < dimensions.height)
            {
                renderSize.height = CGFloor((dimensions.height * thumbnailSize.width / dimensions.width));
                renderSize.width = thumbnailSize.width;
            }
            else
            {
                renderSize.width = CGFloor((dimensions.width * thumbnailSize.height / dimensions.height));
                renderSize.height = thumbnailSize.height;
            }
            
            [previewUri appendFormat:@"&width=%d&height=%d&renderWidth=%d&renderHeight=%d", (int)thumbnailSize.width, (int)thumbnailSize.height, (int)renderSize.width, (int)renderSize.height];
            
            [previewUri appendString:@"&rounded=1"];
            
            if (_legacyThumbnailCacheUri != nil)
                [previewUri appendFormat:@"&legacy-thumbnail-cache-url=%@", [TGStringUtils stringByEscapingForURL:_legacyThumbnailCacheUri]];
            
            filePreviewUri = previewUri;
        }
        
        static UIColor *incomingNameColor = nil;
        static UIColor *outgoingNameColor = nil;
        static UIColor *incomingSizeColor = nil;
        static UIColor *outgoingSizeColor = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            incomingNameColor = UIColorRGB(0x0b8bed);
            outgoingNameColor = UIColorRGB(0x3faa3c);
            incomingSizeColor = UIColorRGB(0x999999);
            outgoingSizeColor = UIColorRGB(0x6fb26a);
        });
        
        _documentNameModel = [[TGModernLabelViewModel alloc] initWithText:@"" textColor:incomingAppearance ? incomingNameColor : outgoingNameColor font:TGCoreTextSystemFontOfSize(16.0f) maxWidth:145.0f truncateInTheMiddle:true];
        [_contentModel addSubmodel:_documentNameModel];
        
        NSString *sizeString = @"";
        if (document.size == INT_MAX)
        {
            sizeString = TGLocalized(@"Conversation.Processing");
        }
        else if (document.size >= 1024 * 1024)
        {
            sizeString = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Megabytes"), (float)(float)document.size / (1024 * 1024)];
        }
        else if (document.size >= 1024)
        {
            sizeString = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Kilobytes"), (int)(int)(document.size / 1024)];
        }
        else
        {
            sizeString = [[NSString alloc] initWithFormat:TGLocalized(@"Conversation.Bytes"), (int)(int)(document.size)];
        }
        
        _sizeText = sizeString;
        
        _documentSizeModel = [[TGModernLabelViewModel alloc] initWithText:@"" textColor:!incomingAppearance ? outgoingSizeColor : incomingSizeColor font:TGCoreTextSystemFontOfSize(13.0f) maxWidth:145.0f];
        [_contentModel addSubmodel:_documentSizeModel];
        
        _imageModel = [[TGMessageImageViewModel alloc] initWithUri:filePreviewUri];
        _imageModel.skipDrawInContext = true;
        _imageModel.timestampHidden = true;
        _imageModel.overlayDiameter = 44.0f;
        _imageModel.frame = CGRectMake(0.0f, 0.0f, 74.0f, 74.0f);
        [self addSubmodel:_imageModel];
    }
    return self;
}

- (void)layoutForContainerSize:(CGSize)__unused containerSize {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 140.0f, 60.0f);
}

@end
