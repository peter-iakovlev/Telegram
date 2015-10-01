/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@interface TGDataResource : NSObject

- (NSData *)data;
- (NSInputStream *)stream;
- (UIImage *)image;
- (bool)isImageDecoded;

- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithInputStream:(NSInputStream *)stream;
- (instancetype)initWithImage:(UIImage *)image decoded:(bool)decoded;

@end
