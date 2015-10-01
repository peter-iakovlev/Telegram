#import <Foundation/Foundation.h>

#import "TGMusicPlayerItem.h"

@interface TGMusicPlayerPlaylist : NSObject

@property (nonatomic, strong, readonly) NSArray *items;
@property (nonatomic, strong, readonly) NSDictionary *itemKeyAliases;

- (instancetype)initWithItems:(NSArray *)items itemKeyAliases:(NSDictionary *)itemKeyAliases;

@end
