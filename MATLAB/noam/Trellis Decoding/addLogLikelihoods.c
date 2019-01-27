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
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    double *input1, *output,*input2,*output2 ;
    int i, j, n_rows2, n_cols2,n_rows,n_cols;
    double avg;

    if ((nrhs != 2) || (nlhs > 1)) {
        printf("Error! Expecting exactly 2e rhs and up to 1 lhs argument!\n");
        return;
    }
        
    input1 = mxGetPr(prhs[0]);
    n_rows = mxGetM(prhs[0]);
    n_cols = mxGetN(prhs[0]);
    input2 = mxGetPr(prhs[1]);
    n_rows2 = mxGetM(prhs[1]);
    n_cols2 = mxGetN(prhs[1]);
    if ((n_rows!=n_rows2)||(n_cols!=n_cols2)) {
        printf("Both inputs must have the same dimensions\n");
        return;
    }

    if (nlhs == 1) {
        plhs[0] = mxCreateDoubleMatrix(n_rows, n_cols, mxREAL);
        output = mxGetPr(plhs[0]);    
         for(j=0; j<n_cols; j++)   
         {
            for(i=0; i<n_rows; i++)
            {
               // printf("%f %f : %f %f\n",input2[n_rows*j+i],input1[n_rows*j+i],max(input1[n_rows*j+i],input2[n_rows*j+i]),log(1+exp(-fabs(input1[n_rows*j+i]-input2[n_rows*j+i]))));
                output[n_rows*j+i] = max(input1[n_rows*j+i],input2[n_rows*j+i])+ log(1+exp(-fabs(input1[n_rows*j+i]-input2[n_rows*j+i])))  ;
            }
        }
    }

} 
/* end mexFunction **/
