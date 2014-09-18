#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLgeochats_Located : NSObject <TLObject>

@property (nonatomic, retain) NSArray *results;
@property (nonatomic, retain) NSArray *messages;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;

@end

@interface TLgeochats_Located$geochats_located : TLgeochats_Located


@end

