/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

typedef enum {
    TGFlatActionCellModeInvite = 0,
    TGFlatActionCellModeCreateGroup = 1,
    TGFlatActionCellModeCreateEncrypted = 2,
    TGFlatActionCellModeCreateGroupContacts = 3,
    TGFlatActionCellModeChannels = 4,
    TGFlatActionCellModeCreateChannel = 5,
    TGFlatActionCellModeCreateChannelGroup = 6,
    TGFlatActionCellModeAddPhoneNumber = 7,
    TGFlatActionCellModeShareApp = 8
} TGFlatActionCellMode;

@interface TGFlatActionCell : UITableViewCell

@property (nonatomic) TGFlatActionCellMode mode;

- (void)setPhoneNumber:(NSString *)phoneNumber;

@end
