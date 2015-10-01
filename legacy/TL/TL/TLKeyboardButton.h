#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLKeyboardButton : NSObject <TLObject>

@property (nonatomic, retain) NSString *text;

@end

@interface TLKeyboardButton$keyboardButton : TLKeyboardButton


@end

