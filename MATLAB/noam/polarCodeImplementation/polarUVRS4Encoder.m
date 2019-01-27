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

function encodedCodeword = polarUVRS4Encoder(streamOfBitsIncludingFrozen)
% TAU - Litsyn Team (Tera Santa)
% This function gets as input a string of bits of length 4^(i) where i > 0 is
% an integer. This string represents the input data to the polar
% code encoder including: 1) frozen symbols 2) crc. The funciton return as
% output the corresponding poar codeword.
NUMOFOUTERCODES = 2;
oneMat = [1 0 ; 0 1];
alphaMat = [0 1 ; 1 1 ];
alpha2Mat = mod(alphaMat^2,2);
zeroMat = zeros(2,2);
% RS4 gen matrix in binary format
UVVGenMatrixBin = [oneMat zeroMat; oneMat alphaMat];  
% block length
N = length(streamOfBitsIncludingFrozen);

if( N == 4) % base case 
    encodedCodeword = mod(streamOfBitsIncludingFrozen*UVVGenMatrixBin,2) ; % GF2 arithmetic
else
        % need to first encode each one of the 4 outer codes and then encode
    % them using the inner code(RS4GenMatrixBin)
    Nouter = N/NUMOFOUTERCODES; % length of outer codes
    encodedCodeword = zeros(1,N);
    encodedOuterCode = zeros(NUMOFOUTERCODES,Nouter);

    % scan the outer-codes
    for idxOuterCode = 1:1:NUMOFOUTERCODES
        informationPartOfTheOuterCode = streamOfBitsIncludingFrozen(((idxOuterCode-1)*Nouter) +(1:1:Nouter));
        encodedOuterCode(idxOuterCode,:) = polarRS4Encoder(informationPartOfTheOuterCode);
    end
    
    % perform inner encoding
    for idxLengthOuterCode=1:1:(Nouter/2)
        informationPartForInnerCode = zeros(1,NUMOFOUTERCODES*2);
        for idxOuterCode = 1:1:NUMOFOUTERCODES
            informationPartForInnerCode((idxOuterCode-1)*2+(1:2)) = encodedOuterCode(idxOuterCode,(idxLengthOuterCode-1)*2+ (1:2));
        end
        encodedCodeword(((idxLengthOuterCode-1)*NUMOFOUTERCODES*2)+(1:1:(NUMOFOUTERCODES*2)))= mod(informationPartForInnerCode*UVVGenMatrixBin,2);
    end
    
    
end