//
//  KFEstimator.m
//  kalman-ios
//
//  Created by Gareth Cross on 12/27/2013.
//  Copyright (c) 2013 gareth. All rights reserved.
//

#import "KFEstimator.h"
#include <mach/mach_time.h>

#include "AttitudeESKF.hpp"
#include <deque>

uint64_t getTime_ns()
{
    static mach_timebase_info_data_t s_timebase_info;
    
    //  get the time scale
    if (s_timebase_info.denom == 0) {
        mach_timebase_info(&s_timebase_info);
    }
    
    return ((mach_absolute_time() * (uint64_t)s_timebase_info.numer) / (uint64_t)s_timebase_info.denom);
}

double getTime()
{
    // mach_absolute_time() returns billionth of seconds
    const double kOneBillion = 1000000000.0;
    return getTime_ns() / kOneBillion;
}

float constrain(float v, float vmin, float vmax)
{
	if (v > vmax) return vmax;
	if (v < vmin) return vmin;
	return v;
}

BOOL skipCalibration = NO;

@interface KFEstimator ()
{
    double lastT;
    
    NSDate * lastDisturbance;
    
    int staticPts;
    matrix<3> mean_g, mean_m;
    matrix<3> max_m, min_m;
    float max_x, min_x, max_y, min_y;
}

@end

@implementation KFEstimator

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.gyroCalibrated = NO;
        self.compassCalibrated = NO;
        
        max_m = matrix<3>(-10000.0f, -10000.0f, -10000.0f);
        min_m = matrix<3>( 10000.0f,  10000.0f,  10000.0f);
        
        max_x = max_y = -1.0f;
        min_x = min_y =  1.0f;
        
        _eskf = new AttitudeESKF();
        
        if (skipCalibration) {
            _eskf->m_b = matrix<3> (0.037, -0.0029, -0.0002);
            _eskf->m_mc = matrix<3> (201.5953f, -291.3410f, 93.4031f);
            _eskf->m_mi = matrix<3> (0.35f, 0, 0.936f);
            
            _eskf->m_Q(0,0) = _eskf->m_Q(1,1) = _eskf->m_Q(2,2) = 1.0e-4f;
            
            _eskf->m_R(0,0) = _eskf->m_R(1,1) = _eskf->m_R(2,2) = 0.02f;
            _eskf->m_R = _eskf->m_R * 20;
            
            //  compass
            _eskf->m_R(3,3) = 1.0410;  _eskf->m_R(3,4) = 0.0650;  _eskf->m_R(3,5) = 0.0737;
            _eskf->m_R(4,3) = 0.0650;  _eskf->m_R(4,4) = 1.2123;  _eskf->m_R(4,5) = -0.1402;
            _eskf->m_R(5,3) = 0.0737;  _eskf->m_R(5,4) = -0.1402; _eskf->m_R(5,5) = 1.5370;
            
            //_eskf->m_R = _eskf->m_R * 0.01f;
            
            self.gyroCalibrated = YES;
            self.compassCalibrated = YES;
        }
    }
    return self;
}

- (void)dealloc
{
    if (_eskf) {
        delete _eskf;
    }
}

- (void)readAccel:(CMAcceleration)acceleration
            rates:(CMRotationRate)rotationRate
            field:(CMMagneticField)magneticField
{
    double T = getTime();
    float delta = (float)MAX(MIN(T - lastT, 0.1), 0.01);
    lastT = T;
    
    auto ar = matrix<3>(-acceleration.x, -acceleration.y, -acceleration.z);
    auto gr = matrix<3>(-rotationRate.x, -rotationRate.y, -rotationRate.z);
    auto mr = matrix<3>(-magneticField.x, -magneticField.y, -magneticField.z);
    
    //  get rough estimates of angles
    float phi = asin(-constrain(ar(1), -1.0f, 1.0f));	//	pitch
    float theta = atan2(ar(0), ar(2));                  //	roll

    if (!self.gyroCalibrated)
    {
        if (fabsf(phi) > 0.06f || fabsf(theta) > 0.06f || fabsf(gr(0)) > 0.1f || fabsf(gr(1)) > 0.1f || fabsf(gr(2)) > 0.1f) {
            lastDisturbance = [NSDate date];
            NSLog(@"Disturbed!");
        }
        
        if (lastDisturbance.timeIntervalSinceNow < -2.0 || !lastDisturbance)
        {
            //  at 'rest', record point
            
            mean_g = (mean_g * staticPts + gr) / (staticPts + 1);
            mean_m = (mean_m * staticPts + mr) / (staticPts + 1);
        }
        
        //  300 calibration points, the above method has ~ converged to the real mean
        if (staticPts++ == 300)
        {
            matrix <6,6> R; //  these params were determined in advanced using samples + matlab
            matrix <3,3> Q;
            
            //  gyroscope
            Q(0,0) = Q(1,1) = Q(2,2) = 0.0001f;
            
            //  accelerometer
            R(0,0) = R(1,1) = R(2,2) = 0.01f;
            R = R * 10;
            
            //  compass
            R(3,3) = 1.041;   R(3,4) =  0.065;  R(3,5) =  0.074;
            R(4,3) = 0.065;   R(4,4) =  1.212;  R(4,5) = -0.0140;
            R(5,3) = 0.074;   R(5,4) = -0.014;  R(5,5) =  1.537;
            
            _eskf->Q() = Q;
            _eskf->R() = R;    //  scale R up to smooth results
            
            _eskf->setGyroBias(mean_g);
            
            NSLog(@"Gyro calibrated, gyro bias: %f, %f, %f", mean_g(0), mean_g(1), mean_g(2));
            self.gyroCalibrated = YES;
        }
    }
    else if (!self.compassCalibrated)
    {
        for (int i=0; i < 3; i++) {
            max_m(i) = MAX(max_m(i), mr(i));
            min_m(i) = MIN(min_m(i), mr(i));
        }
        
        max_x = MAX(ar(0), max_x);
        min_x = MIN(ar(0), min_x);
        
        max_y = MAX(ar(1), max_y);
        min_y = MIN(ar(1), min_y);
        
        //  this is a lazy man's magnetometer calibration
        //  condition: swept through close to 180 degrees on both axes
        //  we consider this close enough to a sphere
        if ((max_x - min_x > 1.8f) &&
            (max_y - min_y > 1.8f))
        {
            auto offset = (max_m + min_m) * 0.5f;
            
            //  determine inertial magnetic field (x-axis aligned with field)
            mean_m = mean_m - offset;
            mean_m(0) = std::sqrt(mean_m(0)*mean_m(0) + mean_m(1)*mean_m(1));
            mean_m(1) = 0;
            //mean_m(2) = 0;
           // mean_m.normalize_safe();
            
            NSLog(@"Compass calibrated, offset: %f, %f, %f, inertial: %f, %f, %f", offset(0), offset(1), offset(2),
                  mean_m(0), mean_m(1), mean_m(2));
            
            _eskf->setMagnetometerOffset(offset);
            _eskf->setInertialField(mean_m);
            
            self.compassCalibrated = YES;
        }
    }
    else
    {
        //  we may now estimate everything
        _eskf->predict(gr, delta);
        _eskf->update(ar, mr, true);   //  true = use compass, false = integrate freely on yaw axis
    }
}

@end
