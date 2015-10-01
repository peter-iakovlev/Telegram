/*
 * This is the source code of Telegram for iOS v. 1.1
 * It is licensed under GNU GPL v. 2 or later.
 * You should have received a copy of the license in this archive (see LICENSE).
 *
 * Copyright Peter Iakovlev, 2013.
 */

#import <Foundation/Foundation.h>

@interface TGUpdate : NSObject

@property (nonatomic, strong) NSArray *updates;
@property (nonatomic) int date;
@property (nonatomic) int beginSeq;
@property (nonatomic) int endSeq;
@property (nonatomic) int messageDate;
@property (nonatomic, strong) NSArray *usersDesc;
@property (nonatomic, strong) NSArray *chatsDesc;

- (id)initWithUpdates:(NSArray *)updates date:(int)date beginSeq:(int)beginSeq endSeq:(int)endSeq messageDate:(int)messageDate usersDesc:(NSArray *)usersDesc chatsDesc:(NSArray *)chatsDesc;

@end
