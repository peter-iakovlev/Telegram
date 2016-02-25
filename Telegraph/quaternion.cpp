/*
 * quaternion.cpp
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

#include <cmath>
#include "quaternion.hpp"

quat::quat()
{
    m_q[0] = 1.0f;
    m_q[1] = m_q[2] = m_q[3] = 0.0f;
}

quat::quat(float a, float b, float c, float d)
{
    this->a() = a;
    this->b() = b;
    this->c() = c;
    this->d() = d;
}

quat::quat(const quat& q)
{
    for (int i=0; i < 4; i++) {
        operator()(i) = q(i);
    }
}

quat::quat(quat&& q)
{
    for (int i=0; i < 4; i++) {
        operator()(i) = q(i);
    }
}

quat& quat::operator = (const quat& q)
{
    for (int i=0; i < 4; i++) {
        operator()(i) = q(i);
    }
    return *this;
}

float quat::norm() const
{
    return sqrtf(a()*a() + b()*b() + c()*c() + d()*d());
}

quat quat::conjugate() const
{
    return quat(a(), -b(), -c(), -d());
}

quat quat::transform(const quat& v)
{
    const quat& q = *this;
    return q * v * q.conjugate();
}

matrix<3,3> quat::to_matrix() const
{
    matrix<3,3> R;
    
    R(0,0) = a()*a() + b()*b() - c()*c() - d()*d();
    R(1,0) = 2*b()*c() + 2*a()*d();
    R(2,0) = 2*b()*d() - 2*a()*c();
    
    R(0,1) = 2*b()*c() - 2*a()*d();
    R(1,1) = a()*a() - b()*b() + c()*c() - d()*d();
    R(2,1) = 2*c()*d() + 2*a()*b();
    
    R(0,2) = 2*b()*d() + 2*a()*c();
    R(1,2) = 2*c()*d() - 2*a()*b();
    R(2,2) = a()*a() - b()*b() - c()*c() + d()*d();
    
    return R;
}

void quat::integrateRungeKutta4(const quat& w, float dt, bool normalize)
{
    quat& q = *this;
    quat qw = w * q * 0.5f;
    
    quat k2 = w * (q + qw*dt*0.5f) * 0.5f;
    quat k3 = w * (q + k2*dt*0.5f) * 0.5f;
    quat k4 = w * (q + k3*dt) * 0.5f;
    
    q += (qw + k2*2.0f + k3*2.0f + k4) * (dt / 6.0f);
    
    if (normalize) {
        q = q * (1.0f / q.norm());
    }
}

void quat::integrateEuler(const quat& w, float dt, bool normalize)
{
    quat& q = *this;
    q += (w * q * 0.5f) * dt;
    
    if (normalize) {
        q = q * (1.0f / q.norm());
    }
}

quat quat::rotation(float theta, float x, float y, float z)
{
    const float haversine = sinf(0.5f * theta);
    const float havercosine = cosf(0.5f * theta);
    
    return quat(
        havercosine,
        haversine * x,
        haversine * y,
        haversine * z
    );
}

quat operator * (const quat& a, const quat &b)
{
    quat lhs;
    
    lhs(0) = a(0)*b(0) - a(1)*b(1) - a(2)*b(2) - a(3)*b(3);
    lhs(1) = a(0)*b(1) + a(1)*b(0) + a(2)*b(3) - a(3)*b(2);
    lhs(2) = a(0)*b(2) - a(1)*b(3) + a(2)*b(0) + a(3)*b(1);
    lhs(3) = a(0)*b(3) + a(1)*b(2) - a(2)*b(1) + a(3)*b(0);
    
    return lhs;
}

quat operator * (const quat& a, const float s)
{
    quat lhs;
    
    for (int i=0; i < 4; i++) {
        lhs(i) = a(i) * s;
    }
    
    return lhs;
}

quat operator * (const float s, const quat& a)
{
    return operator * (a, s);
}

quat& operator *= (quat& a, const float s)
{
    for (int i=0; i < 4; i++) {
        a(i) *= s;
    }
    
    return a;
}

quat operator + (const quat& a, const quat &b)
{
    quat lhs;
    
    for (int i=0; i < 4; i++) {
        lhs(i) = a(i) + b(i);
    }
    
    return lhs;
}

quat& operator += (quat& a, const quat &b)
{
    for (int i=0; i < 4; i++) {
        a(i) += b(i);
    }
    
    return a;
}

