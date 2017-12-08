#import <Foundation/Foundation.h>
#import <SSignalKit/SSignalKit.h>

#import "TGPresentationPallete.h"
#import "TGPresentationImages.h"

@interface TGPresentation : NSObject

@property (nonatomic, readonly) TGPresentationPallete *pallete;
@property (nonatomic, readonly) TGPresentationImages *images;

+ (TGPresentation *)current;
+ (SSignal *)signal;

@end
