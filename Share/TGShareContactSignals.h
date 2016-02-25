#import <SSignalKit/SSignalKit.h>
#import <UIKit/UIKit.h>

#import "TGContactModel.h"

@interface TGShareContactSignals : NSObject

+ (SSignal *)contactMessageContentForContact:(TGContactModel *)contact parentController:(UIViewController *)parentController;

@end
