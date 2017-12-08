/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>
#import <SSignalKit/SSignalKit.h>

#import "TGDialogListCellAssetsSource.h"

@interface TGDialogListSearchCell : UITableViewCell

@property (nonatomic, strong) id<TGDialogListCellAssetsSource> assetsSource;

@property (nonatomic) int64_t conversationId;

@property (nonatomic, strong) NSString *titleTextFirst;
@property (nonatomic, strong) NSString *titleTextSecond;
@property (nonatomic, strong) NSAttributedString *attributedSubtitleText;

@property (nonatomic, strong) NSString *avatarUrl;

@property (nonatomic) int isSavedMessages;

@property (nonatomic) bool isChat;
@property (nonatomic) bool isEncrypted;
@property (nonatomic) bool isVerified;
@property (nonatomic) int encryptedUserId;

@property (nonatomic) int unreadCount;

@property (nonatomic) SMetaDisposable *channelDisposable;

- (void)resetView:(bool)animated;

- (void)setBoldMode:(int)index;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier assetsSource:(id<TGDialogListCellAssetsSource>)assetsSource;

- (UIView *)avatarSnapshotView;
- (CGRect)avatarFrame;
- (CGRect)textContentFrame;

@end
