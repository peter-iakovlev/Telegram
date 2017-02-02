#import <UIKit/UIKit.h>

#import "TGInstantPageDisplayView.h"
#import "TGInstantPageMediaArguments.h"
#import "TGInstantPageMedia.h"

@interface TGInstantPageImageView : UIView <TGInstantPageDisplayView>

@property (nonatomic, strong, readonly) TGInstantPageMedia *media;

@property (nonatomic, copy) void (^imageUpdated)();

- (instancetype)initWithFrame:(CGRect)frame media:(TGInstantPageMedia *)media arguments:(TGInstantPageMediaArguments *)arguments;
- (instancetype)initWithFrame:(CGRect)frame media:(TGInstantPageMedia *)media arguments:(TGInstantPageMediaArguments *)arguments imageUpdated:(void (^)())imageUpdated;

@end
