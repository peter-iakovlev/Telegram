#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLupdates_State;

@interface TLupdates_Difference : NSObject <TLObject>


@end

@interface TLupdates_Difference$updates_differenceEmpty : TLupdates_Difference

@property (nonatomic) int32_t date;
@property (nonatomic) int32_t seq;

@end

@interface TLupdates_Difference$updates_difference : TLupdates_Difference

@property (nonatomic, retain) NSArray *n_new_messages;
@property (nonatomic, retain) NSArray *n_new_encrypted_messages;
@property (nonatomic, retain) NSArray *other_updates;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) TLupdates_State *state;

@end

@interface TLupdates_Difference$updates_differenceSlice : TLupdates_Difference

@property (nonatomic, retain) NSArray *n_new_messages;
@property (nonatomic, retain) NSArray *n_new_encrypted_messages;
@property (nonatomic, retain) NSArray *other_updates;
@property (nonatomic, retain) NSArray *chats;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) TLupdates_State *intermediate_state;

@end

@interface TLupdates_Difference$updates_differenceTooLong : TLupdates_Difference

@property (nonatomic) int32_t pts;

@end

