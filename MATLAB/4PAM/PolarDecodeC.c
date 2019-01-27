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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double LogAdd(double a, double b)
{
    return max(a,b) + log(1+exp(-fabs(a-b)));
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double CalcL(int i, double* L, double* U, size_t N)
{
    double* U1 = (double *)mxMalloc(N/2 * sizeof(double));
    double* U2 = (double *)mxMalloc(N/2 * sizeof(double));
    double LUp, LDown;
    int i_New, j;
    
    if (N == 1)
    {
        return *L;
    }
    else
    {
        for (j = 0; j < N/2; j++)
        {
            U1[j] = (double)((int)U[2*j] ^ (int)U[2*j + 1]);
            U2[j] = U[2*j + 1];
        }
        
        i_New = i / 2;
        
        LUp = CalcL(i_New, &L[0], U1, N/2);
        LDown = CalcL(i_New, &L[N/2], U2, N/2);
        
        if (!(i % 2))
        {
            return LogAdd(LUp + LDown, 0) - LogAdd(LUp, LDown);
        }
        else
        {
            if (U[i - 1] == 0)
                return LDown + LUp;
            else
                return LDown - LUp;
        }
    }
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void PolarDecode(double *UTag, double *L, double* U,  size_t N)
{
   double LBit;
   int i;
   
   for (i = 0; i < N; i++)
   {
        LBit = CalcL(i, L, U, N);
        if (LBit < 0)
            UTag[i] = 1;
   }
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void mexFunction (int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    double *U, *L , *UTag;
    size_t N;
    
    //Get Input Data
    L = mxGetPr(prhs[0]);
    
    U = mxGetPr(prhs[1]);
    N = mxGetN(prhs[1]);
        
    
    //assign output vector
    plhs[0] = mxCreateDoubleMatrix(1, (int)N, mxREAL);
    UTag = mxGetPr(plhs[0]);
    
    PolarDecode(UTag, L, U, N);
}