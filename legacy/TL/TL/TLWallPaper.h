#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"


@interface TLWallPaper : NSObject <TLObject>

@property (nonatomic) int32_t n_id;
@property (nonatomic, retain) NSString *title;
@property (nonatomic) int32_t color;

@end

@interface TLWallPaper$wallPaper : TLWallPaper

@property (nonatomic, retain) NSArray *sizes;

@end

@interface TLWallPaper$wallPaperSolid : TLWallPaper

@property (nonatomic) int32_t bg_color;

@end

