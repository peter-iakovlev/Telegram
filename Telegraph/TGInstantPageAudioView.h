#import <UIKit/UIKit.h>

#import "TGInstantPageLayout.h"
#import "TGInstantPageDisplayView.h"

@class TGDocumentMediaAttachment;

@interface TGInstantPageAudioView : UIView <TGInstantPageDisplayView>

@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *document;

- (instancetype)initWithFrame:(CGRect)frame document:(TGDocumentMediaAttachment *)document presentation:(TGInstantPagePresentation *)presentation;

+ (CGFloat)height;

@end
