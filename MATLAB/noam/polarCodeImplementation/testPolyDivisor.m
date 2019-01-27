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

%% check polynomial divisor

inputPoly = randi(2,1,12)-1;
divisorPoly = [1 1 0 1];

% demo of systematic cyclic code generation

[remainderPoly]=polynomialDivisorFunc([zeros(1,length(divisorPoly)-1) inputPoly],divisorPoly);

codeword = [remainderPoly inputPoly];

[remainderPoly2]=polynomialDivisorFunc(codeword,divisorPoly);

%% with the crc:
primPoly25 =zeros(1,26); %x^25 + x^8 + x^6 + x^2 + 1
primPoly25([26,9,7,3,1])=1;
crcPoly26 = mod([primPoly25 0] + [0 primPoly25],2);% (1+x)*primPoly25
inputPoly = randi(2,1,3850-26)-1;
[remainderPoly]=polynomialDivisorFunc([zeros(1,length(crcPoly26)-1) inputPoly],crcPoly26);

codeword = [remainderPoly inputPoly];

[syndrom]=polynomialDivisorFunc(codeword,crcPoly26);

