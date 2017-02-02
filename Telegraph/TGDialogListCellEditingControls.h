#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    TGDialogListCellEditingControlsDelete,
    TGDialogListCellEditingControlsPin,
    TGDialogListCellEditingControlsUnpin,
    TGDialogListCellEditingControlsMute,
    TGDialogListCellEditingControlsUnmute
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

- (void)setButtonBytes:(NSArray *)buttonTypes;
- (void)setExpanded:(bool)expanded animated:(bool)animated;
- (bool)isExpanded;
- (void)setExpandable:(bool)expandable;

@end

#ifdef __cplusplus
}
#endif
