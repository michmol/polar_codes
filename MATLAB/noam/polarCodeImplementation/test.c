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
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    double *input, *output;
    int i, j, n_rows, n_cols;
    double avg;

    if ((nrhs != 1) || (nlhs > 1)) {
        printf("Error! Expecting exactly 1 rhs and up to 1 lhs argument!\n");
        return;
    }
        
    input = mxGetPr(prhs[0]);
    n_rows = mxGetM(prhs[0]);
    n_cols = mxGetN(prhs[0]);

    if (nlhs == 1) {
        plhs[0] = mxCreateDoubleMatrix(n_rows, 1, mxREAL);
        output = mxGetPr(plhs[0]);
    }
        
    for(i=0; i<n_rows; i++) {
        avg = 0.;
        for(j=0; j<n_cols; j++)
            avg += input[(i*n_cols)+j];
        avg /= (double)n_cols;

        if (nlhs == 1)
            output[i] = avg;
    }
} 
/* end mexFunction **/
