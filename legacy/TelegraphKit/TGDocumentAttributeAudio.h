#import <Foundation/Foundation.h>

#import "PSCoding.h"

@interface TGDocumentAttributeAudio : NSObject <NSCoding, PSCoding>

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *performer;
@property (nonatomic, readonly) int32_t duration;

- (instancetype)initWithTitle:(NSString *)title performer:(NSString *)performer duration:(int32_t)duration;

@end
