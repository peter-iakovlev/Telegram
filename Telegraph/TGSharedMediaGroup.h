#import <Foundation/Foundation.h>

typedef enum {
    TGSharedMediaGroupContentTypeUnknown,
    TGSharedMediaGroupContentTypeImage,
    TGSharedMediaGroupContentTypeVideo,
    TGSharedMediaGroupContentTypeFile,
    TGSharedMediaGroupContentTypeLink
} TGSharedMediaGroupContentType;

@interface TGSharedMediaGroup : NSObject

@property (nonatomic, readonly) NSTimeInterval date;
@property (nonatomic, strong, readonly) NSArray *items;
@property (nonatomic, readonly) TGSharedMediaGroupContentType contentType;

- (instancetype)initWithDate:(NSTimeInterval)date items:(NSArray *)items;

@end
