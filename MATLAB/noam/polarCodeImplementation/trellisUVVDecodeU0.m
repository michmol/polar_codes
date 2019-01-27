%Copyright 2019 Michael Milkov
% 
%Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%documentation files (the "Software"), to deal in the Software without restriction, including without limitation
%the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
%and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
% 
%The above copyright notice and this permission notice shall be included in all copies or substantial portions
%of the Software.
% 
%THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
%THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
%THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
%TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 function outLL = trellisUVVDecodeU0(LLInput)
% H = [a^1,1]
% cosetVector = [1,0]



% Transition = 0
sL1_0 = LLInput(1,1) ; % (transition = 0) 0 ---0---> 0
sL1_2 = LLInput(2,1) ; % (transition = 0) 0 ---1---> a^1
sL1_3 = LLInput(3,1) ; % (transition = 0) 0 ---a^1---> a^2
sL1_1 = LLInput(4,1) ; % (transition = 0) 0 ---a^2---> 1



 % Transition = 1
sL2_0 = sL1_0 + LLInput(1,2) ; % (transition = 1) 0 ---0---> 0
sL2_1 = sL1_0 + LLInput(2,2) ; % (transition = 1) 0 ---1---> 1
sL2_2 = sL1_0 + LLInput(3,2) ; % (transition = 1) 0 ---a^1---> a^1
sL2_3 = sL1_0 + LLInput(4,2) ; % (transition = 1) 0 ---a^2---> a^2
sL2_2 = addLogLikelihoods(sL2_2,  sL1_2 + LLInput(1,2) ) ; % (transition = 1) a^1 ---0---> a^1
sL2_3 = addLogLikelihoods(sL2_3,  sL1_2 + LLInput(2,2) ) ; % (transition = 1) a^1 ---1---> a^2
sL2_0 = addLogLikelihoods(sL2_0,  sL1_2 + LLInput(3,2) ) ; % (transition = 1) a^1 ---a^1---> 0
sL2_1 = addLogLikelihoods(sL2_1,  sL1_2 + LLInput(4,2) ) ; % (transition = 1) a^1 ---a^2---> 1
sL2_3 = addLogLikelihoods(sL2_3,  sL1_3 + LLInput(1,2) ) ; % (transition = 1) a^2 ---0---> a^2
sL2_2 = addLogLikelihoods(sL2_2,  sL1_3 + LLInput(2,2) ) ; % (transition = 1) a^2 ---1---> a^1
sL2_1 = addLogLikelihoods(sL2_1,  sL1_3 + LLInput(3,2) ) ; % (transition = 1) a^2 ---a^1---> 1
sL2_0 = addLogLikelihoods(sL2_0,  sL1_3 + LLInput(4,2) ) ; % (transition = 1) a^2 ---a^2---> 0
sL2_1 = addLogLikelihoods(sL2_1,  sL1_1 + LLInput(1,2) ) ; % (transition = 1) 1 ---0---> 1
sL2_0 = addLogLikelihoods(sL2_0,  sL1_1 + LLInput(2,2) ) ; % (transition = 1) 1 ---1---> 0
sL2_3 = addLogLikelihoods(sL2_3,  sL1_1 + LLInput(3,2) ) ; % (transition = 1) 1 ---a^1---> a^2
sL2_2 = addLogLikelihoods(sL2_2,  sL1_1 + LLInput(4,2) ) ; % (transition = 1) 1 ---a^2---> a^1


% output: 
 outLL = [sL2_0,sL2_2,sL2_3,sL2_1];
