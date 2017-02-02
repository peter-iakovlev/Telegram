#import "TGMediaAttachment.h"

#import "TGMessageEntityUrl.h"
#import "TGMessageEntityEmail.h"
#import "TGMessageEntityTextUrl.h"
#import "TGMessageEntityMention.h"
#import "TGMessageEntityHashtag.h"
#import "TGMessageEntityBotCommand.h"
#import "TGMessageEntityBold.h"
#import "TGMessageEntityItalic.h"
#import "TGMessageEntityCode.h"
#import "TGMessageEntityPre.h"
#import "TGMessageEntityMentionName.h"

#define TGMessageEntitiesAttachmentType ((int)0x8C2E3CCE)

@interface TGMessageEntitiesAttachment : TGMediaAttachment <TGMediaAttachmentParser, NSCoding>

@property (nonatomic, strong) NSArray *entities;

@end
