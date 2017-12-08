#import <LegacyComponents/LegacyComponents.h>

#import <QuickLook/QuickLook.h>

@interface TGDocumentController : QLPreviewController

@property (nonatomic, assign) bool previewMode;
@property (nonatomic, copy) void (^shareAction)(NSArray *peerIds, NSString *caption);

- (instancetype)initWithURL:(NSURL *)url messageId:(int32_t)messageId;

@property (nonatomic, assign) bool useDefaultAction;

@end
