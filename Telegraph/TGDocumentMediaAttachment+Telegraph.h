/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import "TGDocumentMediaAttachment.h"

#import "TL/TLMetaScheme.h"

#import "SecretLayer23.h"
#import "SecretLayer46.h"
#import "SecretLayer66.h"

@interface TGDocumentMediaAttachment (Telegraph)

+ (NSArray *)parseAttribtues:(NSArray *)descs;

- (instancetype)initWithTelegraphDocumentDesc:(TLDocument *)desc;
- (instancetype)initWithSecret23Desc:(Secret23_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)desc;
- (instancetype)initWithSecret46ExternalDesc:(Secret46_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)desc;
- (instancetype)initWithSecret66ExternalDesc:(Secret66_DecryptedMessageMedia_decryptedMessageMediaExternalDocument *)desc;

@end
