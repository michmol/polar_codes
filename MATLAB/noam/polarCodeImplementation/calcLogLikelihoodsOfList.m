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

function [outerCodeDecoderLLInputContainer] = calcLogLikelihoodsOfList(sOut,calcLLFunctions,inputLLMatrix,estCodewordListIn,polarCodeConfig)
% calcLLFunction is a function that gets as input coset, and input LL
% matrix of output the likelihood matrix corresponding to the current step
% of decoding.
currentListSize = size(estCodewordListIn,1);
sizeOfKernelInBits = size(polarCodeConfig.GeneratingMatrixBin,2);
sizeOfKernelInSymbols = sizeOfKernelInBits/polarCodeConfig.symbolSizeInBits;
outerCodeLengthInBits = size(estCodewordListIn,2)/sizeOfKernelInSymbols;
outerCodeLengthInSymbols = outerCodeLengthInBits/polarCodeConfig.symbolSizeInBits;
outerCodeDecoderLLInputContainer = zeros(polarCodeConfig.alphabetSize,outerCodeLengthInSymbols,currentListSize);

for idxList = 1:1:currentListSize
    reshapedEstimatedCodeword = reshape(estCodewordListIn(idxList,:),polarCodeConfig.symbolSizeInBits,[]);
    for idxInnerCode = 1:outerCodeLengthInSymbols
        outerCodeDecoderLLInputContainer(:,idxInnerCode,idxList) = calcLLFunctions(inputLLMatrix(:,(idxInnerCode-1)*sizeOfKernelInSymbols+(1:1:sizeOfKernelInSymbols),sOut(idxList)+1),...
            reshapedEstimatedCodeword(:,(idxInnerCode-1)*sizeOfKernelInSymbols+(1:1:sizeOfKernelInSymbols)))';    
    end
end
    
