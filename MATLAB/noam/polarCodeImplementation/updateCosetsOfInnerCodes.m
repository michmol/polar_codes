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

function [estCodewordListOut , sOutOut] = updateCosetsOfInnerCodes(numOfCodesProcessedSoFar,sOutIn,sPreviousStep,previousDecisionVec,estCodewordListIn,polarCodeConfig)
% estCodewordListIn is a two dimensional matrix 
%   dim1 = listsize
%   dim2 = codeword size (in bits)
% estCodewordListIn(i,:) is the leader of the coset of the decoded
% codeword.
% numOfCodesProcessedSoFar indicates the step of decoding we're currently at. This is a zero
% based number between 0...(kernel size in symbols)

if(numOfCodesProcessedSoFar==0)
    estCodewordListOut  = estCodewordListIn;
    sOutOut = sOutIn;
    return;
end
    

estCodewordListOut = zeros(size(previousDecisionVec,1),size(estCodewordListIn,2));
sOutOut = sOutIn(sPreviousStep+1);

% re-encoding step
rowOfGeneratingMatrixTransposed =  polarCodeConfig.GeneratingMatrixBin((numOfCodesProcessedSoFar-1)*polarCodeConfig.symbolSizeInBits+(1:1:polarCodeConfig.symbolSizeInBits),:)';

for idxList = 1:1:size(previousDecisionVec,1)
    % current estCurretListIn
    currentEstCodeWord = estCodewordListIn(sPreviousStep(idxList)+1,:);
    currentDecisionVec = previousDecisionVec(idxList,:);
    currentDecisionVecReshaped = reshape(currentDecisionVec,2,[],1);
    addendnMat = rowOfGeneratingMatrixTransposed*currentDecisionVecReshaped;
    additionMatReshaped = reshape(addendnMat,1,[],1);
    estCodewordListOut(idxList,:) = mod(additionMatReshaped+currentEstCodeWord,2);
%     for idxLenSym = 1:1:(size(previousDecisionVec,2)/polarCodeConfig.symbolSizeInBits)
%         
%         
%         estCodewordListOut(idxList,(idxLenSym-1)*polarCodeConfig.kernelSizeInBits+(1:1:polarCodeConfig.kernelSizeInBits))=...
%            mod( estCodewordListIn(sPreviousStep(idxList)+1,size(polarCodeConfig.GeneratingMatrixBin,2)*(idxLenSym-1)+(1:1:size(polarCodeConfig.GeneratingMatrixBin,2)))+...
%             previousDecisionVec(idxList,(idxLenSym-1)*polarCodeConfig.symbolSizeInBits+(1:1:polarCodeConfig.symbolSizeInBits))*rowOfGeneratingMatrix,2);
%         estCodewordListOut(idxList,:) = mod(  + previousDecisionVec(idxList,:),2);   
%     end
end