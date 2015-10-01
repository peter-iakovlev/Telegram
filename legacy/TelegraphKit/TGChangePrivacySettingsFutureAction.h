/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGFutureAction.h"

#define TGChangePrivacySettingsFutureActionType ((int)0x41D91E18)

@interface TGChangePrivacySettingsFutureAction : TGFutureAction

@property (nonatomic) bool disableSuggestions;
@property (nonatomic) bool hideContacts;
@property (nonatomic) bool hideLastVisit;
@property (nonatomic) bool hideLocation;

- (id)initWithDisableSuggestions:(bool)disableSuggestions hideContacts:(bool)hideContacts hideLastVisit:(bool)hideLastVisit hideLocation:(bool)hideLocation;

@end
