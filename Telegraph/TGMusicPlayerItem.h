#import <Foundation/Foundation.h>

@class TGMessage;
@class TGDocumentMediaAttachment;

@interface TGMusicPlayerItem : NSObject

@property (nonatomic, strong, readonly) id<NSObject, NSCopying> key;
@property (nonatomic, strong, readonly) TGDocumentMediaAttachment *document;
@property (nonatomic, readonly) int64_t peerId;

+ (instancetype)itemWithMessage:(TGMessage *)message;

- (instancetype)initWithKey:(id<NSObject, NSCopying>)key document:(TGDocumentMediaAttachment *)document peerId:(int64_t)peerId;

@end
