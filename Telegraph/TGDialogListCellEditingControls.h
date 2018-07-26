#import <UIKit/UIKit.h>

@class TGPresentation;

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    TGDialogListCellEditingControlsDelete = 1 << 0,
    TGDialogListCellEditingControlsPin = 1 << 1,
    TGDialogListCellEditingControlsUnpin = 1 << 2,
    TGDialogListCellEditingControlsMute = 1 << 3,
    TGDialogListCellEditingControlsUnmute = 1 << 4,
    TGDialogListCellEditingControlsBan = 1 << 5,
    TGDialogListCellEditingControlsPromote = 1 << 6,
    TGDialogListCellEditingControlsRestrict = 1 << 7,
    TGDialogListCellEditingControlsGroup = 1 << 8,
    TGDialogListCellEditingControlsUngroup = 1 << 9,
    TGDialogListCellEditingControlsRead = 1 << 10,
    TGDialogListCellEditingControlsUnread = 1 << 11,
} TGDialogListCellEditingControlButton;

@interface TGDialogListCellEditingControls : UIView

@property (nonatomic, strong) TGPresentation *presentation;

@property (nonatomic, copy) void (^requestDelete)();
@property (nonatomic, copy) void (^togglePinned)(bool);
@property (nonatomic, copy) void (^toggleMute)(bool);
@property (nonatomic, copy) void (^requestPromote)();
@property (nonatomic, copy) void (^requestRestrict)();
@property (nonatomic, copy) void (^toggleGrouped)(bool);
@property (nonatomic, copy) void (^toggleRead)(bool);
@property (nonatomic, copy) void (^expandedUpdated)(bool);

- (void)setLeftButtonTypes:(NSArray *)leftButtonTypes rightButtonTypes:(NSArray *)rightButtonTypes;
- (void)setExpanded:(bool)expanded animated:(bool)animated;
- (bool)isExpanded;
- (void)setExpandable:(bool)expandable;
- (void)setLabelOnly:(bool)labelOnly;
- (void)setSmallLabels:(bool)smallLabels;
- (void)setOffsetLabels:(bool)offsetLabels;
- (void)resetButtons;
- (bool)isTracking;

@end

#ifdef __cplusplus
}
#endif
