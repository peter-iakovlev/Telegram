#import "TGInstantPage+TG.h"

#import "TGMessage+Telegraph.h"
#import "TGConversation+Telegraph.h"

#import "TGImageMediaAttachment+Telegraph.h"
#import "TGDocumentMediaAttachment+Telegraph.h"

static TGRichText *parseText(TLRichText *textDesc) {
    if ([textDesc isKindOfClass:[TLRichText$textPlain class]]) {
        TLRichText$textPlain *text = (TLRichText$textPlain *)textDesc;
        return [[TGRichTextPlain alloc] initWithText:text.text];
    } else if ([textDesc isKindOfClass:[TLRichText$textBold class]]) {
        TLRichText$textBold *text = (TLRichText$textBold *)textDesc;
        return [[TGRichTextBold alloc] initWithText:parseText(text.text)];
    } else if ([textDesc isKindOfClass:[TLRichText$textItalic class]]) {
        TLRichText$textItalic *text = (TLRichText$textItalic *)textDesc;
        return [[TGRichTextItalic alloc] initWithText:parseText(text.text)];
    } else if ([textDesc isKindOfClass:[TLRichText$textUnderline class]]) {
        TLRichText$textUnderline *text = (TLRichText$textUnderline *)textDesc;
        return [[TGRichTextUnderline alloc] initWithText:parseText(text.text)];
    } else if ([textDesc isKindOfClass:[TLRichText$textStrike class]]) {
        TLRichText$textStrike *text = (TLRichText$textStrike *)textDesc;
        return [[TGRichTextStrikethrough alloc] initWithText:parseText(text.text)];
    } else if ([textDesc isKindOfClass:[TLRichText$textFixed class]]) {
        TLRichText$textFixed *text = (TLRichText$textFixed *)textDesc;
        return [[TGRichTextFixed alloc] initWithText:parseText(text.text)];
    } else if ([textDesc isKindOfClass:[TLRichText$textUrl class]]) {
        TLRichText$textUrl *text = (TLRichText$textUrl *)textDesc;
        return [[TGRichTextUrl alloc] initWithText:parseText(text.text) url:text.url webpageId:text.webpage_id];
    } else if ([textDesc isKindOfClass:[TLRichText$textEmail class]]) {
        TLRichText$textEmail *text = (TLRichText$textEmail *)textDesc;
        return [[TGRichTextEmail alloc] initWithText:parseText(text.text) email:text.email];
    } else if ([textDesc isKindOfClass:[TLRichText$textConcat class]]) {
        TLRichText$textConcat *text = (TLRichText$textConcat *)textDesc;
        NSMutableArray *texts = [[NSMutableArray alloc] init];
        for (TLRichText *itemDesc in text.texts) {
            TGRichText *parsedText = parseText(itemDesc);
            if (parsedText != nil) {
                [texts addObject:parsedText];
            }
        }
        return [[TGRichTextCollection alloc] initWithTexts:texts];
    }
    return nil;
}

static TGInstantPageBlock *parseBlock(TLPageBlock *blockDesc) {
    if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockTitle class]]) {
        TLPageBlock$pageBlockTitle *block = (TLPageBlock$pageBlockTitle *)blockDesc;
        return [[TGInstantPageBlockTitle alloc] initWithText:parseText(block.text)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockSubtitle class]]) {
        TLPageBlock$pageBlockSubtitle *block = (TLPageBlock$pageBlockSubtitle *)blockDesc;
        return [[TGInstantPageBlockSubtitle alloc] initWithText:parseText(block.text)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockAuthorDate class]]) {
        TLPageBlock$pageBlockAuthorDate *block = (TLPageBlock$pageBlockAuthorDate *)blockDesc;
        return [[TGInstantPageBlockAuthorAndDate alloc] initWithAuthor:parseText(block.author) date:block.published_date];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockHeader class]]) {
        TLPageBlock$pageBlockHeader *block = (TLPageBlock$pageBlockHeader *)blockDesc;
        return [[TGInstantPageBlockHeader alloc] initWithText:parseText(block.text)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockSubheader class]]) {
        TLPageBlock$pageBlockSubheader *block = (TLPageBlock$pageBlockSubheader *)blockDesc;
        return [[TGInstantPageBlockSubheader alloc] initWithText:parseText(block.text)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockParagraph class]]) {
        TLPageBlock$pageBlockParagraph *block = (TLPageBlock$pageBlockParagraph *)blockDesc;
        return [[TGInstantPageBlockParagraph alloc] initWithText:parseText(block.text)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockPreformatted class]]) {
        TLPageBlock$pageBlockPreformatted *block = (TLPageBlock$pageBlockPreformatted *)blockDesc;
        return [[TGInstantPageBlockPreFormatted alloc] initWithText:parseText(block.text) language:block.language];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockFooter class]]) {
        TLPageBlock$pageBlockFooter *block = (TLPageBlock$pageBlockFooter *)blockDesc;
        return [[TGInstantPageBlockFooter alloc] initWithText:parseText(block.text)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockDivider class]]) {
        return [[TGInstantPageBlockDivider alloc] init];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockList class]]) {
        TLPageBlock$pageBlockList *block = (TLPageBlock$pageBlockList *)blockDesc;
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (TLRichText *item in block.items) {
            TGRichText *parsedItem = parseText(item);
            if (parsedItem != nil) {
                [items addObject:parsedItem];
            }
        }
        return [[TGInstantPageBlockList alloc] initWithOrdered:block.ordered items:items];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockBlockquote class]]) {
        TLPageBlock$pageBlockBlockquote *block = (TLPageBlock$pageBlockBlockquote *)blockDesc;
        return [[TGInstantPageBlockBlockQuote alloc] initWithText:parseText(block.text) caption:parseText(block.caption)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockPullquote class]]) {
        TLPageBlock$pageBlockPullquote *block = (TLPageBlock$pageBlockPullquote *)blockDesc;
        return [[TGInstantPageBlockPullQuote alloc] initWithText:parseText(block.text) caption:parseText(block.caption)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockPhoto class]]) {
        TLPageBlock$pageBlockPhoto *block = (TLPageBlock$pageBlockPhoto *)blockDesc;
        return [[TGInstantPageBlockPhoto alloc] initWithPhotoId:block.photo_id caption:parseText(block.caption)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockVideo class]]) {
        TLPageBlock$pageBlockVideo *block = (TLPageBlock$pageBlockVideo *)blockDesc;
        return [[TGInstantPageBlockVideo alloc] initWithVideoId:block.video_id caption:parseText(block.caption) autoplay:block.flags & (1 << 0) loop:block.flags & (1 << 1)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockEmbedMeta class]]) {
        TLPageBlock$pageBlockEmbedMeta *block = (TLPageBlock$pageBlockEmbedMeta *)blockDesc;
        return [[TGInstantPageBlockEmbed alloc] initWithUrl:block.url html:block.html posterPhotoId:block.poster_photo_id caption:parseText(block.caption) size:CGSizeMake(block.w, block.h) fillWidth:block.flags & (1 << 0) enableScrolling:block.flags & (1 << 3)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockSlideshow class]]) {
        TLPageBlock$pageBlockSlideshow *block = (TLPageBlock$pageBlockSlideshow *)blockDesc;
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (TLPageBlock *item in block.items) {
            TGInstantPageBlock *parsedItem = parseBlock(item);
            if (parsedItem != nil) {
                [items addObject:parsedItem];
            }
        }
        return [[TGInstantPageBlockSlideshow alloc] initWithItems:items caption:parseText(block.caption)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockCollage class]]) {
        TLPageBlock$pageBlockCollage *block = (TLPageBlock$pageBlockCollage *)blockDesc;
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (TLPageBlock *item in block.items) {
            TGInstantPageBlock *parsedItem = parseBlock(item);
            if (parsedItem != nil) {
                [items addObject:parsedItem];
            }
        }
        return [[TGInstantPageBlockCollage alloc] initWithItems:items caption:parseText(block.caption)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockCover class]]) {
        TLPageBlock$pageBlockCover *block = (TLPageBlock$pageBlockCover *)blockDesc;
        return [[TGInstantPageBlockCover alloc] initWithBlock:parseBlock(block.cover)];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockEmbedPost class]]) {
        TLPageBlock$pageBlockEmbedPost *block = (TLPageBlock$pageBlockEmbedPost *)blockDesc;
        
        NSMutableArray *blocks = [[NSMutableArray alloc] init];
        for (id subBlock in block.blocks) {
            TGInstantPageBlock *parsedSubBlock = parseBlock(subBlock);
            if (parsedSubBlock != nil) {
                [blocks addObject:parsedSubBlock];
            }
        }
        
        return [[TGInstantPageBlockEmbedPost alloc] initWithAuthor:block.author date:block.date caption:parseText(block.caption) url:block.url webpageId:block.webpage_id blocks:blocks authorPhotoId:block.author_photo_id];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockAnchor class]]) {
        return [[TGInstantPageBlockAnchor alloc] initWithName:((TLPageBlock$pageBlockAnchor *)blockDesc).name];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockChannel class]]) {
        TGConversation *conversation = [[TGConversation alloc] initWithTelegraphChatDesc:((TLPageBlock$pageBlockChannel *)blockDesc).channel];
        conversation.kind = TGConversationKindTemporaryChannel;
        return [[TGInstantPageBlockChannel alloc] initWithChannel:conversation];
    } else if ([blockDesc isKindOfClass:[TLPageBlock$pageBlockAudio class]]) {
        TLPageBlock$pageBlockAudio *block = (TLPageBlock$pageBlockAudio *)blockDesc;
        return [[TGInstantPageBlockAudio alloc] initWithAudioId:block.audio_id caption:parseText(block.caption)];
    }
    return nil;
}

@implementation TGInstantPage (TG)

+ (TGInstantPage *)parse:(TLPage *)pageDescription {
    NSMutableArray *blocks = [[NSMutableArray alloc] init];
    for (TLPageBlock *block in pageDescription.blocks) {
        TGInstantPageBlock *parsedBlock = parseBlock(block);
        if (parsedBlock != nil) {
            [blocks addObject:parsedBlock];
        }
    }
    
    NSMutableDictionary *images = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *videos = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *documents = [[NSMutableDictionary alloc] init];
    for (id mediaDesc in pageDescription.photos) {
        TGImageMediaAttachment *imageMedia = [[TGImageMediaAttachment alloc] initWithTelegraphDesc:mediaDesc];
        images[@(((TGImageMediaAttachment *)imageMedia).imageId)] = imageMedia;
    }
    for (id documentDesc in pageDescription.documents) {
        TGDocumentMediaAttachment *documentAttachment = [[TGDocumentMediaAttachment alloc] initWithTelegraphDocumentDesc:documentDesc];
        
        bool isAnimated = false;
        TGVideoMediaAttachment *videoMedia = nil;
        for (id attribute in documentAttachment.attributes) {
            if ([attribute isKindOfClass:[TGDocumentAttributeVideo class]]) {
                TGDocumentAttributeVideo *video = attribute;
                
                videoMedia = [[TGVideoMediaAttachment alloc] init];
                videoMedia.videoId = documentAttachment.documentId;
                videoMedia.accessHash = documentAttachment.accessHash;
                videoMedia.duration = video.duration;
                videoMedia.dimensions = video.size;
                videoMedia.thumbnailInfo = documentAttachment.thumbnailInfo;
                videoMedia.caption = documentAttachment.caption;
                
                for (id additionalAttribute in documentAttachment.attributes) {
                    if ([additionalAttribute isKindOfClass:[TLDocumentAttribute$documentAttributeHasStickers class]]) {
                        videoMedia.hasStickers = true;
                        break;
                    }
                }
                
                TGVideoInfo *videoInfo = [[TGVideoInfo alloc] init];
                [videoInfo addVideoWithQuality:1 url:[[NSString alloc] initWithFormat:@"video:%lld:%lld:%d:%d", videoMedia.videoId, videoMedia.accessHash, documentAttachment.datacenterId, documentAttachment.size] size:documentAttachment.size];
                videoMedia.videoInfo = videoInfo;
            } else if ([attribute isKindOfClass:[TGDocumentAttributeAnimated class]]) {
                isAnimated = true;
            }
        }
        
        if (videoMedia != nil) {
            videos[@(videoMedia.videoId)] = videoMedia;
        }
        documents[@(documentAttachment.documentId)] = documentAttachment;
    }
    
    return [[TGInstantPage alloc] initWithIsPartial:[pageDescription isKindOfClass:[TLPage$pagePart class]] blocks:blocks images:images videos:videos documents:documents];
}

@end
