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

function [ listOfDecidedCodewords, listOfDecidedInfoWords,sOut ] = findInformationWordBaseCase(inputLLMatrix,frozenIndVecIn,maxListSize,polarCodeConfig)
midListSize = size(inputLLMatrix,3);
listOfDecidedCodewords = zeros(midListSize,polarCodeConfig.kernelSizeInBits);
informationListDataStruct = zeros(maxListSize,polarCodeConfig.symbolSizeInBits,polarCodeConfig.kernelSizeInSymbols);
sVector = cell(1,polarCodeConfig.kernelSizeInSymbols);
sOut = (1:1:(midListSize))-1;
for idxU = 1:1:polarCodeConfig.kernelSizeInSymbols
    % choose the calc LL function
       specificCalcLLFunciton = @(inLLMat,cosetLeader) generaCalcLLFunction(polarCodeConfig.decodingfunction{idxU},inLLMat,cosetLeader,polarCodeConfig.alphabetPermutationTable,polarCodeConfig.binWeightVector);
       [midListSize, sVector{idxU}, decideInfoBits] = findUListBaseCase(inputLLMatrix,maxListSize,specificCalcLLFunciton,frozenIndVecIn(idxU),sOut,listOfDecidedCodewords,polarCodeConfig);
       [listOfDecidedCodewords , sOut] = updateCosetsOfInnerCodes(idxU,sOut,sVector{idxU},decideInfoBits,listOfDecidedCodewords,polarCodeConfig);
       informationListDataStruct(1:1:midListSize,:,idxU) = decideInfoBits;
end
 listOfDecidedInfoWords = updateInfoListVector(informationListDataStruct,sVector);