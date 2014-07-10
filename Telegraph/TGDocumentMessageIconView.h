#import "TGModernView.h"

@protocol TGMessageImageViewDelegate;

@interface TGDocumentMessageIconView : UIView <TGModernView>

@property (nonatomic, weak) id<TGMessageImageViewDelegate> delegate;

@property (nonatomic, strong) NSString *fileExtension;

@property (nonatomic) int overlayType;
@property (nonatomic) float progress;

- (void)setOverlayType:(int)overlayType animated:(bool)animated;
- (void)setProgress:(float)progress animated:(bool)animated;

@end
