#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLRichText;

@interface TLRichText : NSObject <TLObject>


@end

@interface TLRichText$textEmpty : TLRichText


@end

@interface TLRichText$textPlain : TLRichText

@property (nonatomic, retain) NSString *text;

@end

@interface TLRichText$textBold : TLRichText

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLRichText$textItalic : TLRichText

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLRichText$textUnderline : TLRichText

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLRichText$textStrike : TLRichText

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLRichText$textFixed : TLRichText

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLRichText$textUrl : TLRichText

@property (nonatomic, retain) TLRichText *text;
@property (nonatomic, retain) NSString *url;
@property (nonatomic) int64_t webpage_id;

@end

@interface TLRichText$textEmail : TLRichText

@property (nonatomic, retain) TLRichText *text;
@property (nonatomic, retain) NSString *email;

@end

@interface TLRichText$textConcat : TLRichText

@property (nonatomic, retain) NSArray *texts;

@end

