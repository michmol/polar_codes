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

function  Utag = PolarDecode(L,U)

%channel calculation
LBit = zeros(1, length(L));
for ind = 1:length(L)
    LBit(ind) = CalcL(ind, L, U);
end


%decoding the output according to the likelihood
Utag = zeros(size(LBit));
%Utag(LBit < 1) = 1;
Utag(LBit < 0) = 1;
end

%likelihood calculation

function LBit = CalcL(ind, L, U)
%ind - index of the value to be calculated
%L - received LR vector
%U - transmitted data for Genie-Aided decoding
if length(L) == 1
    LBit = L;
    return;
end

U1 = xor(U(1:2:end), U(2:2:end));%modulo 2 addition
U2 = U(2:2:end);
indNew = ceil(ind/2);

LUp = CalcL(indNew, L(1:length(L)/2), U1);
LDown = CalcL(indNew, L(length(L)/2 + 1: end), U2);

if mod(ind,2)%if 'ind' is odd
    %LBit = (LUp * LDown + 1) / (LUp + LDown);
    LBit = LogAdd(LUp + LDown , 0) - LogAdd(LUp ,LDown);
else%if 'ind' is even
    if U(ind - 1) == 0%check the previous decoded bit - genie-aided style
        %LBit = LDown * LUp;
        LBit = LDown + LUp;
    else
        %LBit = LDown / LUp;
        LBit = LDown - LUp;
    end
end
end

function S = LogAdd(a,b)
    S = max(a,b) + log(1+ exp(-abs(a-b)));
end

