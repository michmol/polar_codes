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

function  Utag = PolarDecode(Y,U,p)

%channel calculation
L = zeros(1, length(Y));
for ind = 1:length(Y)
    L(ind) = CalcL(ind, Y, U, p);
end


%decoding the output according to the likelihood
Utag = zeros(size(L));
Utag(L < 1) = 1;
end

%likelihood calculation

function L = CalcL(ind, Y, U, p)
%ind - index of the value to be calculated
%Y - received vector
%U - transmitted data for Genie-Aided decoding
%p - Probabillity of error in BSC channel

if length(Y) == 1
    L = LikelihoodBSC(Y, p);
    return;
end

U1 = xor(U(1:2:end), U(2:2:end));%modulo 2 addition
U2 = U(2:2:end);
indNew = ceil(ind/2);

LUp = CalcL(indNew, Y(1:length(Y)/2), U1, p);
LDown = CalcL(indNew, Y(length(Y)/2 + 1: length(Y)), U2, p);

if mod(ind,2)%if 'ind' is odd
    L = (LUp * LDown + 1) / (LUp + LDown);
else%if 'ind' is even
    if U(ind - 1) == 0%check the previous decoded bit - genie-aided style
        L = LDown * LUp;
    else
        L = LDown / LUp;
    end
end
end

function L = LikelihoodBSC(Y, p)
switch Y
    case 0
        L = (1 - p)/p;
    otherwise
        L = p/(1 - p);
end
end


