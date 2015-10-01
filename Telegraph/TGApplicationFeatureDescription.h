#import <Foundation/Foundation.h>

@interface TGApplicationFeatureDescription : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, readonly) bool enabled;
@property (nonatomic, strong, readonly) NSString *disabledMessage;

- (instancetype)initWithIdentifier:(NSString *)identifier enabled:(bool)enabled disabledMessage:(NSString *)disabledMessage;

@end
