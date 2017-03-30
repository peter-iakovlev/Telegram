#import <UIKit/UIKit.h>

@class TGMessage;
@class TGUser;

@interface TGCallGroup : NSObject

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSArray *messages;
@property (nonatomic, readonly) TGUser *peer;
@property (nonatomic, readonly) bool failed;

@property (nonatomic, readonly) TGMessage *message;
@property (nonatomic, readonly) bool outgoing;

@property (nonatomic, readonly) NSString *displayType;

- (instancetype)initWithMessages:(NSArray *)messages peer:(TGUser *)peer failed:(bool)failed;

@end

@interface TGCallCell : UITableViewCell

@property (nonatomic, copy) void (^infoPressed)(void);
@property (nonatomic, copy) void (^deletePressed)(void);

@property (nonatomic) bool isLastCell;

- (void)setupWithCallGroup:(TGCallGroup *)group;

- (bool)isEditingControlsExpanded;
- (void)setEditingConrolsExpanded:(bool)expanded animated:(bool)animated;

@end
