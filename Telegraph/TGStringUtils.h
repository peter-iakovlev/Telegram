/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    
int32_t murMurHash32(NSString *string);
int32_t murMurHashBytes32(void *bytes, int length);
int32_t phoneMatchHash(NSString *phone);
    
bool TGIsRTL();
bool TGIsArabic();
bool TGIsKorean();
bool TGIsLocaleArabic();
    
#ifdef __cplusplus
}
#endif

@interface TGStringUtils : NSObject

+ (NSString *)stringByEscapingForURL:(NSString *)string;
+ (NSString *)stringByEscapingForActorURL:(NSString *)string;
+ (NSString *)stringByEncodingInBase64:(NSData *)data;
+ (NSString *)stringByUnescapingFromHTML:(NSString *)srcString;

+ (NSString *)stringWithLocalizedNumber:(NSInteger)number;
+ (NSString *)stringWithLocalizedNumberCharacters:(NSString *)string;

+ (NSString *)md5:(NSString *)string;

+ (NSDictionary *)argumentDictionaryInUrlString:(NSString *)string;

+ (bool)stringContainsEmoji:(NSString *)string;

+ (NSString *)stringForMessageTimerSeconds:(NSUInteger)seconds;
+ (NSString *)stringForShortMessageTimerSeconds:(NSUInteger)seconds;
+ (NSArray *)stringComponentsForMessageTimerSeconds:(NSUInteger)seconds;
+ (NSString *)stringForUserCount:(NSUInteger)userCount;
+ (NSString *)stringForFileSize:(NSUInteger)size;
+ (NSString *)stringForFileSize:(NSUInteger)size precision:(NSInteger)precision;

+ (NSString *)integerValueFormat:(NSString *)prefix value:(NSInteger)value;
+ (NSString *)stringForMuteInterval:(int)value;
+ (NSString *)stringForRemainingMuteInterval:(int)value;

+ (NSString *)stringForDeviceType;

@end

@interface NSString (Telegraph)

- (int)lengthByComposedCharacterSequences;
- (int)lengthByComposedCharacterSequencesInRange:(NSRange)range;

- (NSData *)dataByDecodingHexString;
- (NSArray *)getEmojiFromString:(BOOL)checkColor;

- (bool)containsSingleEmoji;

- (bool)hasNonWhitespaceCharacters;

- (NSAttributedString *)attributedStringWithFormattingAndFontSize:(CGFloat)fontSize lineSpacing:(CGFloat)lineSpacing paragraphSpacing:(CGFloat)paragraphSpacing;

@end

@interface NSData (Telegraph)

- (NSString *)stringByEncodingInHex;

@end
