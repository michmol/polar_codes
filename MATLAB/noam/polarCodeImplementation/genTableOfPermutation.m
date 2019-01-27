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

function  [tableOfPermutation] = genTableOfPermutation(permutationIndices,alphabetPermTbl)
% This function gets as input table of sizeOfAlphabetInBits
% and generate as output tablOfPermutation which has sizeOfAlphabet
% rows and size(permutationIndices,2) columns, such that the each column is
% a result of bitwise xor between the binary representation of
% (0:1:(sizeOfAlphabet-1)) and permutationIndices(:,colIDX).
sizeOfAlphabetInBits = size(permutationIndices,1);
sizeOfAlphabet = 2^sizeOfAlphabetInBits;

binWeightVector = 2.^(0:(sizeOfAlphabetInBits-1));
permutationIndicesInteger = binWeightVector*permutationIndices;
%tableOfPermutation = bsxfun(@(x,y)bitxor(x,y),(0:1:(sizeOfAlphabet-1))',permutationIndicesInteger);
tableOfPermutation = alphabetPermTbl(:,permutationIndicesInteger+1);
% tableOfPermutation = zeros(sizeOfAlphabet,size(permutationIndices,2));
% for i = 1:1:sizeOfAlphabet
%    currentVectorOfElementInAlphabet =  dec2binvec(i-1,sizeOfAlphabetInBits);
%    for idxOfPermutations = 1:1:size(permutationIndices,2)
%         currentShiftBin = xor(permutationIndices(:,idxOfPermutations)',currentVectorOfElementInAlphabet);
%         tableOfPermutation(i,idxOfPermutations) = currentShiftBin*binWeightVector;
%    end
%    
% end