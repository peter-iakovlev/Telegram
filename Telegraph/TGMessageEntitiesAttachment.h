#import "TGMediaAttachment.h"

#import "TGMessageEntityUrl.h"
#import "TGMessageEntityEmail.h"
#import "TGMessageEntityTextUrl.h"

#define TGMessageEntitiesAttachmentType ((int)0x8C2E3CCE)

@interface TGMessageEntitiesAttachment : TGMediaAttachment <TGMediaAttachmentParser, NSCoding>

@property (nonatomic, strong) NSArray *entities;

@end
