#import "TGModernViewModel.h"

@class TGModernViewContext;

typedef enum {
    TGWebpageFooterModelActionNone,
    TGWebpageFooterModelActionGeneric,
    TGWebpageFooterModelActionOpenURL,
    TGWebpageFooterModelActionDownload,
    TGWebpageFooterModelActionPlay
} TGWebpageFooterModelAction;

@interface TGWebpageFooterModel : TGModernViewModel

@property (nonatomic, strong, readonly) TGModernViewContext *context;
@property (nonatomic) bool mediaIsAvailable;
@property (nonatomic) float mediaProgress;
@property (nonatomic) bool mediaProgressVisible;
@property (nonatomic) bool boundToContainer;

- (instancetype)initWithContext:(TGModernViewContext *)context incoming:(bool)incoming;

- (void)layoutForContainerSize:(CGSize)containerSize contentSize:(CGSize)contentSize needsContentUpdate:(bool *)needsContentUpdate bottomInset:(bool *)bottomInset;

- (CGSize)contentSizeForContainerSize:(CGSize)containerSize contentSize:(CGSize)contentSize needsContentsUpdate:(bool *)needsContentsUpdate;
- (void)layoutContentInRect:(CGRect)rect bottomInset:(CGFloat *)bottomInset;

- (void)bindSpecialViewsToContainer:(UIView *)container viewStorage:(TGModernViewStorage *)viewStorage atItemPosition:(CGPoint)itemPosition;
- (void)updateSpecialViewsPositions:(CGPoint)itemPosition;
- (bool)preferWebpageSize;

+ (UIColor *)colorForAccentText:(bool)incoming;

- (TGWebpageFooterModelAction)webpageActionAtPoint:(CGPoint)point;
- (bool)activateWebpageContents;
- (bool)webpageContentsActivated;
- (NSString *)linkAtPoint:(CGPoint)point regionData:(__autoreleasing NSArray **)regionData;

- (UIView *)referenceViewForImageTransition;
- (void)setMediaVisible:(bool)mediaVisible;

- (void)updateMediaProgressVisible:(bool)mediaProgressVisible mediaProgress:(float)mediaProgress animated:(bool)animated;

- (void)imageDataInvalidated:(NSString *)imageUrl;
- (void)stopInlineMedia;
- (void)resumeInlineMedia;

@end
