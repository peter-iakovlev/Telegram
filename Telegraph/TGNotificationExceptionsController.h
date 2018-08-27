#import <LegacyComponents/LegacyComponents.h>

@class TGPresentation;

@interface TGNotificationExceptionsController : TGViewController

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic, copy) void (^updatedExceptions)(NSArray *, NSDictionary *);

- (instancetype)initWithExceptions:(NSArray *)exceptions peers:(NSDictionary *)peers group:(bool)group;

@end
