#import <Foundation/Foundation.h>

@interface TGTwoStepConfig : NSObject

@property (nonatomic, strong, readonly) NSData *nextSalt;
@property (nonatomic, strong, readonly) NSData *currentSalt;
@property (nonatomic, readonly) bool hasRecovery;
@property (nonatomic, strong, readonly) NSString *currentHint;
@property (nonatomic, strong, readonly) NSString *unconfirmedEmailPattern;

- (instancetype)initWithNextSalt:(NSData *)nextSalt currentSalt:(NSData *)currentSalt hasRecovery:(bool)hasRecovery currentHint:(NSString *)currentHint unconfirmedEmailPattern:(NSString *)unconfirmedEmailPattern;

@end
