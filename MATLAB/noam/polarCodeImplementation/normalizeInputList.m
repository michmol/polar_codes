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

function [normalizedinputLLMatrix] =  normalizeInputList(inputLLMatrix)
% This function gets as input inputLLMatrix which is a 3-dimensional matrix
%           dim 1 = alphabet size
%           dim 2 = code length in symbols 
%           dim 3 = list size
% The function normalize the matrix for each column, such the maximum
% element of each column (dim2) among dim1 and dim3 is subtracted from each
% one them.
normalizedinputLLMatrix = zeros(size(inputLLMatrix));
% find the maximum element for each column
maximumElement = -inf*ones(1,size(inputLLMatrix,2));
for idxList = 1:1:size(inputLLMatrix,3)
    maximumElement = max(maximumElement,max(inputLLMatrix(:,:,idxList)));
end

%deduct the maximum element
for idxList = 1:1:size(inputLLMatrix,3)
    for idxRow = 1:1:size(inputLLMatrix,1)
        normalizedinputLLMatrix(idxRow,:,idxList) = inputLLMatrix(idxRow,:,idxList) - maximumElement;
    end
end
