//
//  STPCardTuple.h
//  Stripe
//
//  Created by Jack Flintermann on 5/17/16.
//  Copyright © 2016 Stripe, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class STPCard;

@interface STPCardTuple : NSObject

+ (instancetype)tupleWithSelectedCard:(nullable STPCard *)selectedCard
                                cards:(nullable NSArray<STPCard *>*)cards;

@property(nonatomic, readonly, nullable)STPCard *selectedCard;
@property(nonatomic, readonly)NSArray<STPCard *> *cards;

@end

NS_ASSUME_NONNULL_END
