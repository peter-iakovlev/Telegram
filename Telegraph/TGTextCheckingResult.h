#import <Foundation/Foundation.h>

typedef enum {
    TGTextCheckingResultTypeMention,
    TGTextCheckingResultTypeHashtag,
    TGTextCheckingResultTypeCommand,
    TGTextCheckingResultTypeBold,
    TGTextCheckingResultTypeUltraBold,
    TGTextCheckingResultTypeItalic,
    TGTextCheckingResultTypeCode,
    TGTextCheckingResultTypeLink
} TGTextCheckingResultType;

@interface TGTextCheckingResult : NSObject

@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) TGTextCheckingResultType type;
@property (nonatomic, strong, readonly) NSString *contents;

- (instancetype)initWithRange:(NSRange)range type:(TGTextCheckingResultType)type contents:(NSString *)contents;

@end
