 #import <UIKit/UIKit.h>

#import "TGInstantPageDisplayView.h"
#import "TGInstantPageLayout.h"

@class TGInstantPageMedia;

@interface TGInstantPageSlideshowView : UIView <TGInstantPageDisplayView>

@property (nonatomic, strong, readonly) NSArray<TGInstantPageMedia *> *medias;

- (instancetype)initWithFrame:(CGRect)frame medias:(NSArray<TGInstantPageMedia *> *)medias;

@end
