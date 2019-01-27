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

function listOfDecidedInfoWords = updateInfoListVector(informationWordDataStruct,sVector)
currentListSize = length(sVector{end}); 
numOfouterCodes = size(informationWordDataStruct,3);
codeLengthOfOuterCodeInBits = size(informationWordDataStruct,2);

listOfDecidedInfoWords = zeros(currentListSize,numOfouterCodes*codeLengthOfOuterCodeInBits);

for idxList = 1:1:currentListSize
    sPointerToOuterCode = idxList;
    for idxOuterCode = (numOfouterCodes):-1:1
        listOfDecidedInfoWords(idxList,(idxOuterCode-1)*codeLengthOfOuterCodeInBits+(1:1:codeLengthOfOuterCodeInBits)) = informationWordDataStruct(sPointerToOuterCode,:,idxOuterCode);
        sPointerToOuterCode = sVector{idxOuterCode}(sPointerToOuterCode)+1;
    end
end