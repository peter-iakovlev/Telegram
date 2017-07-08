#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    TGDialogListCellEditingControlsDelete,
    TGDialogListCellEditingControlsPin,
    TGDialogListCellEditingControlsUnpin,
    TGDialogListCellEditingControlsMute,
    TGDialogListCellEditingControlsUnmute,
    TGDialogListCellEditingControlsBan,
    TGDialogListCellEditingControlsPromote,
    TGDialogListCellEditingControlsRestrict,
} TGDialogListCellEditingControlButton;

NSArray *TGDialogListCellEditingControlButtonsPinDelete();
NSArray *TGDialogListCellEditingControlButtonsUnpinDelete();
NSArray *TGDialogListCellEditingControlButtonsMutePinDelete();
NSArray *TGDialogListCellEditingControlButtonsUnmutePinDelete();
NSArray *TGDialogListCellEditingControlButtonsMuteUnpinDelete();
NSArray *TGDialogListCellEditingControlButtonsUnmuteUnpinDelete();

@interface TGDialogListCellEditingControls : UIView

@property (nonatomic, copy) void (^requestDelete)();
@property (nonatomic, copy) void (^togglePinned)(bool);
@property (nonatomic, copy) void (^toggleMute)(bool);
@property (nonatomic, copy) void (^requestPromote)();
@property (nonatomic, copy) void (^requestRestrict)();
@property (nonatomic, copy) void (^expandedUpdated)(bool);

- (void)setButtonBytes:(NSArray *)buttonTypes;
- (void)setExpanded:(bool)expanded animated:(bool)animated;
- (bool)isExpanded;
- (void)setExpandable:(bool)expandable;
- (void)setLabelOnly:(bool)labelOnly;
- (void)setSmallLabels:(bool)smallLabels;
- (void)setOffsetLabels:(bool)offsetLabels;

@end

#ifdef __cplusplus
}
#endif
