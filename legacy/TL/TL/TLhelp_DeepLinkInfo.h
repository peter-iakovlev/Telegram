#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLhelp_DeepLinkInfo : NSObject <TLObject>

@end

@interface TLhelp_DeepLinkInfo$help_deepLinkInfoEmpty : TLhelp_DeepLinkInfo

@end

@interface TLhelp_DeepLinkInfo$help_deepLinkInfoMeta : TLhelp_DeepLinkInfo

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSArray *entities;

@end
