#import <UIKit/UIKit.h>

@class TGUser;
@class TGPresentation;

@interface TGPassportHeaderView : UIView

@property (nonatomic, assign) UIEdgeInsets safeAreaInset;
@property (nonatomic, assign) bool avatarHidden;
@property (nonatomic, assign) bool logoHidden;

- (void)setBot:(TGUser *)bot;
- (void)setPresentation:(TGPresentation *)presentation;

@end
