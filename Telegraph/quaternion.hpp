/*
 * quaternion.hpp
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
 *	Created on: 13/12/2013
 *		Author: gareth
 */

#ifndef quaternion_hpp
#define quaternion_hpp

#include "matrix.hpp"

/**
 *  @class Floating point representation of a quaternion
 */
class quat
{
public:
    
    /**
     *  @brief Create a quaternion with null rotation
     */
    quat();
    
    /**
     *  @brief Construct a quaterion
     *  @param a Scalar parameter
     *  @param b,c,d Complex parameters
     */
    quat(float a, float b, float c, float d);
    
    /**
     *  @brief Copy operator
     */
    quat(const quat& q);
    
    /**
     *  @brief Move operator
     */
    quat(quat&& q);
    
    /**
     *  @brief Assignment operator
     */
    quat& operator = (const quat& q);
    
    /**
     *  @brief L2 norm of the quaternion
     */
    float norm() const;
    
    /**
     *  @brief Complex conjugate quaternion
     */
    quat conjugate() const;
    
    /**
     *  @brief Transform a vector using this quaternion
     *  @param v Vector stored in the three complex terms
     */
    quat transform(const quat& v);
    
    /**
     *  @brief Convert a rotation quaternion to its matrix form
     *  @note The result is not correct if this quaternion is not a rotation in R3
     *  @return 3x3 Rotation matrix
     */
    matrix<3,3> to_matrix() const;
    
    /**
     *  @brief Integrate a rotation quaternion using 4th order Runge Kutta
     *  @param w Angular velocity (fixed frame), stored in 3 complex terms
     *  @param dt Time interval
     *  @param normalize If true, quaternion is normalized after integration
     */
    void integrateRungeKutta4(const quat& w, float dt, bool normalize = true);
    
    /**
     *  @brief Integrate a rotation quaterion using Euler stepping
     *  @param w Angular velocity (fixed frame), stored in 3 complex terms
     *  @param dt Time interval
     *  @param normalize If True, quaternion is normalized after integration
     */
    void integrateEuler(const quat& w, float dt, bool normalize = true);
    
    /**
     *  @brief Create a rotation quaterion
     *  @param theta Angle of rotation, radians
     *  @param x X component of rotation vector
     *  @param y Y component
     *  @param z Z component
     */
    static quat rotation(float theta, float x, float y, float z);
    
    /*
     *  Accessors
     */
    
    float& operator () (unsigned int i) { return m_q[i]; }
    const float& operator () (unsigned int i) const { return m_q[i]; }
    
    float& a() { return m_q[0]; }   /**< Scalar component */
    const float& a() const { return m_q[0]; }
    
    float& b() { return m_q[1]; }   /**< First complex dimension (i) */
    const float& b() const { return m_q[1]; }
    
    float& c() { return m_q[2]; }   /**< Second complex dimension (j) */
    const float& c() const { return m_q[2]; }
    
    float& d() { return m_q[3]; }   /**< Third complex dimension (k) */
    const float& d() const { return m_q[3]; }
    
private:
    float m_q[4];
};

/**
 *  @brief Multiply two quaternions
 *  @param a Left quaternion
 *  @param b Right quaternion
 *  @return Product of both quaternions
 */
quat operator * (const quat& a, const quat &b);

/**
 *  @brief Multiply a quaternion by a scalar
 *  @param a Quaternion
 *  @param s Scalar
 *  @return Scaled quaterion
 */
quat operator * (const quat& a, const float s);
quat operator * (const float s, const quat& a);

/**
 *  @brief Multiply a quaternion by a scalar, in place
 *  @param a Quaternion to scale
 *  @param s Scalar
 *  @return a
 */
quat& operator *= (quat& a, const float s);

/**
 *  @brief Add two quaternions (element-wise summation)
 *  @param a First quaternion
 *  @param b Second quaternion
 *  @return Sum
 */
quat operator + (const quat& a, const quat &b);

/**
 *  @brief Add-in place quaterion
 *  @param a First quaternion, is modified
 *  @param b Second quaternion
 *  @return Sum
 */
quat& operator += (quat& a, const quat &b);

#endif
