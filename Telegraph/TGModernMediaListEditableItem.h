#import <LegacyComponents/TGModernMediaListItem.h>

@protocol TGMediaEditableItem;
@class TGMediaEditingContext;

@protocol TGModernMediaListEditableItem <TGModernMediaListItem>

@property (nonatomic, strong) TGMediaEditingContext *editingContext;

- (id<TGMediaEditableItem>)editableMediaItem;

@end
