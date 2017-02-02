#import <Foundation/Foundation.h>

#import <SSignalKit/SSignalKit.h>

@interface TGDialogListRecentPeers : NSObject

@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSArray *peers;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title peers:(NSArray *)peers;

@end
