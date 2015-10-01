/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <UIKit/UIKit.h>

typedef enum {
    TGActionSheetActionTypeGeneric = 0,
    TGActionSheetActionTypeCancel = 1,
    TGActionSheetActionTypeDestructive = 2
} TGActionSheetActionType;

@interface TGActionSheetAction : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *action;
@property (nonatomic) TGActionSheetActionType type;

- (instancetype)initWithTitle:(NSString *)title action:(NSString *)action;
- (instancetype)initWithTitle:(NSString *)title action:(NSString *)action type:(TGActionSheetActionType)type;

@end

@interface TGActionSheet : UIActionSheet

@property (nonatomic, copy) bool (^dismissBlock)(id target, NSString *action);

- (instancetype)initWithTitle:(NSString *)title actions:(NSArray *)actions actionBlock:(void (^)(id target, NSString *action))actionBlock target:(id)target;

@end
