#import <Foundation/Foundation.h>

@class TGConversation;

@interface TGChannelList : NSObject

- (instancetype)initWithChannels:(NSArray *)channels;

- (NSArray *)channels;
- (bool)updateChannel:(TGConversation *)conversation;
- (void)commitUpdatedChannels;

@end
