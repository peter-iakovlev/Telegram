/*
 * matrix.hpp
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
 *	Created on: 10/12/2013
 *		Author: gareth
 */

#ifndef matrix_hpp
#define matrix_hpp

#include <cmath>

/**
 *  @brief Template class for matrix operations
 *  @param N number of rows
 *  @param M number of columns (default to 1, column vector)
 */
template <int N, int M = 1>
class matrix
{
    static_assert(N > 0 && M > 0, "Matrix dimensions must be positive");
    
public:
    
    /** Upper limit on zero */
    constexpr static float precision = 1.0e-6f;
    
    /** Number of elements */
    constexpr static int numel = N * M;
    
    /**
     *  @brief Ctor, zero-fill the matrix
     */
	matrix()
    {
        for (int i=0; i < numel; i++) {
            operator()(i) = 0.0f;
        }
    }
    
    /**
     *  @brief Copy ctor
     */
    matrix(const matrix& src)
    {
        for (int i=0; i < numel; i++) {
            operator()(i) = src(i);
        }
    }
    
    /**
     *  @brief R3 vector constructor
     */
    matrix(float x, float y, float z) 
    {
        static_assert(N==3 && M==1, "This constructor only applies to R3 vectors");
        
        operator()(0) = x;
        operator()(1) = y;
        operator()(2) = z;
    }
    
    /*
     *  Element-wise accessors (indexed from 0)
     */
    
    float& operator () (int i) { return m_entries[i]; }
	float& operator () (int i, int j) { return m_entries[i*M + j]; }
    
    const float& operator () (int i) const { return m_entries[i]; }
	const float& operator () (int i, int j) const { return m_entries[i*M + j]; }
    
    int n() const { return N; }
    int m() const { return M; }
    
    /**
     *  @brief Copy operator
     */
	matrix& operator = (const matrix& src)
    {
        for (int i=0; i < numel; i++) {
            operator()(i) = src(i);
        }
        
        return *this;
    }

    /**
     *  @brief Create an identity matrix
     *  @note Must be square
     */
	static matrix identity()
    {
        static_assert(N == M, "Identity matrix only defined for square matrices");
        
        matrix I;
        for (int i=0; i < N; i++) {
            I(i,i) = 1.0f;
        }

        return I;
    }
    
    /**
     *  @brief Create a skew-symmetric matrix from a 3-element vector
     *
     *  w   ->  [  0 -w2  w1]
     *          [ w2   0 -w3]
     *          [-w1  w3   0]
     */
    static matrix<3,3> cross_skew(const matrix <3,1>& w)
    {
        matrix<3,3> W;
    
        W(0,1) = -w(2);
        W(0,2) = w(1);
        
        W(1,0) = w(2);
        W(1,2) = -w(0);
        
        W(2,0) = -w(1);
        W(2,1) = w(0);
        
        return W;
    }
    
    /**
     *  @brief Transpose the receiver
     */
    matrix<M,N> transposed() const
    {
        matrix<M,N> T;
    
        for (int i=0; i < n(); i++) {
            for (int j=0; j < m(); j++) {
                T(j,i) = operator()(i,j);
            }
        }

        return T;
    }
    
    /**
     *  @brief Scale a row in the matrix
     *  @param i Index of row to scale
     *  @param s Scale factor
     */
    void row_scale(int i, float s)
    {
        for (int j=0; j < m(); j++) {
            operator()(i,j) *= s;
        }
    }

    /**
     *  @brief Perform a multiply-add between two rows
     *  @param a Index of row that is increased
     *  @param b Index of row to add
     *  @param s Scale factor
     *
     *  a = a + b*s
     */
    void row_madd(int a, int b, float s)
    {
        for (int j=0; j < m(); j++) {
            operator()(a,j) += operator()(b,j) * s;
        }
    }

    /**
     *  @brief Swap two rows
     *  @param a Index of first row
     *  @param b Index of second row
     */
    void row_swap(int a, int b)
    {
        float T;
        
        for (int j=0; j < m(); j++)
        {
            T = operator()(a,j);
            operator()(a,j) = operator()(b,j);
            operator()(b,j) = T;
        }
    }
    
    /**
     *  @brief Extract a set of columns
     *  @param m1 Index of starting column in the receiver
     *  @param m2 Index of ending column in the receiver
     */
    template <int m1, int m2>
    matrix<N, m2 - m1> slice() const
    {
        static_assert(m1 >= 0 && m1 < M, "First dimension is invalid");
        static_assert(m2 > m1 && m2 <= M, "Second dimension is invalid");
        
        matrix <N, m2 - m1> R;
        
        for (int i=0; i < N; i++) {
            for (int j=m1; j < m2; j++) {
                R(i, j - m1) = operator()(i,j);
            }
        }
        
        return R;
    }
    
    /**
     *  @brief Calculate the frobenius (L2) norm of this matrix
     */
    float norm() const
    {
        float n = 0.0f;
        for (int i=0; i < numel; i++) {
            n += operator()(i) * operator()(i);
        }

        return sqrtf(n);
    }
    
    /**
     *  @brief Normalize the elements of this matrix by dividing by the L2 norm
     *  @return The numerical value of the norm
     *  @note If the norm ~ 0, assume a 0 matrix and perform no division
     */
    float normalize_safe()
    {
        float n = norm();
        if (n > 1.0e-6f)
        {
            for (int i=0; i < numel; i++) {
                operator()(i) /= n;
            }
        }
        return n;
    }
    
    /**
     *  @brief Set a sub-matrix
     *  @param n Starting row in receiver
     *  @param m Ending row in receiver
     */
    template <int N2, int M2>
    void subs(int n, int m, const matrix<N2,M2>& A)
    {
        for (int i=n; i < n + A.n(); i++)
        {
            for (int j=m; j < m + A.m(); j++)
            {
                operator()(i, j) = A(i - n, j - m);
            }
        }
    }
    
    /**
     *  @brief X rotation matrix
     *  @param angle Angle in radians
     */
    static matrix<3,3> rotation_x(float angle)
    {
        const float c = std::cos(angle);
        const float s = std::sin(angle);
        
        matrix <3,3> R;
        
        R(0,0) = 1.0f;
        R(1,1) = c;
        R(1,2) = -s;
        R(2,1) = s;
        R(2,2) = c;
        
        return R;
    }
    
    /**
     *  @brief Y rotation matrix
     *  @param angle Angle in radians
     */
    static matrix<3,3> rotation_y(float angle)
    {
        const float c = std::cos(angle);
        const float s = std::sin(angle);
        
        matrix <3,3> R;
        
        R(1,1) = 1.0f;
        R(0,0) = c;
        R(2,0) = -s;
        R(0,2) = s;
        R(2,2) = c;
        
        return R;
    }
    
    /**
     *  @brief Z rotation matrix
     *  @param angle Angle in radians
     */
    static matrix<3,3> rotation_z(float angle)
    {
        const float c = std::cos(angle);
        const float s = std::sin(angle);
        
        matrix <3,3> R;
        
        R(2,2) = 1.0f;
        R(0,0) = c;
        R(0,1) = -s;
        R(1,0) = s;
        R(1,1) = c;
        
        return R;
    }
    
    /**
     *  @brief Extract angles corresponding to an YXZ transformation
     *  @param angles Resulting angles, in order: phi,theta,psi about Y,X,Z
     *
     *  @note In the case where cos(phi)==0, we set psi = 0 (gimbal lock).
     */
    void extractYXZ(float angles[3]) const
    {
        static_assert(N == 3 && M == 3, "Matrix must be a member of SO3 group");
        
        using std::cos;
        using std::atan2;
        
        const matrix <3,3>& R = *this;
        
        //  numerical rounding may cause this value to drift out of bounds
        float nsin_phi = R(1,2);
        if (nsin_phi < -1.0f) {
            nsin_phi = -1.0f;
        } else if (nsin_phi > 1.0f) {
            nsin_phi = 1.0f;
        }
        
        angles[0] = asinf( -nsin_phi );   //  phi
        if (cos(angles[0]) < 1.0e-5f)
        {
            angles[1] = atan2(R(0,1), R(0,0));  //  theta
            angles[2] = 0.0f;                   //  psi
        }
        else
        {
            angles[1] = atan2(R(0,2), R(2,2));  //  theta
            angles[2] = atan2(R(1,0), R(1,1));  //  psi
        }
    }
    
private:
	float m_entries[numel];
};

template <int N, int M>
matrix <N,M> operator + (const matrix<N,M>& A, const matrix<N,M>& B)
{
    matrix <N,M> C;
    
    for (int i=0; i < matrix<N,M> :: numel; i++) {
        C(i) = A(i) + B(i);
    }
    
    return C;
}

template <int N, int M>
matrix <N,M> operator - (const matrix<N,M>& A, const matrix<N,M>& B)
{
    matrix <N,M> C;
    
    for (int i=0; i < matrix<N,M> :: numel; i++) {
        C(i) = A(i) - B(i);
    }
    
    return C;
}


template <int N, int M, int D>
matrix <N,D> operator * (const matrix<N,M>& A, const matrix<M,D>& B)
{
    matrix <N,D> C;
        
    for (int i=0; i < A.n(); i++)
    {
        for (int j=0; j < B.m(); j++)
        {
            for (int k=0; k < B.n(); k++)
            {
                C(i,j) += A(i,k) * B(k,j);
            }
        }
    }
    
    return C;
}

template <int N, int M>
matrix <N,M> operator * (const matrix<N,M>& A, const float S)
{
    matrix <N,M> C;

    for (int i=0; i < matrix<N,M> :: numel; i++) {
        C(i) = A(i) * S;
    }

    return C;
}

template <int N, int M>
matrix <N,M> operator / (const matrix<N,M>& A, const float S)
{
    return operator*(A, 1.0f / S);
}

/**
 *  @brief Invert an NxN matrix.
 *  @param A matrix to invert
 *  @param success Set to true if the matrix can be inverted, false otherwise
 *
 *  @note This uses simple Gauss-Jordan reduction and is not vectorized at all.
 */
template <int N>
matrix <N,N> invert(const matrix<N,N>& A, bool& success)
{    
    matrix <N,2 * N> aug;
    
    for (int i=0; i < N; i++)
    {
        for (int j=0; j < N; j++)
        {
            float v = A(i,j);
            if (fabsf(v) < matrix<N,N> :: precision) {
                v = 0.0f;   //  clean floats
            }
            
            aug(i,j) = v;
            aug(i,N+j) = (i == j) * 1.0f;    //  right hand side is I3
        }
    }
    
    //  reduce
    for (int i=0; i < N; i++)   //  iterate over rows
    {
        //  look for a pivot
        float p = aug(i,i);
        if (p == 0.0f)
        {
            bool pFound = false;
            for (int k=i+1; k < N; k++)
            {
                p = aug(k,i);
                if (p != 0.0f)
                {
                    //  found a pivot
                    aug.row_swap(i,k);
                    pFound = true;
                    break;
                }
            }
            
            if (!pFound) {
                //  singular, give up
                success = false;
                return matrix<N,N>();
            }
        }
        
        //  normalize the pivot
        aug.row_scale(i,  1 / p);
        
        //  pivot is in right place, reduce all rows
        for (int k=0; k < N; k++)
        {
            if (k != i)
            {
                aug.row_madd(k, i, -aug(k,i));
            }
        }
    }
    
    success = true;
    return aug.template slice <N,N*2> ();
}

#endif
