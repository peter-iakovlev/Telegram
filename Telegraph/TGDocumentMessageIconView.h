#import "TGModernView.h"

@protocol TGMessageImageViewDelegate;

@interface TGDocumentMessageIconView : UIView <TGModernView>

@property (nonatomic, weak) id<TGMessageImageViewDelegate> delegate;

@property (nonatomic, strong) NSString *fileName;

@property (nonatomic) bool incoming;
@property (nonatomic) int overlayType;
@property (nonatomic) CGFloat progress;

- (void)setOverlayType:(int)overlayType animated:(bool)animated;
- (void)setProgress:(CGFloat)progress animated:(bool)animated;

@end
