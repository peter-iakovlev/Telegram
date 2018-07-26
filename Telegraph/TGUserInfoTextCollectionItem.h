#import "TGCollectionItem.h"

@interface TGUserInfoTextCollectionItem : TGCollectionItem

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) bool highlightLinks;

@property (nonatomic, assign) bool checking;
@property (nonatomic, assign) bool isChecked;

@property (nonatomic, copy) void (^followLink)(NSString *);
@property (nonatomic, copy) void (^holdLink)(NSString *);

- (CGFloat)maximumWidth;

@end
