//
//  KFEstimator.h
//  kalman-ios
//
//  Created by Gareth Cross on 12/27/2013.
//  Copyright (c) 2013 gareth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

#include "AttitudeESKF.hpp"

@interface KFEstimator : NSObject
{}

- (void)readAccel:(CMAcceleration)accel rates:(CMRotationRate)rates field:(CMMagneticField)field;

@property (nonatomic, assign) BOOL gyroCalibrated;
@property (nonatomic, assign) BOOL compassCalibrated;

@property (nonatomic, readonly) AttitudeESKF * eskf;
@end
