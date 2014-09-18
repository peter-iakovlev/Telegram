/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <map>
#endif

@interface TGPhoneNumber : NSObject

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *number;

@property (nonatomic) int phoneId;

- (id)initWithLabel:(NSString *)label number:(NSString *)number;

- (bool)isEqualToPhoneNumber:(TGPhoneNumber *)other;
- (bool)isEqualToPhoneNumberFuzzy:(TGPhoneNumber *)other;

@end

@interface TGPhonebookContact : NSObject <NSCopying>

@property (nonatomic) int nativeId;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;

@property (nonatomic, strong) NSArray *phoneNumbers;

#ifdef __cplusplus
- (void)fillPhoneHashToNativeMap:(std::map<int, int> *)pMap replace:(bool)replace;
#endif

- (bool)isEqualToPhonebookContact:(TGPhonebookContact *)other;
- (bool)hasEqualPhonesFuzzy:(NSArray *)otherPhones;

- (bool)containsPhoneId:(int)phoneId;

@end
