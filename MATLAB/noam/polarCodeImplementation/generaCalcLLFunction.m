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

function outLLMat = generaCalcLLFunction(llCalcFunc,inLLMat,cosetLeader,permTbl,binWeightVector)
% This function get as input llCalcFunc which a function that receives as
% input the inLLMat, which should be 2^size(cosetLeader,1) rows and size(cosetLeader,2) columns matrix. 
% The function performs permutation of the rows acoording to the
% cosetleader matrix and and outputs outLLMat which is LL matrix with
% size(inLLMat,1) rows and 1 column. 

inLLMatPermuted = zeros(size(inLLMat));

% calculate the mapped indices of the  ll permuted indices
%LLMatPermutedIndices = genTableOfPermutation(cosetLeader,permTbl);
permutationIndicesInteger = binWeightVector*cosetLeader+1;

for i = 1:1:size(inLLMatPermuted,2)
    inLLMatPermuted(:,i) = inLLMat(permTbl(:,permutationIndicesInteger(i)),i);
end

% calculate the output LL matrix
outLLMat = llCalcFunc(inLLMatPermuted);

end

