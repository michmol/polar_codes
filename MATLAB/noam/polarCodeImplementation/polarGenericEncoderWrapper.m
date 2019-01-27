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

function encodedCodeword = polarGenericEncoderWrapper(codeLengthIbBits,streamOfUserInformationBits,crcPolynomial,nonfrozenSymbols,polarCodeConfig)
% TAU - Litsyn Team (Tera Santa)
% This function gets as input a string of bits of length k and crc, of
% size length(crcPolynomial)-1, such that its the coefficient of the ith
% element x^i is crcPolynomial(i), 0<=i<=size_of_crc.
% frozen indices is a vector of the indices (zero based) on the indices
% that should be frozen. We have 2*nonfrozenSymbols >=
% length(streamOfUserInformationBits) + length(crcPolynomial) - 1 +
% 


N = codeLengthIbBits;
crcSize = length(crcPolynomial)-1;
K = length(nonfrozenSymbols);
% calculate the CRC
[remainderPoly]=polynomialDivisorFunc([zeros(1,crcSize) streamOfUserInformationBits],crcPolynomial);

informationWordPlusCRC = [remainderPoly streamOfUserInformationBits];
if(mod(length(informationWordPlusCRC),2))
    % pad with zero so the stream will be of even length
    informationWordPlusCRC = [informationWordPlusCRC 0 ];
end

% set the non-frozen symbols with the informationWordPlusCRC
encoderInput = zeros(1,N);

for idx = 1:1:(length(informationWordPlusCRC)/polarCodeConfig.symbolSizeInBits)
    encoderInput( polarCodeConfig.symbolSizeInBits*nonfrozenSymbols(idx) + (1:1:polarCodeConfig.symbolSizeInBits))=informationWordPlusCRC((idx-1)*polarCodeConfig.symbolSizeInBits+(1:1:polarCodeConfig.symbolSizeInBits));
end


encodedCodeword = polarGenericEncoder(encoderInput,polarCodeConfig);

