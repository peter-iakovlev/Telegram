#import <Foundation/Foundation.h>

@class TLhelp_TermsOfService;

@interface TGTermsOfService : NSObject

@property (nonatomic, readonly) bool popup;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSArray *entities;
@property (nonatomic, readonly) NSNumber *minimumAgeRequired;
@property (nonatomic, readonly) NSString *identifier;

- (instancetype)initWithTL:(TLhelp_TermsOfService *)tl;

@end
