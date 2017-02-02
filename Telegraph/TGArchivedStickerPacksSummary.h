#import <Foundation/Foundation.h>

@interface TGArchivedStickerPacksSummary : NSObject <NSCoding>

@property (nonatomic, readonly) NSUInteger count;

- (instancetype)initWithCount:(NSUInteger)count;

@end
