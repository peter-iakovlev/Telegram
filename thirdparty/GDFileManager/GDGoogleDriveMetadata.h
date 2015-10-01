//
//  GDGoogleDriveMetadata.h
//  GDFileManagerExample
//
//  Created by Graham Dennis on 26/06/13.
//  Copyright (c) 2013 Graham Dennis. All rights reserved.
//

#import "GDDictionaryBackedObject.h"

@interface GDGoogleDriveMetadata : GDDictionaryBackedObject

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, readonly, copy) NSString *headRevisionIdentifier;
@property (nonatomic, readonly, copy) NSString *etag;
@property (nonatomic, readonly, copy) NSString *md5Checksum;
@property (nonatomic, readonly, copy) NSString *downloadURLString;
@property (nonatomic, readonly, copy) NSString *thumbnailURLString;
@property (nonatomic, readonly, copy) NSString *mimeType;
@property (nonatomic, readonly)       NSInteger fileSize;
@property (nonatomic, readonly)       CGSize imageSize;
@property (nonatomic, readonly)       NSArray *exportUrls;
@property (nonatomic, readonly, getter = isDirectory) BOOL directory;
@property (nonatomic, readonly, getter = isEditable) BOOL editable;

@end
