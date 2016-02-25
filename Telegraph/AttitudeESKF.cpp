/*
 * AttitudeESKF.cpp
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

#include "AttitudeESKF.hpp"

AttitudeESKF::AttitudeESKF() :  m_q(quat(1.0f, 0.0f, 0.0f, 0.0f)),
                                m_P(matrix<3,3> :: identity()),
                                m_Q(matrix<3,3> :: identity()),
                                m_R(matrix<6,6> :: identity())
{
    m_isStable = true;
}

void AttitudeESKF::predict(const matrix<3>& wg, float dt)
{
    static auto I3 = matrix<3,3> :: identity();
    
    auto wt = wg - m_b;
    auto F = I3 - matrix <3,3> :: cross_skew(wt) * dt;    //     Jacobian of f(x,dx) w.r.t dx
    
    //  integrate nominal state
    m_q.integrateRungeKutta4(quat(0, wt(0), wt(1), wt(2)), dt);
    
    //  integrate covariance
    m_P = F * m_P * F.transposed() + m_Q;
}

#include <iostream>

void AttitudeESKF::update(const matrix<3>& ab, const matrix<3>& mb, bool includeMag)
{
    //  Jacobian of h(x,dx) w.r.t. dx, and residual vector
    matrix <6,3> H;
    matrix <6> r;

    //  rotation matrix: world -> body
    auto R = m_q.to_matrix();

    //  normalize acceleration
    matrix <3> a = ab;
    float mag_a = a.normalize_safe();

    //  predict gravity vector
    matrix <3> gi; gi(2) = 1.0f;
    m_aPred = R * gi;

    //  calculate gravity component of Jacobian and residual
    H.subs(0, 0, R * matrix<3,3> :: cross_skew( gi * -1 ));

    r(0) = a(0) - m_aPred(0);
    r(1) = a(1) - m_aPred(1);
    r(2) = a(2) - m_aPred(2);
    
    //printf("%6.3f, %6.3f, %6.3f\n", r(0), r(1), r(2));
    printf("peak %d %d %d\n", std::abs(r(0)) > 0.2 ? 1 : 0, std::abs(r(1)) > 0.2 ? 1 : 0, std::abs(r(2)) > 0.2 ? 1 : 0);

    if (includeMag)
    {
        float angles[3];
        R.extractYXZ(angles);
        
        //  tilt compensation matrix
        //  [cos(theta)          0        -sin(theta)        ]
        //  [sin(phi)sin(theta)  cos(phi)  sin(phi)cos(theta)]
        //  [sin(theta)cos(phi) -sin(phi)  cos(theta)cos(phi)]
        auto M = matrix<3,3> :: rotation_x(-angles[0]) * matrix <3,3> :: rotation_y(-angles[1]);
        M(2,0) = M(2,1) = M(2,2) = 0.0f;    //  <- ignore z contribution in observation
        
        //auto M = matrix<3,3> :: identity();
        
        auto Rz = M * R; // Rz = M * R (if M is the tilt compensation matrix)
        
        m_mMeas = M * (mb - m_mc);   //  centre and compensate
        //m_mMeas.normalize_safe();
        
        // rotation about yaw axis
        m_mPred = Rz * m_mi;
        //m_mPred.normalize_safe();
        
        //  M contribution to jacobian
        H.subs(3, 0, Rz * matrix<3,3> :: cross_skew( m_mi * -1 ));

        r(3) = m_mMeas(0) - m_mPred(0);
        r(4) = m_mMeas(1) - m_mPred(1);
        r(5) = m_mMeas(2) - m_mPred(2);
    }
    
    //  scale accelerometer covariance as acceleration deviates from one G
    auto measCov = m_R;
    float sigma = 1.0f + 50 * std::tanh( std::abs(mag_a - 1.0f) / 5.0f );
    for (int i=0; i < 3; i++) {
        for (int j=0; j < 3; j++) {
            measCov(i,j) *= sigma;
        }
    }

    auto Ht = H.transposed();
    auto S = H * m_P * Ht + measCov;

    //  calculate kalman gain and error
    auto K = m_P * Ht * invert(S, m_isStable);
    m_dx = K * r;
    
    //  covariance update
    m_P = (matrix<3,3> :: identity() - K * H) * m_P;

    //  state update
    m_q = m_q * quat(1.0f, m_dx(0), m_dx(1), m_dx(2));
    m_q = m_q * (1.0f / m_q.norm());

    //  reset
    m_dx(0) = m_dx(1) = m_dx(2) = 0.0f;
}
