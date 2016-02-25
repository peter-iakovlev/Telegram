/*
 * AttitudeESKF.hpp
 *
 *  Copyright (c) 2013 Gareth Cross. All rights reserved.
 *
 *  This file is part of kalman-ios.
 *
 *  kalman-ios is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  kalman-ios is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with kalman-ios.  If not, see <http://www.gnu.org/licenses/>.
 *
 *	Created on: 12/24/2013
 *		Author: gareth
 */

#ifndef __AttitudeESKF__
#define __AttitudeESKF__

#include "quaternion.hpp"
#include "matrix.hpp"

/**
 *  @class AttitudeESKF
 *  @brief Implementation of an error-state EKF for attidude determination using Quaternions
 *  @note Two possible reference vectors (gravity and magnetic field) are used.
 *  @see 'Attitude Error Representations for Kalman Filtering' F. Landis Markley
 */
class AttitudeESKF
{
public:
    
    /**
     *  @brief Ctor, initializes P,Q and R with identity matrices
     */
    AttitudeESKF();
    
    /**
     *  @brief Perform the prediction step
     *  @param wg Uncorrected gyroscope readings (fixed frame)
     *  @param dt Time step
     *
     *  @note Integrates the nominal state using RK4.
     */
    void predict(const matrix<3>& wg, float dt);
    
    /**
     *  @brief Perform the update step
     *  @param ab Accelerometer readings
     *  @param mb Uncorrected magnetometer readings
     *  @param includeMag If true, magnetometer data is used in update step
     *
     *  @note Without includeMag=true, no yaw corrections are possible.
     */
    void update(const matrix<3>& ab, const matrix<3>& mb, bool includeMag);
  
    /*
     *  Accessors for internal state variables
     */
    
    const quat& getState() const { return m_q; }    /** Orientation as quaternion */
    
    bool isStable() const { return m_isStable; }    /** False if the kalman gain is singular */
    
    void setGyroBias(const matrix<3>& bias) { m_b = bias; } /** Steady-state bias of the gyroscope */
    
    void setMagnetometerOffset(const matrix<3>& offset) { m_mc = offset; }  /** Bias of the magnetic field */
    
    void setInertialField(const matrix<3>& mi) { m_mi = mi; }  /** Magnetic field in inertial frame */
    
    matrix<3,3>& Q() { return m_Q; }    /** Process covariance matrix */
    matrix<6,6>& R() { return m_R; }    /** Measurement covariance matrix */
    
    const matrix<3>& getAPred() const { return m_aPred; }   /** Predicted acceleration */
    
    const matrix<3>& getMPred() const { return m_mPred; }   /** Predicted magnetic field */
    
    const matrix<3>& getMMeas() const { return m_mMeas; }   /** Measured magnetic field, after normalization */
    
public:
    
    quat m_q;
    matrix<3> m_dx;
    
    matrix<3> m_b;
    matrix<3> m_mc;
    matrix<3> m_mi;
    
    matrix<3,3> m_P;
    matrix<3,3> m_Q;
    matrix<6,6> m_R;
    
    bool m_isStable;
    
    matrix<3> m_aPred;
    matrix<3> m_mPred;
    matrix<3> m_mMeas;
};


#endif /* defined(__AttitudeESKF__) */
