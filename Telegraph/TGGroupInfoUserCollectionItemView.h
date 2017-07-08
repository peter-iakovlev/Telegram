/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGEditableCollectionItemView.h"

@class TGGroupInfoUserCollectionItemView;

@protocol TGGroupInfoUserCollectionItemViewDelegate <NSObject>

@optional

- (void)groupInfoUserItemViewRequestedDeleteAction:(TGGroupInfoUserCollectionItemView *)groupInfoUserItemView;
- (void)switchValueChanged:(bool)switchValue;

@end

@interface TGGroupInfoUserCollectionItemView : TGEditableCollectionItemView

@property (nonatomic, weak) id<TGGroupInfoUserCollectionItemViewDelegate> delegate;

@property (nonatomic, copy) void (^requestRestrict)();
@property (nonatomic, copy) void (^requestPromote)();
@property (nonatomic, copy) void (^requestDelete)();

- (void)setFirstName:(NSString *)firstName lastName:(NSString *)lastName uidForPlaceholderCalculation:(int32_t)uidForPlaceholderCalculation canPromote:(bool)canPromote canRestrict:(bool)canRestrict canBan:(bool)canBan canDelete:(bool)canDelete;
- (void)setStatus:(NSString *)status active:(bool)active;
- (void)setAvatarUri:(NSString *)avatarUri;
- (void)setIsSecretChat:(bool)isSecretChat;
- (void)setCustomLabel:(NSString *)customLabel;

- (void)setDisplaySwitch:(bool)displaySwitch;
- (void)setEnableSwitch:(bool)enableSwitch animated:(bool)animated;
- (void)setSwitchIsOn:(bool)switchIsOn animated:(bool)animated;

- (void)setDisplayCheck:(bool)displayCheck;
- (void)setCheckIsOn:(bool)checkIsOn;

- (void)setRequiresFullSeparator:(bool)requiresFullSeparator;

- (void)setDisabled:(bool)disabled animated:(bool)animated;

@end
