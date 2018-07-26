#import <LegacyComponents/TGViewController.h>
#import <LegacyComponents/LegacyComponentsContext.h>

@class TGImageInfo;
@class TGSuggestionContext;
@class TGPresentation;

@interface TGWebSearchController : TGViewController

@property (nonatomic, copy) void (^avatarCompletionBlock)(UIImage *);
@property (nonatomic, copy) void (^completionBlock)(TGWebSearchController *sender);
@property (nonatomic, copy) void (^dismiss)(void);

@property (nonatomic, weak) TGNavigationController *parentNavigationController;

@property (nonatomic, readonly) bool avatarSelection;
@property (nonatomic, assign) bool captionsEnabled;
@property (nonatomic, assign) bool allowCaptionEntities;
@property (nonatomic, strong) TGSuggestionContext *suggestionContext;

@property (nonatomic, strong) TGPresentation *presentation;
@property (nonatomic, strong) NSString *recipientName;

- (instancetype)initWithContext:(id<LegacyComponentsContext>)context forAvatarSelection:(bool)avatarSelection embedded:(bool)embedded allowGrouping:(bool)allowGrouping;

- (NSArray *)selectedItemSignals:(id (^)(id, NSString *, NSArray *))imageDescriptionGenerator;

+ (void)clearRecents;
+ (void)addRecentSelectedItems:(NSArray *)items;

- (void)presentEmbeddedInController:(UIViewController *)controller animated:(bool)animated;
- (void)dismissEmbeddedAnimated:(bool)animated;

@end
