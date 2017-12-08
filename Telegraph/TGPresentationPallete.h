#import <Foundation/Foundation.h>

#define COLOR @property (nonatomic, readonly) UIColor *

@interface TGPresentationPallete : NSObject

@property (nonatomic, readonly) bool isDark;

COLOR backgroundColor;
COLOR textColor;
COLOR secondaryTextColor;
COLOR accentColor;
COLOR destructiveColor;
COLOR selectionColor;
COLOR separatorColor;

COLOR barBackgroundColor;
COLOR barSeparatorColor;
COLOR navigationTitleColor;
COLOR navigationSubtitleColor;
COLOR navigationActiveSubtitleColor;
COLOR navigationButtonColor;
COLOR navigationBadgeColor;
COLOR navigationBadgeTextColor;
COLOR navigationBadgeBorderColor;

COLOR tabTextColor;
COLOR tabIconColor;
COLOR tabActiveIconColor;
COLOR tabBadgeColor;
COLOR tabBadgeTextColor;
COLOR tabBadgeBorderColor;

COLOR searchBarBackgroundColor;
COLOR searchBarTextColor;
COLOR searchBarPlaceholderColor;

COLOR dialogTitleColor;
COLOR dialogNameColor;
COLOR dialogTextColor;
COLOR dialogDraftColor;
COLOR dialogDateColor;
COLOR dialogChecksColor;
COLOR dialogVerifiedBackgroundColor;
COLOR dialogVerifiedIconColor;
COLOR dialogPinnedBackgroundColor;
COLOR dialogPinnedIconColor;
COLOR dialogEncryptedColor;
COLOR dialogBadgeColor;
COLOR dialogBadgeTextColor;
COLOR dialogBadgeMutedColor;
COLOR dialogBadgeMutedTextColor;
COLOR dialogUnsentColor;

COLOR chatIncomingBubbleColor;
COLOR chatIncomingBubbleBorderColor;
COLOR chatIncomingHighlightedBubbleColor;
COLOR chatIncomingHighlightedBubbleBorderColor;
COLOR chatIncomingTextColor;
COLOR chatIncomingSubtextColor;
COLOR chatIncomingAccentColor;
COLOR chatIncomingLinkColor;

COLOR chatOutgoingBubbleColor;
COLOR chatOutgoingBubbleBorderColor;
COLOR chatOutgoingHighlightedBubbleColor;
COLOR chatOutgoingHighlightedBubbleBorderColor;
COLOR chatOutgoingTextColor;
COLOR chatOutgoingSubtextColor;
COLOR chatOutgoingAccentColor;
COLOR chatOutgoingLinkColor;

COLOR chatChecksColor;
COLOR chatChecksMediaColor;

COLOR chatServiceBackgroundColor;
COLOR chatServiceTextColor;
COLOR chatServiceIconColor;

COLOR chatInputBackgroundColor;
COLOR chatInputBorderColor;
COLOR chatInputPlaceholderColor;
COLOR chatInputTextColor;

COLOR callsOutgoingIconColor;

COLOR collectionMenuBackgroundColor;
COLOR collectionMenuCellBackgroundColor;
COLOR collectionMenuCellSelectionColor;
COLOR collectionMenuTextColor;
COLOR collectionMenuPlaceholderColor;
COLOR collectionMenuVariantColor;
COLOR collectionMenuAccentColor;
COLOR collectionMenuDestructiveColor;
COLOR collectionMenuSeparatorColor;
COLOR collectionMenuAccessoryColor;
COLOR collectionMenuCommentColor;
COLOR collectionMenuBadgeColor;
COLOR collectionMenuBadgeTextColor;
COLOR collectionMenuSwitchColor;
COLOR collectionMenuCheckColor;

@end

#undef COLOR
