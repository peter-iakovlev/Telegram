#import <Foundation/Foundation.h>

@protocol TGModernMediaListItem;

@protocol TGModernMediaListSelectableItem <TGModernMediaListItem, NSCopying>

@property (nonatomic, copy) void (^itemSelected)(id<TGModernMediaListItem> item);
@property (nonatomic, copy) bool (^isItemSelected)(id<TGModernMediaListItem> item);
@property (nonatomic, copy) bool (^isItemHidden)(id<TGModernMediaListItem> item);

- (NSString *)uniqueId;

@end
