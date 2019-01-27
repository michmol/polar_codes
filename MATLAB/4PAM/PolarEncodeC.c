//Copyright 2019 Michael Milkov
// 
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//documentation files (the "Software"), to deal in the Software without restriction, including without limitation
//the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
//and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//The above copyright notice and this permission notice shall be included in all copies or substantial portions
//of the Software.
// 
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
//THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include <stdio.h>
#include "mex.h"
#include "math.h"

void PolarEncode(double *X, double *U, size_t N)
{
    double* U1 = (double *)mxMalloc(N/2 * sizeof(double));
    double* U2 = (double *)mxMalloc(N/2 * sizeof(double));
    double* X1 = (double *)mxMalloc(N/2 * sizeof(double));
    double* X2 = (double *)mxMalloc(N/2 * sizeof(double));
    
    int i;
    
    if (N == 2)
    {
        X[0] = (double)((int)U[0] ^ (int)U[1]);
        X[1] = U[1];
    }
    else
    {
        for (i = 0; i < N/2; i++)
        {
            U1[i] = (double)((int)U[2*i] ^ (int)U[2*i + 1]);
            U2[i] = U[2*i + 1];
        }
        
        PolarEncode(X1, U1, N/2);
        PolarEncode(X2, U2, N/2);
        
        for (i = 0; i < N/2; i++)
        {
            X[i] = X1[i];
            X[i + N/2] = X2[i];
        }
    }
}

void mexFunction (int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    double *U, *X;
    size_t N;
    
    //Get Input Data
    U = mxGetPr(prhs[0]);
    N = mxGetN(prhs[0]);
    
    //assign output vector
    plhs[0] = mxCreateDoubleMatrix(1, (int)N, mxREAL);
    X = mxGetPr(plhs[0]);
    
    PolarEncode(X, U, N);
}

