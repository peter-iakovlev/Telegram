#import <Foundation/Foundation.h>

#import "TLObject.h"
#import "TLMetaRpc.h"

@class TLRichText;
@class TLPageBlock;
@class TLChat;

@interface TLPageBlock : NSObject <TLObject>


@end

@interface TLPageBlock$pageBlockTitle : TLPageBlock

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLPageBlock$pageBlockSubtitle : TLPageBlock

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLPageBlock$pageBlockHeader : TLPageBlock

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLPageBlock$pageBlockSubheader : TLPageBlock

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLPageBlock$pageBlockParagraph : TLPageBlock

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLPageBlock$pageBlockPreformatted : TLPageBlock

@property (nonatomic, retain) TLRichText *text;
@property (nonatomic, retain) NSString *language;

@end

@interface TLPageBlock$pageBlockFooter : TLPageBlock

@property (nonatomic, retain) TLRichText *text;

@end

@interface TLPageBlock$pageBlockDivider : TLPageBlock


@end

@interface TLPageBlock$pageBlockList : TLPageBlock

@property (nonatomic) bool ordered;
@property (nonatomic, retain) NSArray *items;

@end

@interface TLPageBlock$pageBlockBlockquote : TLPageBlock

@property (nonatomic, retain) TLRichText *text;
@property (nonatomic, retain) TLRichText *caption;

@end

@interface TLPageBlock$pageBlockPullquote : TLPageBlock

@property (nonatomic, retain) TLRichText *text;
@property (nonatomic, retain) TLRichText *caption;

@end

@interface TLPageBlock$pageBlockPhoto : TLPageBlock

@property (nonatomic) int64_t photo_id;
@property (nonatomic, retain) TLRichText *caption;

@end

@interface TLPageBlock$pageBlockVideo : TLPageBlock

@property (nonatomic) int32_t flags;
@property (nonatomic) int64_t video_id;
@property (nonatomic, retain) TLRichText *caption;

@end

@interface TLPageBlock$pageBlockCover : TLPageBlock

@property (nonatomic, retain) TLPageBlock *cover;

@end

@interface TLPageBlock$pageBlockEmbedPost : TLPageBlock

@property (nonatomic, retain) NSString *url;
@property (nonatomic) int64_t webpage_id;
@property (nonatomic) int64_t author_photo_id;
@property (nonatomic, retain) NSString *author;
@property (nonatomic) int32_t date;
@property (nonatomic, retain) NSArray *blocks;
@property (nonatomic, retain) TLRichText *caption;

@end

@interface TLPageBlock$pageBlockCollage : TLPageBlock

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) TLRichText *caption;

@end

@interface TLPageBlock$pageBlockSlideshow : TLPageBlock

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) TLRichText *caption;

@end

@interface TLPageBlock$pageBlockUnsupported : TLPageBlock


@end

@interface TLPageBlock$pageBlockAnchor : TLPageBlock

@property (nonatomic, retain) NSString *name;

@end

@interface TLPageBlock$pageBlockEmbedMeta : TLPageBlock

@property (nonatomic) int32_t flags;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *html;
@property (nonatomic) int64_t poster_photo_id;
@property (nonatomic) int32_t w;
@property (nonatomic) int32_t h;
@property (nonatomic, retain) TLRichText *caption;

@end

@interface TLPageBlock$pageBlockAuthorDate : TLPageBlock

@property (nonatomic, retain) TLRichText *author;
@property (nonatomic) int32_t published_date;

@end

@interface TLPageBlock$pageBlockChannel : TLPageBlock

@property (nonatomic, retain) TLChat *channel;

@end

@interface TLPageBlock$pageBlockAudio : TLPageBlock

@property (nonatomic) int64_t audio_id;
@property (nonatomic, retain) TLRichText *caption;

@end

