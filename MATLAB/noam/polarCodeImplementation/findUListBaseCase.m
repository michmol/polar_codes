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

function [outListSize, currentS, decideInfoBits] = findUListBaseCase(inputLLMatrix,maxListSize,specificCalcLLFunciton,isFrozen,sOut,listOfDecidedCodewords,polarCodeConfig)
inListSize = size(listOfDecidedCodewords,1);
if isFrozen
    outListSize = inListSize;
    currentS = (1:1:inListSize)-1;
    decideInfoBits = zeros(inListSize,polarCodeConfig.symbolSizeInBits);
    
else
      outerCodeDecoderLLInputContainer = calcLogLikelihoodsOfList(sOut,specificCalcLLFunciton,inputLLMatrix,listOfDecidedCodewords,polarCodeConfig);
      % the dimensions of outerCodeDecoderLLInputContainer is numOfSymbols,
      % 1, listSize.
      % rearrange it to be 2D matrix in which the rows are the symbols and
      % the columns are the soruce list;
      permutedOuterDecoderLL = permute(outerCodeDecoderLLInputContainer,[1,3,2]);
      reshapeOuterDecodeLL = reshape(permutedOuterDecoderLL,[],1,1);
      % sort and pick the maxListSize
      [sortList , idxSorted] = sort(reshapeOuterDecodeLL,'descend');
      % pick at most maxListSize symbols
      newListSize = min(maxListSize,length(sortList));
      indicesOfBestValues = idxSorted(1:1:newListSize);
      decideInfoBits = zeros(newListSize,polarCodeConfig.symbolSizeInBits);
      currentS = zeros(newListSize,1);
      for idxL = 1:1:newListSize
        %decideInfoBits(idxL,:) = dec2binvec(   mod((indicesOfBestValues(idxL)-1),polarCodeConfig.alphabetSize),polarCodeConfig.symbolSizeInBits);
        decideInfoBits(idxL,:) = polarCodeConfig.dec2binMat(mod(indicesOfBestValues(idxL)-1,polarCodeConfig.alphabetSize)+1,:);
        currentS(idxL) = floor((indicesOfBestValues(idxL)-1)/polarCodeConfig.alphabetSize);
      end
      
      outListSize = newListSize;
        
end