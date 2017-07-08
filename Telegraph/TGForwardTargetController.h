/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGViewController.h"

#import "TGNavigationController.h"

#import "ActionStage.h"

#import "TGContactsController.h"

@interface TGForwardTargetController : TGViewController <ASWatcher, TGViewControllerNavigationBarAppearance, TGNavigationControllerItem>

@property (nonatomic, strong) NSString *controllerTitle;
@property (nonatomic, strong) NSString *confirmationDefaultPersonFormat;
@property (nonatomic, strong) NSString *confirmationDefaultGroupFormat;

@property (nonatomic, strong) ASHandle *actionHandle;
@property (nonatomic, strong) ASHandle *watcherHandle;

@property (nonatomic) bool skipConfirmation;
@property (nonatomic) bool doNothing;

- (id)initWithForwardMessages:(NSArray *)forwardMessages sendMessages:(NSArray *)sendMessages shareLink:(NSDictionary *)shareLink showSecretChats:(bool)showSecretChats;
- (id)initWithSelectBlockTarget;
- (id)initWithSelectPrivacyTarget:(NSString *)title placeholder:(NSString *)placeholder;
- (id)initWithSelectPrivacyTarget:(NSString *)title placeholder:(NSString *)placeholder dialogs:(bool)dialogs;
- (id)initWithSelectTarget;
- (id)initWithSelectTarget:(bool)showSecretChats;
- (id)initWithSelectGroup;
- (id)initWithDocumentFile:(NSURL *)fileUrl size:(int)size;
- (id)initWithDocumentFiles:(NSArray *)fileDescs;

- (TGContactsController *)contactsController;

@end
