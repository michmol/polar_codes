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
#define INPUT_CH    prhs[0]
#define INDEX       prhs[1]


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
float log2(float In)
{
    return log(In) / log(2);
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
float LogAdd(float a, float b)
{
    return max(a,b) + log2(1+pow(2,(-fabs(a-b))));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void   trellisRS4DecodeU0(float** LLInput,float** outLL)
{
// H = [1,1,1,a^2]
// cosetVector = [1,0,0,0]
// automatically generated by Matlab 20-May-2014
    
    
    float sL3_0 = 0;float sL4_0  = 0;
    float sL3_1 = 0;float sL4_3 = 0;
    float sL3_2 = 0;float sL4_1 = 0;
    float sL3_3 = 0;float sL4_2 = 0;
    
    float sL1_0 = LLInput[0][0] ; // (transition = 0) 0 ---0---> 0
    float sL1_1 = LLInput[0][1] ; // (transition = 0) 0 ---1---> 1
    float sL1_2 = LLInput[0][2] ; // (transition = 0) 0 ---a^1---> a^1
    float sL1_3 = LLInput[0][3] ; // (transition = 0) 0 ---a^2---> a^2
    
    
    
    // Transition = 1
    float sL2_0 =  sL1_0 + LLInput[1] [0] ; // (transition = 1) 0 ---0---> 0
    float sL2_1 =  sL1_0 + LLInput[1] [1] ; // (transition = 1) 0 ---1---> 1
    float sL2_2 =  sL1_0 + LLInput[1] [2] ; // (transition = 1) 0 ---a^1---> a^1
    float sL2_3 =  sL1_0 + LLInput[1] [3] ; // (transition = 1) 0 ---a^2---> a^2
    sL2_1 = LogAdd(sL2_1,  sL1_1 + LLInput[1] [0]) ; // (transition = 1) 1 ---0---> 1
    sL2_0 = LogAdd(sL2_0,  sL1_1 + LLInput[1] [1]) ; // (transition = 1) 1 ---1---> 0
    sL2_3 = LogAdd(sL2_3,  sL1_1 + LLInput[1] [2]) ; // (transition = 1) 1 ---a^1---> a^2
    sL2_2 = LogAdd(sL2_2,  sL1_1 + LLInput[1] [3]) ; // (transition = 1) 1 ---a^2---> a^1
    sL2_2 = LogAdd(sL2_2,  sL1_2 + LLInput[1] [0]) ; // (transition = 1) a^1 ---0---> a^1
    sL2_3 = LogAdd(sL2_3,  sL1_2 + LLInput[1] [1]) ; // (transition = 1) a^1 ---1---> a^2
    sL2_0 = LogAdd(sL2_0,  sL1_2 + LLInput[1] [2]) ; // (transition = 1) a^1 ---a^1---> 0
    sL2_1 = LogAdd(sL2_1,  sL1_2 + LLInput[1] [3]) ; // (transition = 1) a^1 ---a^2---> 1
    sL2_3 = LogAdd(sL2_3,  sL1_3 + LLInput[1] [0]) ; // (transition = 1) a^2 ---0---> a^2
    sL2_2 = LogAdd(sL2_2,  sL1_3 + LLInput[1] [1]) ; // (transition = 1) a^2 ---1---> a^1
    sL2_1 = LogAdd(sL2_1,  sL1_3 + LLInput[1] [2]) ; // (transition = 1) a^2 ---a^1---> 1
    sL2_0 = LogAdd(sL2_0,  sL1_3 + LLInput[1] [3]) ; // (transition = 1) a^2 ---a^2---> 0
    
    
    
    // Transition = 2
    sL3_0 =  sL2_0 + LLInput[2][0]  ; // (transition = 2) 0 ---0---> 0
    sL3_1 =  sL2_0 + LLInput[2][1]  ; // (transition = 2) 0 ---1---> 1
    sL3_2 =  sL2_0 + LLInput[2][2]  ; // (transition = 2) 0 ---a^1---> a^1
    sL3_3 =  sL2_0 + LLInput[2][3]  ; // (transition = 2) 0 ---a^2---> a^2
    sL3_1 = LogAdd(sL3_1,  sL2_1 + LLInput[2][0] ) ; // (transition = 2) 1 ---0---> 1
    sL3_0 = LogAdd(sL3_0,  sL2_1 + LLInput[2][1] ) ; // (transition = 2) 1 ---1---> 0
    sL3_3 = LogAdd(sL3_3,  sL2_1 + LLInput[2][2] ) ; // (transition = 2) 1 ---a^1---> a^2
    sL3_2 = LogAdd(sL3_2,  sL2_1 + LLInput[2][3] ) ; // (transition = 2) 1 ---a^2---> a^1
    sL3_2 = LogAdd(sL3_2,  sL2_2 + LLInput[2][0] ) ; // (transition = 2) a^1 ---0---> a^1
    sL3_3 = LogAdd(sL3_3,  sL2_2 + LLInput[2][1] ) ; // (transition = 2) a^1 ---1---> a^2
    sL3_0 = LogAdd(sL3_0,  sL2_2 + LLInput[2][2] ) ; // (transition = 2) a^1 ---a^1---> 0
    sL3_1 = LogAdd(sL3_1,  sL2_2 + LLInput[2][3] ) ; // (transition = 2) a^1 ---a^2---> 1
    sL3_3 = LogAdd(sL3_3,  sL2_3 + LLInput[2][0] ) ; // (transition = 2) a^2 ---0---> a^2
    sL3_2 = LogAdd(sL3_2,  sL2_3 + LLInput[2][1] ) ; // (transition = 2) a^2 ---1---> a^1
    sL3_1 = LogAdd(sL3_1,  sL2_3 + LLInput[2][2] ) ; // (transition = 2) a^2 ---a^1---> 1
    sL3_0 = LogAdd(sL3_0,  sL2_3 + LLInput[2][3] ) ; // (transition = 2) a^2 ---a^2---> 0
    
    
    
    // Transition = 3
    sL4_0 =  sL3_0 + LLInput[3] [0] ; // (transition = 3) 0 ---0---> 0
    sL4_3 =  sL3_0 + LLInput[3] [1] ; // (transition = 3) 0 ---1---> a^2
    sL4_1 =  sL3_0 + LLInput[3] [2] ; // (transition = 3) 0 ---a^1---> 1
    sL4_2 =  sL3_0 + LLInput[3] [3] ; // (transition = 3) 0 ---a^2---> a^1
    sL4_1 = LogAdd(sL4_1,  sL3_1 + LLInput[3][0] ) ; // (transition = 3) 1 ---0---> 1
    sL4_2 = LogAdd(sL4_2,  sL3_1 + LLInput[3][1] ) ; // (transition = 3) 1 ---1---> a^1
    sL4_0 = LogAdd(sL4_0,  sL3_1 + LLInput[3][2] ) ; // (transition = 3) 1 ---a^1---> 0
    sL4_3 = LogAdd(sL4_3,  sL3_1 + LLInput[3][3] ) ; // (transition = 3) 1 ---a^2---> a^2
    sL4_2 = LogAdd(sL4_2,  sL3_2 + LLInput[3][0] ) ; // (transition = 3) a^1 ---0---> a^1
    sL4_1 = LogAdd(sL4_1,  sL3_2 + LLInput[3][1] ) ; // (transition = 3) a^1 ---1---> 1
    sL4_3 = LogAdd(sL4_3,  sL3_2 + LLInput[3][2] ) ; // (transition = 3) a^1 ---a^1---> a^2
    sL4_0 = LogAdd(sL4_0,  sL3_2 + LLInput[3][3] ) ; // (transition = 3) a^1 ---a^2---> 0
    sL4_3 = LogAdd(sL4_3,  sL3_3 + LLInput[3][0] ) ; // (transition = 3) a^2 ---0---> a^2
    sL4_0 = LogAdd(sL4_0,  sL3_3 + LLInput[3][1] ) ; // (transition = 3) a^2 ---1---> 0
    sL4_2 = LogAdd(sL4_2,  sL3_3 + LLInput[3][2] ) ; // (transition = 3) a^2 ---a^1---> a^1
    sL4_1 = LogAdd(sL4_1,  sL3_3 + LLInput[3][3] ) ; // (transition = 3) a^2 ---a^2---> 1
    
    
// output:
    *outLL[0] = -6 + sL4_0 ; // symbol = 0
    *outLL[1] = -6 + sL4_1 ; // symbol = 1
    *outLL[2] = -6 + sL4_2 ; // symbol = a^1
    *outLL[3] = -6 + sL4_3 ; // symbol = a^2
    
// num of initializations = 16
// num of additions = 48
// num of LL additions = 36
    
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void   trellisRS4DecodeU1(float** LLInput,float** outLL)
{
// H = [[1,1,1,a^2];[a^1,a^2,0,a^2]]
// cosetVector = [1,1,0,0]
// automatically generated by Matlab 20-May-2014
    
    float sL4_0_0 =  0  ; //
    float sL4_0_1 = 0 ;
    float sL4_0_2 =  0  ; //
    float sL4_0_3 =  0  ; //
    
// Transition = 0
    float sL1_0_0 = LLInput[0][0] ; // (transition = 0) [0,0] ---0---> [0,0]
    float sL1_1_2 = LLInput[0][1] ; // (transition = 0) [0,0] ---1---> [1,a^1]
    float sL1_2_3 = LLInput[0][2] ; // (transition = 0) [0,0] ---a^1---> [a^1,a^2]
    float sL1_3_1 = LLInput[0][3] ; // (transition = 0) [0,0] ---a^2---> [a^2,1]
    
    
    
    // Transition = 1
    float sL2_0_0 =  sL1_0_0 + LLInput[1][0]  ; // (transition = 1) [0,0] ---0---> [0,0]
    float sL2_1_3 =  sL1_0_0 + LLInput[1][1]  ; // (transition = 1) [0,0] ---1---> [1,a^2]
    float sL2_2_1 =  sL1_0_0 + LLInput[1][2]  ; // (transition = 1) [0,0] ---a^1---> [a^1,1]
    float sL2_3_2 =  sL1_0_0 + LLInput[1][3]  ; // (transition = 1) [0,0] ---a^2---> [a^2,a^1]
    float sL2_1_2 =  sL1_1_2 + LLInput[1][0]  ; // (transition = 1) [1,a^1] ---0---> [1,a^1]
    float sL2_0_1 =  sL1_1_2 + LLInput[1][1]  ; // (transition = 1) [1,a^1] ---1---> [0,1]
    float sL2_3_3 =  sL1_1_2 + LLInput[1][2]  ; // (transition = 1) [1,a^1] ---a^1---> [a^2,a^2]
    float sL2_2_0 =  sL1_1_2 + LLInput[1][3]  ; // (transition = 1) [1,a^1] ---a^2---> [a^1,0]
    float sL2_2_3 =  sL1_2_3 + LLInput[1][0]  ; // (transition = 1) [a^1,a^2] ---0---> [a^1,a^2]
    float sL2_3_0 =  sL1_2_3 + LLInput[1][1]  ; // (transition = 1) [a^1,a^2] ---1---> [a^2,0]
    float sL2_0_2 =  sL1_2_3 + LLInput[1][2]  ; // (transition = 1) [a^1,a^2] ---a^1---> [0,a^1]
    float sL2_1_1 =  sL1_2_3 + LLInput[1][3]  ; // (transition = 1) [a^1,a^2] ---a^2---> [1,1]
    float sL2_3_1 =  sL1_3_1 + LLInput[1][0]  ; // (transition = 1) [a^2,1] ---0---> [a^2,1]
    float sL2_2_2 =  sL1_3_1 + LLInput[1][1]  ; // (transition = 1) [a^2,1] ---1---> [a^1,a^1]
    float sL2_1_0 =  sL1_3_1 + LLInput[1][2]  ; // (transition = 1) [a^2,1] ---a^1---> [1,0]
    float sL2_0_3 =  sL1_3_1 + LLInput[1][3]  ; // (transition = 1) [a^2,1] ---a^2---> [0,a^2]
    
    
    
    // Transition = 2
    float sL3_0_0 =  sL2_0_0 + LLInput[2][0]  ; // (transition = 2) [0,0] ---0---> [0,0]
    float sL3_1_0 =  sL2_0_0 + LLInput[2][1]  ; // (transition = 2) [0,0] ---1---> [1,0]
    float sL3_2_0 =  sL2_0_0 + LLInput[2][2]  ; // (transition = 2) [0,0] ---a^1---> [a^1,0]
    float sL3_3_0 =  sL2_0_0 + LLInput[2][3]  ; // (transition = 2) [0,0] ---a^2---> [a^2,0]
    float sL3_1_3 =  sL2_1_3 + LLInput[2][0]  ; // (transition = 2) [1,a^2] ---0---> [1,a^2]
    float sL3_0_3 =  sL2_1_3 + LLInput[2][1]  ; // (transition = 2) [1,a^2] ---1---> [0,a^2]
    float sL3_3_3 =  sL2_1_3 + LLInput[2][2]  ; // (transition = 2) [1,a^2] ---a^1---> [a^2,a^2]
    float sL3_2_3 =  sL2_1_3 + LLInput[2][3]  ; // (transition = 2) [1,a^2] ---a^2---> [a^1,a^2]
    float sL3_2_1 =  sL2_2_1 + LLInput[2][0]  ; // (transition = 2) [a^1,1] ---0---> [a^1,1]
    float sL3_3_1 =  sL2_2_1 + LLInput[2][1]  ; // (transition = 2) [a^1,1] ---1---> [a^2,1]
    float sL3_0_1 =  sL2_2_1 + LLInput[2][2]  ; // (transition = 2) [a^1,1] ---a^1---> [0,1]
    float sL3_1_1 =  sL2_2_1 + LLInput[2][3]  ; // (transition = 2) [a^1,1] ---a^2---> [1,1]
    float sL3_3_2 =  sL2_3_2 + LLInput[2][0]  ; // (transition = 2) [a^2,a^1] ---0---> [a^2,a^1]
    float sL3_2_2 =  sL2_3_2 + LLInput[2][1]  ; // (transition = 2) [a^2,a^1] ---1---> [a^1,a^1]
    float sL3_1_2 =  sL2_3_2 + LLInput[2][2]  ; // (transition = 2) [a^2,a^1] ---a^1---> [1,a^1]
    float sL3_0_2 =  sL2_3_2 + LLInput[2][3]  ; // (transition = 2) [a^2,a^1] ---a^2---> [0,a^1]
    sL3_1_2 = LogAdd(sL3_1_2,  sL2_1_2 + LLInput[2] [0]) ; // (transition = 2) [1,a^1] ---0---> [1,a^1]
    sL3_0_2 = LogAdd(sL3_0_2,  sL2_1_2 + LLInput[2] [1]) ; // (transition = 2) [1,a^1] ---1---> [0,a^1]
    sL3_3_2 = LogAdd(sL3_3_2,  sL2_1_2 + LLInput[2] [2]) ; // (transition = 2) [1,a^1] ---a^1---> [a^2,a^1]
    sL3_2_2 = LogAdd(sL3_2_2,  sL2_1_2 + LLInput[2] [3]) ; // (transition = 2) [1,a^1] ---a^2---> [a^1,a^1]
    sL3_0_1 = LogAdd(sL3_0_1,  sL2_0_1 + LLInput[2] [0]) ; // (transition = 2) [0,1] ---0---> [0,1]
    sL3_1_1 = LogAdd(sL3_1_1,  sL2_0_1 + LLInput[2] [1]) ; // (transition = 2) [0,1] ---1---> [1,1]
    sL3_2_1 = LogAdd(sL3_2_1,  sL2_0_1 + LLInput[2] [2]) ; // (transition = 2) [0,1] ---a^1---> [a^1,1]
    sL3_3_1 = LogAdd(sL3_3_1,  sL2_0_1 + LLInput[2] [3]) ; // (transition = 2) [0,1] ---a^2---> [a^2,1]
    sL3_3_3 = LogAdd(sL3_3_3,  sL2_3_3 + LLInput[2] [0]) ; // (transition = 2) [a^2,a^2] ---0---> [a^2,a^2]
    sL3_2_3 = LogAdd(sL3_2_3,  sL2_3_3 + LLInput[2] [1]) ; // (transition = 2) [a^2,a^2] ---1---> [a^1,a^2]
    sL3_1_3 = LogAdd(sL3_1_3,  sL2_3_3 + LLInput[2] [2]) ; // (transition = 2) [a^2,a^2] ---a^1---> [1,a^2]
    sL3_0_3 = LogAdd(sL3_0_3,  sL2_3_3 + LLInput[2] [3]) ; // (transition = 2) [a^2,a^2] ---a^2---> [0,a^2]
    sL3_2_0 = LogAdd(sL3_2_0,  sL2_2_0 + LLInput[2] [0]) ; // (transition = 2) [a^1,0] ---0---> [a^1,0]
    sL3_3_0 = LogAdd(sL3_3_0,  sL2_2_0 + LLInput[2] [1]) ; // (transition = 2) [a^1,0] ---1---> [a^2,0]
    sL3_0_0 = LogAdd(sL3_0_0,  sL2_2_0 + LLInput[2] [2]) ; // (transition = 2) [a^1,0] ---a^1---> [0,0]
    sL3_1_0 = LogAdd(sL3_1_0,  sL2_2_0 + LLInput[2] [3]) ; // (transition = 2) [a^1,0] ---a^2---> [1,0]
    sL3_2_3 = LogAdd(sL3_2_3,  sL2_2_3 + LLInput[2] [0]) ; // (transition = 2) [a^1,a^2] ---0---> [a^1,a^2]
    sL3_3_3 = LogAdd(sL3_3_3,  sL2_2_3 + LLInput[2] [1]) ; // (transition = 2) [a^1,a^2] ---1---> [a^2,a^2]
    sL3_0_3 = LogAdd(sL3_0_3,  sL2_2_3 + LLInput[2] [2]) ; // (transition = 2) [a^1,a^2] ---a^1---> [0,a^2]
    sL3_1_3 = LogAdd(sL3_1_3,  sL2_2_3 + LLInput[2] [3]) ; // (transition = 2) [a^1,a^2] ---a^2---> [1,a^2]
    sL3_3_0 = LogAdd(sL3_3_0,  sL2_3_0 + LLInput[2] [0]) ; // (transition = 2) [a^2,0] ---0---> [a^2,0]
    sL3_2_0 = LogAdd(sL3_2_0,  sL2_3_0 + LLInput[2] [1]) ; // (transition = 2) [a^2,0] ---1---> [a^1,0]
    sL3_1_0 = LogAdd(sL3_1_0,  sL2_3_0 + LLInput[2] [2]) ; // (transition = 2) [a^2,0] ---a^1---> [1,0]
    sL3_0_0 = LogAdd(sL3_0_0,  sL2_3_0 + LLInput[2] [3]) ; // (transition = 2) [a^2,0] ---a^2---> [0,0]
    sL3_0_2 = LogAdd(sL3_0_2,  sL2_0_2 + LLInput[2] [0]) ; // (transition = 2) [0,a^1] ---0---> [0,a^1]
    sL3_1_2 = LogAdd(sL3_1_2,  sL2_0_2 + LLInput[2] [1]) ; // (transition = 2) [0,a^1] ---1---> [1,a^1]
    sL3_2_2 = LogAdd(sL3_2_2,  sL2_0_2 + LLInput[2] [2]) ; // (transition = 2) [0,a^1] ---a^1---> [a^1,a^1]
    sL3_3_2 = LogAdd(sL3_3_2,  sL2_0_2 + LLInput[2] [3]) ; // (transition = 2) [0,a^1] ---a^2---> [a^2,a^1]
    sL3_1_1 = LogAdd(sL3_1_1,  sL2_1_1 + LLInput[2] [0]) ; // (transition = 2) [1,1] ---0---> [1,1]
    sL3_0_1 = LogAdd(sL3_0_1,  sL2_1_1 + LLInput[2] [1]) ; // (transition = 2) [1,1] ---1---> [0,1]
    sL3_3_1 = LogAdd(sL3_3_1,  sL2_1_1 + LLInput[2] [2]) ; // (transition = 2) [1,1] ---a^1---> [a^2,1]
    sL3_2_1 = LogAdd(sL3_2_1,  sL2_1_1 + LLInput[2] [3]) ; // (transition = 2) [1,1] ---a^2---> [a^1,1]
    sL3_3_1 = LogAdd(sL3_3_1,  sL2_3_1 + LLInput[2] [0]) ; // (transition = 2) [a^2,1] ---0---> [a^2,1]
    sL3_2_1 = LogAdd(sL3_2_1,  sL2_3_1 + LLInput[2] [1]) ; // (transition = 2) [a^2,1] ---1---> [a^1,1]
    sL3_1_1 = LogAdd(sL3_1_1,  sL2_3_1 + LLInput[2] [2]) ; // (transition = 2) [a^2,1] ---a^1---> [1,1]
    sL3_0_1 = LogAdd(sL3_0_1,  sL2_3_1 + LLInput[2] [3]) ; // (transition = 2) [a^2,1] ---a^2---> [0,1]
    sL3_2_2 = LogAdd(sL3_2_2,  sL2_2_2 + LLInput[2] [0]) ; // (transition = 2) [a^1,a^1] ---0---> [a^1,a^1]
    sL3_3_2 = LogAdd(sL3_3_2,  sL2_2_2 + LLInput[2] [1]) ; // (transition = 2) [a^1,a^1] ---1---> [a^2,a^1]
    sL3_0_2 = LogAdd(sL3_0_2,  sL2_2_2 + LLInput[2] [2]) ; // (transition = 2) [a^1,a^1] ---a^1---> [0,a^1]
    sL3_1_2 = LogAdd(sL3_1_2,  sL2_2_2 + LLInput[2] [3]) ; // (transition = 2) [a^1,a^1] ---a^2---> [1,a^1]
    sL3_1_0 = LogAdd(sL3_1_0,  sL2_1_0 + LLInput[2] [0]) ; // (transition = 2) [1,0] ---0---> [1,0]
    sL3_0_0 = LogAdd(sL3_0_0,  sL2_1_0 + LLInput[2] [1]) ; // (transition = 2) [1,0] ---1---> [0,0]
    sL3_3_0 = LogAdd(sL3_3_0,  sL2_1_0 + LLInput[2] [2]) ; // (transition = 2) [1,0] ---a^1---> [a^2,0]
    sL3_2_0 = LogAdd(sL3_2_0,  sL2_1_0 + LLInput[2] [3]) ; // (transition = 2) [1,0] ---a^2---> [a^1,0]
    sL3_0_3 = LogAdd(sL3_0_3,  sL2_0_3 + LLInput[2] [0]) ; // (transition = 2) [0,a^2] ---0---> [0,a^2]
    sL3_1_3 = LogAdd(sL3_1_3,  sL2_0_3 + LLInput[2] [1]) ; // (transition = 2) [0,a^2] ---1---> [1,a^2]
    sL3_2_3 = LogAdd(sL3_2_3,  sL2_0_3 + LLInput[2] [2]) ; // (transition = 2) [0,a^2] ---a^1---> [a^1,a^2]
    sL3_3_3 = LogAdd(sL3_3_3,  sL2_0_3 + LLInput[2] [3]) ; // (transition = 2) [0,a^2] ---a^2---> [a^2,a^2]
    
    
    
    // Transition = 3
    sL4_0_0 =  sL3_0_0 + LLInput[3][0]  ; // (transition = 3) [0,0] ---0---> [0,0]
    sL4_0_1 =  sL3_1_0 + LLInput[3][2]  ; // (transition = 3) [1,0] ---a^1---> [0,1]
    sL4_0_2 =  sL3_2_0 + LLInput[3][3]  ; // (transition = 3) [a^1,0] ---a^2---> [0,a^1]
    sL4_0_3 =  sL3_3_0 + LLInput[3][1]  ; // (transition = 3) [a^2,0] ---1---> [0,a^2]
    sL4_0_2 = LogAdd(sL4_0_2,  sL3_1_3 + LLInput[3][2] ) ; // (transition = 3) [1,a^2] ---a^1---> [0,a^1]
    sL4_0_3 = LogAdd(sL4_0_3,  sL3_0_3 + LLInput[3][0] ) ; // (transition = 3) [0,a^2] ---0---> [0,a^2]
    sL4_0_0 = LogAdd(sL4_0_0,  sL3_3_3 + LLInput[3][1] ) ; // (transition = 3) [a^2,a^2] ---1---> [0,0]
    sL4_0_1 = LogAdd(sL4_0_1,  sL3_2_3 + LLInput[3][3] ) ; // (transition = 3) [a^1,a^2] ---a^2---> [0,1]
    sL4_0_3 = LogAdd(sL4_0_3,  sL3_2_1 + LLInput[3][3] ) ; // (transition = 3) [a^1,1] ---a^2---> [0,a^2]
    sL4_0_2 = LogAdd(sL4_0_2,  sL3_3_1 + LLInput[3][1] ) ; // (transition = 3) [a^2,1] ---1---> [0,a^1]
    sL4_0_1 = LogAdd(sL4_0_1,  sL3_0_1 + LLInput[3][0] ) ; // (transition = 3) [0,1] ---0---> [0,1]
    sL4_0_0 = LogAdd(sL4_0_0,  sL3_1_1 + LLInput[3][2] ) ; // (transition = 3) [1,1] ---a^1---> [0,0]
    sL4_0_1 = LogAdd(sL4_0_1,  sL3_3_2 + LLInput[3][1] ) ; // (transition = 3) [a^2,a^1] ---1---> [0,1]
    sL4_0_0 = LogAdd(sL4_0_0,  sL3_2_2 + LLInput[3][3] ) ; // (transition = 3) [a^1,a^1] ---a^2---> [0,0]
    sL4_0_3 = LogAdd(sL4_0_3,  sL3_1_2 + LLInput[3][2] ) ; // (transition = 3) [1,a^1] ---a^1---> [0,a^2]
    sL4_0_2 = LogAdd(sL4_0_2,  sL3_0_2 + LLInput[3][0] ) ; // (transition = 3) [0,a^1] ---0---> [0,a^1]
    
    
// output:
    *outLL[0] = -4 + sL4_0_0 ; // symbol = 0
    *outLL[1] = -4 + sL4_0_1 ; // symbol = 1
    *outLL[2] = -4 + sL4_0_2 ; // symbol = a^1
    *outLL[3] = -4 + sL4_0_3 ; // symbol = a^2
    
// num of initializations = 40
// num of additions = 96
// num of LL additions = 60
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void   trellisRS4DecodeU2(float** LLInput,float** outLL)
{
// H = [[1,1,0,0];[1,0,1,0];[a^1,0,0,1]]
// cosetVector = [a^2,a^1,1,0]
// automatically generated by Matlab 20-May-2014



// Transition = 0
float sL1_0_0_0 = LLInput[0][0] ; // (transition = 0) [0,0,0] ---0---> [0,0,0]
float sL1_1_1_2 = LLInput[0][1] ; // (transition = 0) [0,0,0] ---1---> [1,1,a^1]
float sL1_2_2_3 = LLInput[0][2] ; // (transition = 0) [0,0,0] ---a^1---> [a^1,a^1,a^2]
float sL1_3_3_1 = LLInput[0][3] ; // (transition = 0) [0,0,0] ---a^2---> [a^2,a^2,1]



 // Transition = 1
float sL2_0_0_0 =  sL1_0_0_0 + LLInput[1][0]  ; // (transition = 1) [0,0,0] ---0---> [0,0,0]
float sL2_1_0_0 =  sL1_0_0_0 + LLInput[1][1]  ; // (transition = 1) [0,0,0] ---1---> [1,0,0]
float sL2_2_0_0 =  sL1_0_0_0 + LLInput[1][2]  ; // (transition = 1) [0,0,0] ---a^1---> [a^1,0,0]
float sL2_3_0_0 =  sL1_0_0_0 + LLInput[1][3]  ; // (transition = 1) [0,0,0] ---a^2---> [a^2,0,0]
float sL2_1_1_2 =  sL1_1_1_2 + LLInput[1][0]  ; // (transition = 1) [1,1,a^1] ---0---> [1,1,a^1]
float sL2_0_1_2 =  sL1_1_1_2 + LLInput[1][1]  ; // (transition = 1) [1,1,a^1] ---1---> [0,1,a^1]
float sL2_3_1_2 =  sL1_1_1_2 + LLInput[1][2]  ; // (transition = 1) [1,1,a^1] ---a^1---> [a^2,1,a^1]
float sL2_2_1_2 =  sL1_1_1_2 + LLInput[1][3]  ; // (transition = 1) [1,1,a^1] ---a^2---> [a^1,1,a^1]
float sL2_2_2_3 =  sL1_2_2_3 + LLInput[1][0]  ; // (transition = 1) [a^1,a^1,a^2] ---0---> [a^1,a^1,a^2]
float sL2_3_2_3 =  sL1_2_2_3 + LLInput[1][1]  ; // (transition = 1) [a^1,a^1,a^2] ---1---> [a^2,a^1,a^2]
float sL2_0_2_3 =  sL1_2_2_3 + LLInput[1][2]  ; // (transition = 1) [a^1,a^1,a^2] ---a^1---> [0,a^1,a^2]
float sL2_1_2_3 =  sL1_2_2_3 + LLInput[1][3]  ; // (transition = 1) [a^1,a^1,a^2] ---a^2---> [1,a^1,a^2]
float sL2_3_3_1 =  sL1_3_3_1 + LLInput[1][0]  ; // (transition = 1) [a^2,a^2,1] ---0---> [a^2,a^2,1]
float sL2_2_3_1 =  sL1_3_3_1 + LLInput[1][1]  ; // (transition = 1) [a^2,a^2,1] ---1---> [a^1,a^2,1]
float sL2_1_3_1 =  sL1_3_3_1 + LLInput[1][2]  ; // (transition = 1) [a^2,a^2,1] ---a^1---> [1,a^2,1]
float sL2_0_3_1 =  sL1_3_3_1 + LLInput[1][3]  ; // (transition = 1) [a^2,a^2,1] ---a^2---> [0,a^2,1]



 // Transition = 2
float sL3_0_0_0 =  sL2_0_0_0 + LLInput[2] [0] ; // (transition = 2) [0,0,0] ---0---> [0,0,0]
float sL3_1_2_0 =  sL2_1_0_0 + LLInput[2] [2] ; // (transition = 2) [1,0,0] ---a^1---> [1,a^1,0]
float sL3_2_3_0 =  sL2_2_0_0 + LLInput[2] [3] ; // (transition = 2) [a^1,0,0] ---a^2---> [a^1,a^2,0]
float sL3_3_1_0 =  sL2_3_0_0 + LLInput[2] [1] ; // (transition = 2) [a^2,0,0] ---1---> [a^2,1,0]
float sL3_1_2_2 =  sL2_1_1_2 + LLInput[2] [3] ; // (transition = 2) [1,1,a^1] ---a^2---> [1,a^1,a^1]
float sL3_0_0_2 =  sL2_0_1_2 + LLInput[2] [1] ; // (transition = 2) [0,1,a^1] ---1---> [0,0,a^1]
float sL3_3_1_2 =  sL2_3_1_2 + LLInput[2] [0] ; // (transition = 2) [a^2,1,a^1] ---0---> [a^2,1,a^1]
float sL3_2_3_2 =  sL2_2_1_2 + LLInput[2] [2] ; // (transition = 2) [a^1,1,a^1] ---a^1---> [a^1,a^2,a^1]
float sL3_2_3_3 =  sL2_2_2_3 + LLInput[2] [1] ; // (transition = 2) [a^1,a^1,a^2] ---1---> [a^1,a^2,a^2]
float sL3_3_1_3 =  sL2_3_2_3 + LLInput[2] [3] ; // (transition = 2) [a^2,a^1,a^2] ---a^2---> [a^2,1,a^2]
float sL3_0_0_3 =  sL2_0_2_3 + LLInput[2] [2] ; // (transition = 2) [0,a^1,a^2] ---a^1---> [0,0,a^2]
float sL3_1_2_3 =  sL2_1_2_3 + LLInput[2] [0] ; // (transition = 2) [1,a^1,a^2] ---0---> [1,a^1,a^2]
float sL3_3_1_1 =  sL2_3_3_1 + LLInput[2] [2] ; // (transition = 2) [a^2,a^2,1] ---a^1---> [a^2,1,1]
float sL3_2_3_1 =  sL2_2_3_1 + LLInput[2] [0] ; // (transition = 2) [a^1,a^2,1] ---0---> [a^1,a^2,1]
float sL3_1_2_1 =  sL2_1_3_1 + LLInput[2] [1] ; // (transition = 2) [1,a^2,1] ---1---> [1,a^1,1]
float sL3_0_0_1 =  sL2_0_3_1 + LLInput[2] [3] ; // (transition = 2) [0,a^2,1] ---a^2---> [0,0,1]



 // Transition = 3
float sL4_0_0_0 =  sL3_0_0_0 + LLInput[3][0]  ; // (transition = 3) [0,0,0] ---0---> [0,0,0]
float sL4_1_2_1 =  sL3_1_2_0 + LLInput[3][1]  ; // (transition = 3) [1,a^1,0] ---1---> [1,a^1,1]
float sL4_2_3_2 =  sL3_2_3_0 + LLInput[3][2]  ; // (transition = 3) [a^1,a^2,0] ---a^1---> [a^1,a^2,a^1]
float sL4_3_1_3 =  sL3_3_1_0 + LLInput[3][3]  ; // (transition = 3) [a^2,1,0] ---a^2---> [a^2,1,a^2]
sL4_1_2_1 = LogAdd(sL4_1_2_1,  sL3_1_2_2 + LLInput[3][3] ) ; // (transition = 3) [1,a^1,a^1] ---a^2---> [1,a^1,1]
sL4_0_0_0 = LogAdd(sL4_0_0_0,  sL3_0_0_2 + LLInput[3][2] ) ; // (transition = 3) [0,0,a^1] ---a^1---> [0,0,0]
sL4_3_1_3 = LogAdd(sL4_3_1_3,  sL3_3_1_2 + LLInput[3][1] ) ; // (transition = 3) [a^2,1,a^1] ---1---> [a^2,1,a^2]
sL4_2_3_2 = LogAdd(sL4_2_3_2,  sL3_2_3_2 + LLInput[3][0] ) ; // (transition = 3) [a^1,a^2,a^1] ---0---> [a^1,a^2,a^1]
sL4_2_3_2 = LogAdd(sL4_2_3_2,  sL3_2_3_3 + LLInput[3][1] ) ; // (transition = 3) [a^1,a^2,a^2] ---1---> [a^1,a^2,a^1]
sL4_3_1_3 = LogAdd(sL4_3_1_3,  sL3_3_1_3 + LLInput[3][0] ) ; // (transition = 3) [a^2,1,a^2] ---0---> [a^2,1,a^2]
sL4_0_0_0 = LogAdd(sL4_0_0_0,  sL3_0_0_3 + LLInput[3][3] ) ; // (transition = 3) [0,0,a^2] ---a^2---> [0,0,0]
sL4_1_2_1 = LogAdd(sL4_1_2_1,  sL3_1_2_3 + LLInput[3][2] ) ; // (transition = 3) [1,a^1,a^2] ---a^1---> [1,a^1,1]
sL4_3_1_3 = LogAdd(sL4_3_1_3,  sL3_3_1_1 + LLInput[3][2] ) ; // (transition = 3) [a^2,1,1] ---a^1---> [a^2,1,a^2]
sL4_2_3_2 = LogAdd(sL4_2_3_2,  sL3_2_3_1 + LLInput[3][3] ) ; // (transition = 3) [a^1,a^2,1] ---a^2---> [a^1,a^2,a^1]
sL4_1_2_1 = LogAdd(sL4_1_2_1,  sL3_1_2_1 + LLInput[3][0] ) ; // (transition = 3) [1,a^1,1] ---0---> [1,a^1,1]
sL4_0_0_0 = LogAdd(sL4_0_0_0,  sL3_0_0_1 + LLInput[3][1] ) ; // (transition = 3) [0,0,1] ---1---> [0,0,0]


// output: 
*outLL[0] = -2 + sL4_0_0_0 ; // symbol = 0 
*outLL[1] = -2 + sL4_1_2_1 ; // symbol = 1 
*outLL[2] = -2 + sL4_2_3_2 ; // symbol = a^1 
*outLL[3] = -2 + sL4_3_1_3 ; // symbol = a^2 

// num of initializations = 40
// num of additions = 48
// num of LL additions = 12
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
trellisRS4DecodeU3(float** LLInput,float** outLL)
{
// H = [[1,0,0,0];[0,1,0,0];[0,0,1,0];[0,0,0,1]]
// cosetVector = [1,1,1,a^1]
// automatically generated by Matlab 20-May-2014



// Transition = 0
float sL1_0_0_0_0 = LLInput[0][0] ; // (transition = 0) [0,0,0,0] ---0---> [0,0,0,0]
float sL1_1_0_0_0 = LLInput[0][1] ; // (transition = 0) [0,0,0,0] ---1---> [1,0,0,0]
float sL1_2_0_0_0 = LLInput[0][2] ; // (transition = 0) [0,0,0,0] ---a^1---> [a^1,0,0,0]
float sL1_3_0_0_0 = LLInput[0][3] ; // (transition = 0) [0,0,0,0] ---a^2---> [a^2,0,0,0]



 // Transition = 1
float sL2_0_0_0_0 =  sL1_0_0_0_0 + LLInput[1][0]  ; // (transition = 1) [0,0,0,0] ---0---> [0,0,0,0]
float sL2_1_1_0_0 =  sL1_1_0_0_0 + LLInput[1][1]  ; // (transition = 1) [1,0,0,0] ---1---> [1,1,0,0]
float sL2_2_2_0_0 =  sL1_2_0_0_0 + LLInput[1][2]  ; // (transition = 1) [a^1,0,0,0] ---a^1---> [a^1,a^1,0,0]
float sL2_3_3_0_0 =  sL1_3_0_0_0 + LLInput[1][3]  ; // (transition = 1) [a^2,0,0,0] ---a^2---> [a^2,a^2,0,0]



 // Transition = 2
float sL3_0_0_0_0 =  sL2_0_0_0_0 + LLInput[2][0]  ; // (transition = 2) [0,0,0,0] ---0---> [0,0,0,0]
float sL3_1_1_1_0 =  sL2_1_1_0_0 + LLInput[2][1]  ; // (transition = 2) [1,1,0,0] ---1---> [1,1,1,0]
float sL3_2_2_2_0 =  sL2_2_2_0_0 + LLInput[2][2]  ; // (transition = 2) [a^1,a^1,0,0] ---a^1---> [a^1,a^1,a^1,0]
float sL3_3_3_3_0 =  sL2_3_3_0_0 + LLInput[2][3]  ; // (transition = 2) [a^2,a^2,0,0] ---a^2---> [a^2,a^2,a^2,0]



 // Transition = 3
float sL4_0_0_0_0 =  sL3_0_0_0_0 + LLInput[3][0]  ; // (transition = 3) [0,0,0,0] ---0---> [0,0,0,0]
float sL4_1_1_1_2 =  sL3_1_1_1_0 + LLInput[3][2]  ; // (transition = 3) [1,1,1,0] ---a^1---> [1,1,1,a^1]
float sL4_2_2_2_3 =  sL3_2_2_2_0 + LLInput[3][3]  ; // (transition = 3) [a^1,a^1,a^1,0] ---a^2---> [a^1,a^1,a^1,a^2]
float sL4_3_3_3_1 =  sL3_3_3_3_0 + LLInput[3][1]  ; // (transition = 3) [a^2,a^2,a^2,0] ---1---> [a^2,a^2,a^2,1]


// output: 
*outLL[0] = sL4_0_0_0_0 ; // symbol = 0 
*outLL[1] = sL4_1_1_1_2 ; // symbol = 1 
*outLL[2] = sL4_2_2_2_3 ; // symbol = a^1 
*outLL[3] = sL4_3_3_3_1 ; // symbol = a^2 

// num of initializations = 16
// num of additions = 12
// num of LL additions = 0}
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void mexFunction(int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[])
{
    float *W, *Q;
    int i, j, Index;
    float a;
    size_t M, N, L;
    int k,l,u1,u2,u3,u4,p;
    int I1, I2, I3, I4;
    float *StructuredInput[4][4],*StructuredOutput[4];
    
    
    if ((nrhs != 2) || (nlhs > 1)) {
        printf("Error! Expecting exactly 2 rhs and up to 1 lhs argument!\n");
        return;
    }
    
    Q = mxGetPr(INPUT_CH);//Input Channel
    Index = (int)mxGetScalar(INDEX);//transform desired index
    
    N = mxGetN(INPUT_CH);//size of the input channel
    M = 4;//input alphabet size is 4
    
    
    L = (int)pow((float)N, 4);
    OUTPUT_CH = mxCreateNumericMatrix(0, 0, mxSINGLE_CLASS, mxREAL);//assign output channel
    mxSetM(OUTPUT_CH, M);
    mxSetN(OUTPUT_CH, L);
    mxSetData(OUTPUT_CH, mxMalloc(sizeof(float)*M*L));
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
                    StructuredInput[0][0] = &Q[    M*i];
                    StructuredInput[1][0] = &Q[1 + M*i];
                    StructuredInput[2][0] = &Q[2 + M*i];
                    StructuredInput[3][0] = &Q[3 + M*i];
                    
                    StructuredInput[0][1] = &Q[    M*j];
                    StructuredInput[1][1] = &Q[1 + M*j];
                    StructuredInput[2][1] = &Q[2 + M*j];
                    StructuredInput[3][1] = &Q[3 + M*j];
                    
                    StructuredInput[0][2] = &Q[    M*k];
                    StructuredInput[1][2] = &Q[1 + M*k];
                    StructuredInput[2][2] = &Q[2 + M*k];
                    StructuredInput[3][2] = &Q[3 + M*k];
                    
                    StructuredInput[0][3] = &Q[    M*l];
                    StructuredInput[1][3] = &Q[1 + M*l];
                    StructuredInput[2][3] = &Q[2 + M*l];
                    StructuredInput[3][3] = &Q[3 + M*l];
                    
                    StructuredOutput[0] = &W[    M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l)];
                    StructuredOutput[1] = &W[1 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l)];
                    StructuredOutput[2] = &W[2 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l)];
                    StructuredOutput[3] = &W[3 + M*(i + N*j + (int)pow(N,2)*k + (int)pow(N,3) * l)];
                    
                    switch (Index)
                    {
                        case 0:
                            trellisRS4DecodeU0(StructuredInput,StructuredOutput);
							continue;
                        case 1:
                            trellisRS4DecodeU1(StructuredInput,StructuredOutput);
							continue;
                        case 2:
                            trellisRS4DecodeU2(StructuredInput,StructuredOutput);
							continue;
                        default:
                            trellisRS4DecodeU3(StructuredInput,StructuredOutput);
                    }
                }
            }
        }
        
    }
}
/* end mexFunction **/