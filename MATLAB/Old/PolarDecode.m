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
Wi = zeros(2, length(Y));
for ind = 1:length(Y)
    Wi(1, ind) = CalcW(ind, Y, U, p, 0);
    Wi(2, ind) = CalcW(ind, Y, U, p, 1);
end

L = Wi(2,:) ./ Wi(1, :); %likelihood calculation

%decoding the output according to the likelihood
Utag = zeros(size(L));
Utag(L > 1) = 1;

%likelihood calculation

function Wi = CalcW(ind, Y, U, p, uIn)
%ind - index of the value to be calculated
%Y - received vector
%U - transmitted data for Genie-Aided decoding
%p - Probabillity of error in BSC channel
%uIn - a value of input for which the probability W is calculated

%the base of the recursion
if length(Y) == 1;
    if Y == uIn
        Wi = 1 - p;
    else
        Wi = p;
    end
    return;
end

U1 = xor(U(1:2:end), U(2:2:end));%modulo 2 addition
U2 = U(2:2:end);
indNew = ceil(ind/2);

if mod(ind, 2) %if 'ind' is odd...
    Wi = 0.5 * (CalcW(indNew, Y(1:length(Y)/2), U1, p, xor(uIn, 0))...
              * CalcW(indNew, Y(length(Y)/2 + 1:length(Y)), U2, p, 0)...
              +...
                CalcW(indNew, Y(1:length(Y)/2), U1, p, xor(uIn, 1))...
              * CalcW(indNew, Y(length(Y)/2 + 1:length(Y)), U2, p, 1));
else % if 'ind' is even...
    Wi = 0.5 * (CalcW(indNew, Y(1:length(Y)/2), U1, p, xor(uIn, U(ind - 1)))...
              * CalcW(indNew, Y(length(Y)/2 + 1:length(Y)), U2, p, uIn));
end