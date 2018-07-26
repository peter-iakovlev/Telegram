#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLExportedMessageLink : NSObject <TLObject>

@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSString *html;

@end

@interface TLExportedMessageLink$exportedMessageLink : TLExportedMessageLink


@end

