#import "TGViewController.h"

@class TGImageInfo;

@interface TGWebSearchController : TGViewController

@property (nonatomic, copy) void (^dismiss)(void);
@property (nonatomic, copy) void (^completion)(TGWebSearchController *sender);
@property (nonatomic, copy) void (^avatarCreated)(UIImage *);

@property (nonatomic, readonly) bool avatarSelection;
@property (nonatomic, assign) bool disallowCaptions;

- (instancetype)initForAvatarSelection:(bool)avatarSelection;

- (NSArray *)selectedItemSignals:(id (^)(id, NSString *))imageDescriptionGenerator;

+ (void)clearRecents;
+ (void)addRecentSelectedItems:(NSArray *)items;

@end
