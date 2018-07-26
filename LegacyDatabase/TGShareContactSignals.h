#import <SSignalKit/SSignalKit.h>
#import <UIKit/UIKit.h>

#import "TGContactModel.h"

@class TGShareContext;

@interface TGShareContactSignals : NSObject

+ (SSignal *)contactMessageContentForContact:(TGContactModel *)contact parentController:(UIViewController *)parentController context:(TGShareContext *)context;

@end
