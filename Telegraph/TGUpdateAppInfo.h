#import <Foundation/Foundation.h>

@class TLhelp_AppUpdate$help_appUpdateMeta;
@class TGDocumentMediaAttachment;

@interface TGUpdateAppInfo : NSObject

@property (nonatomic, readonly) bool popup;
@property (nonatomic, readonly) NSString *version;
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSArray *entities;

- (instancetype)initWithTL:(TLhelp_AppUpdate$help_appUpdateMeta *)update;

@end
