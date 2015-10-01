#import <SSignalKit/SSignalKit.h>

typedef enum {
    TGHashtagSpaceEntered = 1,
    TGHashtagSpaceSearchedBy = 2
} TGHashtagSpace;

@interface TGRecentHashtagsSignal : NSObject

+ (SSignal *)recentHashtagsFromSpaces:(int)spaces;

+ (void)addRecentHashtagsFromText:(NSString *)text space:(TGHashtagSpace)space;
+ (void)clearRecentHashtags;

@end
