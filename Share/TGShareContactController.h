#import <UIKit/UIKit.h>

@class TGShareContext;
@class TGVCard;
@class TGContactModel;

@interface TGShareContactController : UIViewController

@property (nonatomic, copy) void (^completionBlock)(TGContactModel *);

- (instancetype)initWithContext:(TGShareContext *)context vCard:(TGVCard *)vcard uid:(int32_t)uid;

@end
