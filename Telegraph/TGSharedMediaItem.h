#import <Foundation/Foundation.h>

#import "TGSharedMediaFilter.h"

@class TGMessage;
@class TGPresentation;

@protocol TGSharedMediaItem <NSObject, NSCopying>

- (int32_t)messageId;
- (NSTimeInterval)date;
- (TGMessage *)message;
- (bool)passesFilter:(id<TGSharedMediaFilter>)filter;

@optional

- (CGFloat)heightForWidth:(CGFloat)width;

@end
