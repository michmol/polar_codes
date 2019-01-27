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
double Sign(double a)
{
    if (a > 0) return 1;
    if(a < 0) return -1;
    return 0;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double LogAdd(double a, double b)
{
    return max(a,b) + log(1+exp(-fabs(a-b)));
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void  BitReversalPermutation(int* PermutedIndices, int N)
{
    int i;
    int *PrevPermutation = (int *)mxMalloc(N/2 * sizeof(int));;
    
    if (N == 2)
    {
        PermutedIndices[0] = 0;
        PermutedIndices[1] = 1;
    }
    else
    {
       BitReversalPermutation(PrevPermutation, N/2);
       for (i = 0; i < N/2; i++)
       {
         PermutedIndices[i] = 2*PrevPermutation[i];
         PermutedIndices[i + N/2] = 2*PrevPermutation[i] + 1;
       }
    }
    return;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double DecodedBitChannel(int i, double* L, double* U, size_t N)
{
    double* LMinus = (double *)mxMalloc(N/2 * sizeof(double));
    double* LPlus = (double *)mxMalloc(N/2 * sizeof(double));
    double* X = (double *)mxMalloc(N * sizeof(double));
    double* XPermuted = (double *)mxMalloc(N * sizeof(double));
    int* PermutedIndices = (int *)mxMalloc(N * sizeof(int));
    int j;
    
    if (N > 2)
        PolarEncode(X, &U[0], N/2);
    else
    {
        X[0] = U[0];
    }
    
    for (j = 0; j < N/2; j++)
    {
                
        LMinus[j] = LogAdd(L[2*j] + L[2*j + 1], 0) - LogAdd(L[2*j], L[2*j + 1]);
        
        if (X[j] == 0)
            LPlus[j] = L[2*j + 1] + L[2*j];
        else
            LPlus[j] = L[2*j + 1] - L[2*j];
    }
       
    if (N == 2)
    {
        if (i == 0)
            return floor((1 - Sign(LMinus[0]))/2);
        else
            return floor((1 - Sign(LPlus[0]))/2);
    }
    else
    {
        if (i < N/2)
            return  DecodedBitChannel(i, LMinus, &U[0], N/2);
        else
            return  DecodedBitChannel(i - N/2, LPlus, &U[N/2], N/2);
    }
    
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void PolarDecode(double *UTag, double *L, double* U,  size_t N)
{
    int i;
    int* PermutedIndices = (int *)mxMalloc(N * sizeof(int));
    double* LPermuted = (double *)mxMalloc(N * sizeof(double));
      
    for (i = 0; i < N; i++)
        UTag[i] = DecodedBitChannel(i, L, U, N);
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