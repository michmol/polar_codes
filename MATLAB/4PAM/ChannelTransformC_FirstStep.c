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

#define OUTPUT_CH   plhs[0]
#define INDEX       prhs[0]
#define INPUT_CH1   prhs[1]
#define INPUT_CH2   prhs[2]


double log2(double In)
{
    return log(In) / log(2);
}

double LogAdd(double a, double b)
{
    return max(a,b) + log2(1+(double)pow(2,(-fabs(a-b))));
}

void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    double *W, *Q1, *Q2;
    int i, j, Index;
    int M, L;
    size_t N;
    int m,n, k;
    
    if ((nrhs > 3) || (nlhs > 1)) {
        printf("Error! Expecting exactly 3 rhs and up to 1 lhs argument!\n");
        return;
    }
    
    Q1 = mxGetPr(INPUT_CH1);//Input Channel
    if (nrhs == 2)
        Q2 = Q1;
    else
        Q2 = mxGetPr(INPUT_CH2);//Input Channel
    
    Index = (int)mxGetScalar(INDEX);//transform desired index
    
    N = mxGetN(INPUT_CH1);//size of the input channel
    M = 2;//input alphabet size is 2
    
    switch (Index)
    {
        case 0:
            L = N;
            OUTPUT_CH = mxCreateNumericMatrix(0, 0, /*mxSINGLE_CLASS*/ mxDOUBLE_CLASS, mxREAL);//assign output channel
            mxSetM(OUTPUT_CH, M);
            mxSetN(OUTPUT_CH, L);
            mxSetData(OUTPUT_CH, mxMalloc(sizeof(double)*M*L));
            W = mxGetPr(OUTPUT_CH);//output channel pointer
            
            for (n = 0; n < N; n++)
            {
                W[M * n]      = -1 + LogAdd(Q1[M*n]       + Q2[M*n] , Q1[M*n + 1] + Q2[M*n + 1]);
                W[M * n + 1]  = -1 + LogAdd(Q1[M*n + 1]   + Q2[M*n] , Q1[M*n]     + Q2[M*n + 1]);
            }
            return;
        default:
            L = 2 * N;
            OUTPUT_CH = mxCreateNumericMatrix(0, 0, /*mxSINGLE_CLASS*/ mxDOUBLE_CLASS, mxREAL);//assign output channel
            mxSetM(OUTPUT_CH, M);
            mxSetN(OUTPUT_CH, L);
            mxSetData(OUTPUT_CH, mxMalloc(sizeof(double)*M*L));
            W = mxGetPr(OUTPUT_CH);//output channel pointer
            
                      
            for (n = 0; n < N; n++)
                for (k = 0; k < 2; k++)
                {
                    W[M*(n + k*N)]       = -1 + Q1[M*n + k]      + Q2[M*n];
                    W[M*(n + k*N) + 1]   = -1 + Q1[M*n + 1 - k]  + Q2[M*n + 1];
                }
            return;
    }
}
/* end mexFunction **/