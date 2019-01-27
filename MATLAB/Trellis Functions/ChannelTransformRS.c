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
#include ".\Galois Field\Galois.h"

#define OUTPUT_CH   plhs[0]
#define INPUT_CH    prhs[0]
#define INDEX       prhs[1]

double log2(double In)
{
	return log(In) / log(2);
}

double LogAdd(double a, double b)
{
	return max(a,b) + log2(1+pow(2,(-fabs(a-b))));
}

void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    double *W, *Q;
    int i, j, Index;
    double a;
    size_t M, N, L;
    int k,l,u1,u2,u3,u4;
    int I1, I2, I3, I4;
    
    if ((nrhs != 2) || (nlhs > 1)) {
        printf("Error! Expecting exactly 2 rhs and up to 1 lhs argument!\n");
        return;
    }
    
    Q = mxGetPr(INPUT_CH);//Input Channel
    Index = (int)mxGetScalar(INDEX);//transform desired index
    
    N = mxGetN(INPUT_CH);//size of the input channel
    M = 4;//input alphabet size is 4
    
    switch (Index)
    {
        case 0:
            L = (int)pow((double)N, 4);
            OUTPUT_CH = mxCreateDoubleMatrix(0, 0,mxREAL);//assign output channel
            mxSetM(OUTPUT_CH, M);
            mxSetN(OUTPUT_CH, L);
            mxSetData(OUTPUT_CH, mxMalloc(sizeof(double)*M*L));
            W = mxGetPr(OUTPUT_CH);//output channel pointer
            
            
            //initialize output W
            for (i = 0; i < M; i++)
                for (j = 0; j < L; j++)
                    W[i + M*j] = -100;
            
            for (i = 0; i < N; i++)
            {
                for (j = 0; j < N; j++)
                {
                    for (k = 0; k < N; k++)
                    {
                        for (l = 0; l < N; l++)
                        {
                            for (u1 = 0; u1 < 4; u1++)
                            {
                                for (u2 = 0; u2 < 4; u2++)
                                {
                                    for (u3 = 0; u3 < 4; u3++)
                                    {
                                        for (u4 = 0; u4 < 4; u4++)
                                        {
                                            I1 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 2, 2) ^ galois_single_multiply(u3, 3, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I2 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 3, 2) ^ galois_single_multiply(u3, 2, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I3 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 1, 2) ^ galois_single_multiply(u3, 1, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I4 = galois_single_multiply(u4, 3, 2);
                                            
											W[u1 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l)] = LogAdd(W[u1 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l)],
																	-6 + Q[I1 + M*i] + Q[I2 + M*j] + Q[I3 + M*k] + Q[I4 + M*l]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
			return;
        case 1:
            L = 4 * (int)pow((double)N, 4);
            OUTPUT_CH = mxCreateDoubleMatrix(0, 0,mxREAL);//assign output channel
            mxSetM(OUTPUT_CH, M);
            mxSetN(OUTPUT_CH, L);
            mxSetData(OUTPUT_CH, mxMalloc(sizeof(double)*M*L));
            W = mxGetPr(OUTPUT_CH);//output channel pointer
            
            
            //initialize output W
            for (i = 0; i < M; i++)
                for (j = 0; j < L; j++)
                    W[i + M*j] = -100;
            
            for (i = 0; i < N; i++)
            {
                for (j = 0; j < N; j++)
                {
                    for (k = 0; k < N; k++)
                    {
                        for (l = 0; l < N; l++)
                        {
                            for (u1 = 0; u1 < 4; u1++)
                            {
                                for (u2 = 0; u2 < 4; u2++)
                                {
                                    for (u3 = 0; u3 < 4; u3++)
                                    {
                                        for (u4 = 0; u4 < 4; u4++)
                                        {
                                            I1 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 2, 2) ^ galois_single_multiply(u3, 3, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I2 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 3, 2) ^ galois_single_multiply(u3, 2, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I3 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 1, 2) ^ galois_single_multiply(u3, 1, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I4 = galois_single_multiply(u4, 3, 2);
                                            
                                            W[u2 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l + (int)pow(N,4) * u1)] = LogAdd(W[u2 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l + (int)pow(N,4) * u1)],
                                                                                                        -6 + Q[I1 + M*i] + Q[I2 + M*j] + Q[I3 + M*k] + Q[I4 + M*l]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
			return;
        case 2:
            L = 16 * (int)pow((double)N, 4);
            OUTPUT_CH = mxCreateDoubleMatrix(0, 0,mxREAL);//assign output channel
            mxSetM(OUTPUT_CH, M);
            mxSetN(OUTPUT_CH, L);
            mxSetData(OUTPUT_CH, mxMalloc(sizeof(double)*M*L));
            W = mxGetPr(OUTPUT_CH);//output channel pointer
            
            
            //initialize output W
            for (i = 0; i < M; i++)
                for (j = 0; j < L; j++)
                    W[i + M*j] = -100;
            
            for (i = 0; i < N; i++)
            {
                for (j = 0; j < N; j++)
                {
                    for (k = 0; k < N; k++)
                    {
                        for (l = 0; l < N; l++)
                        {
                            for (u1 = 0; u1 < 4; u1++)
                            {
                                for (u2 = 0; u2 < 4; u2++)
                                {
                                    for (u3 = 0; u3 < 4; u3++)
                                    {
                                        for (u4 = 0; u4 < 4; u4++)
                                        {
                                            I1 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 2, 2) ^ galois_single_multiply(u3, 3, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I2 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 3, 2) ^ galois_single_multiply(u3, 2, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I3 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 1, 2) ^ galois_single_multiply(u3, 1, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I4 = galois_single_multiply(u4, 3, 2);
                                            
                                            W[u3 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l + (int)pow(N,4) * u1 + 4*(int)pow(N,4) * u2)] = LogAdd(W[u3 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l + (int)pow(N,4) * u1 + 4*(int)pow(N,4) * u2)],
                                                                                                        -6 + Q[I1 + M*i] + Q[I2 + M*j] + Q[I3 + M*k] + Q[I4 + M*l]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
			return;
        default:
           L = 64 * (int)pow((double)N, 4);
            OUTPUT_CH = mxCreateDoubleMatrix(0, 0,mxREAL);//assign output channel
            mxSetM(OUTPUT_CH, M);
            mxSetN(OUTPUT_CH, L);
            mxSetData(OUTPUT_CH, mxMalloc(sizeof(double)*M*L));
            W = mxGetPr(OUTPUT_CH);//output channel pointer
            
            
            //initialize output W
            for (i = 0; i < M; i++)
                for (j = 0; j < L; j++)
                    W[i + M*j] = -100;
            
            for (i = 0; i < N; i++)
            {
                for (j = 0; j < N; j++)
                {
                    for (k = 0; k < N; k++)
                    {
                        for (l = 0; l < N; l++)
                        {
                            for (u1 = 0; u1 < 4; u1++)
                            {
                                for (u2 = 0; u2 < 4; u2++)
                                {
                                    for (u3 = 0; u3 < 4; u3++)
                                    {
                                        for (u4 = 0; u4 < 4; u4++)
                                        {
                                            I1 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 2, 2) ^ galois_single_multiply(u3, 3, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I2 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 3, 2) ^ galois_single_multiply(u3, 2, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I3 = galois_single_multiply(u1, 1, 2) ^ galois_single_multiply(u2, 1, 2) ^ galois_single_multiply(u3, 1, 2) ^ galois_single_multiply(u4, 1, 2);
                                            I4 = galois_single_multiply(u4, 3, 2);
                                            
                                           W[u4 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l + (int)pow(N,4) * u1 + 4*(int)pow(N,4) * u2 + 16*(int)pow(N,4) * u3)] = LogAdd(W[u4 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l + (int)pow(N,4) * u1 + 4*(int)pow(N,4) * u2 + 16*(int)pow(N,4) * u3)],
                                                                                                        -6 + Q[I1 + M*i] + Q[I2 + M*j] + Q[I3 + M*k] + Q[I4 + M*l]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
			return;
    }
}
/* end mexFunction **/