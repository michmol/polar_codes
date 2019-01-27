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

% polar code config file
% GF4 elements matrices.
oneMat = [1 0 ; 0 1];
alphaMat = [0 1 ; 1 1 ];
alpha2Mat = mod(alphaMat^2,2);
zeroMat = zeros(2,2);
% RS4 gen matrix in binary format
RS4GenMatrixBin = [oneMat zeroMat zeroMat zeroMat; oneMat oneMat zeroMat zeroMat; alpha2Mat alphaMat oneMat zeroMat; oneMat oneMat oneMat alphaMat];  
UVVGF4GenMatrix = [oneMat zeroMat; oneMat alphaMat];


polarCodeConfig.nameOfCode = 'RS4';
polarCodeConfig.alphabetSize = 4;
polarCodeConfig.GeneratingMatrixBin = RS4GenMatrixBin;
polarCodeConfig.symbolSizeInBits = log2(polarCodeConfig.alphabetSize);
polarCodeConfig.kernelSizeInBits = length(polarCodeConfig.GeneratingMatrixBin);
polarCodeConfig.kernelSizeInSymbols = polarCodeConfig.kernelSizeInBits/polarCodeConfig.symbolSizeInBits;
polarCodeConfig.decodingfunction = {@(LLInput) trellisRS4DecodeU0(LLInput);@(LLInput) trellisRS4DecodeU1(LLInput);@(LLInput) trellisRS4DecodeU2(LLInput);@(LLInput) trellisRS4DecodeU3(LLInput)};
polarCodeConfig.outerCode = []; % indicating that the outer code is also polar code with the same kernel
polarCodeConfig.alphabetPermutationTable = bsxfun(@(x,y)bitxor(x,y),(0:1:(polarCodeConfig.alphabetSize-1))',(0:1:(polarCodeConfig.alphabetSize-1)))+1;
polarCodeConfig.dec2binMat = [ 0 0 ; 1 0 ; 0 1; 1 1];
polarCodeConfig.binWeightVector = 2.^(0:(polarCodeConfig.symbolSizeInBits-1));
polarCodeConfigRS4 = polarCodeConfig;


polarCodeConfig.nameOfCode = 'UVRS4';
polarCodeConfig.alphabetSize = 4;
polarCodeConfig.GeneratingMatrixBin = UVVGF4GenMatrix;
polarCodeConfig.symbolSizeInBits = log2(polarCodeConfig.alphabetSize);
polarCodeConfig.kernelSizeInBits = length(polarCodeConfig.GeneratingMatrixBin);
polarCodeConfig.kernelSizeInSymbols = polarCodeConfig.kernelSizeInBits/polarCodeConfig.symbolSizeInBits;
polarCodeConfig.decodingfunction = {@(LLInput) trellisUVVDecodeU0(LLInput);@(LLInput) trellisUVVDecodeU1(LLInput)};
polarCodeConfig.outerCode = polarCodeConfigRS4; % indicating that the outer code is homogenous RS4 kernel;
polarCodeConfig.alphabetPermutationTable = bsxfun(@(x,y)bitxor(x,y),(0:1:(polarCodeConfig.alphabetSize-1))',(0:1:(polarCodeConfig.alphabetSize-1)))+1;
polarCodeConfig.dec2binMat = [ 0 0 ; 1 0 ; 0 1; 1 1];
polarCodeConfig.binWeightVector = 2.^(0:(polarCodeConfig.symbolSizeInBits-1));
polarCodeConfigUVRS4 = polarCodeConfig;