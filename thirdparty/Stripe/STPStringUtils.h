//
//  STPStringUtils.h
//  Stripe
//
//  Created by Brian Dorfman on 9/7/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^STPTaggedSubstringCompletionBlock)(NSString *string, NSRange range);
typedef void(^STPTaggedSubstringsCompletionBlock)(NSString *string, NSDictionary <NSString *, NSValue *> *tagMap);

@interface STPStringUtils : NSObject
/**
 *  Takes a string with the named html-style tags, removes the tags,
 *  and then calls the completion block with the modified string and the range 
 *  in it that the tag would have enclosed.
 *  
 *  E.g. Passing in @"Test <b>string</b>" with tag @"b" would call completion
 *  with @"Test string" and NSMakeRange(5,6).
 *  
 *  Completion is always called, location of range is NSNotFound with the unmodified
 *  string if a match could not be found.
 *
 *  @param string     The string with tagged substrings.
 *  @param tag        The tag to search for.
 *  @param completion The string with the named tag removed and the range of the
 *                    substring it covered.
 */
+ (void)parseRangeFromString:(NSString *)string
                     withTag:(NSString *)tag
                  completion:(STPTaggedSubstringCompletionBlock)completion;

/**
 *  Like `parseRangeFromString:withTag:completion:` but you can pass in a set
 *  of unique tags to get the ranges for and it will return you the mapping.
 *  
 *  E.g. Passing @"<a>Test</a> <b>string</b>" with the tag set [a, b]
 *  will get you a completion block dictionary that looks like
 *  @{ @"a" : NSMakeRange(0,4),
 *     @"b" : NSMakeRange(5,6) }
 *
 *  @param string     The string with tagged substrings.
 *  @param tags       The tags to search for.
 *  @param completion The string with the named tags removed and the ranges of the
 *                    substrings they covered (wrapped in NSValue)
 * 
 *  @warning Doesn't currently support overlapping tag ranges because that's
 *           complicated and we don't need it at the moment.
 */
+ (void)parseRangesFromString:(NSString *)string
                     withTags:(NSSet<NSString *> *)tags
                   completion:(STPTaggedSubstringsCompletionBlock)completion;
@end
