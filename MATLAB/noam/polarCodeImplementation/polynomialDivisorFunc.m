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

function [remainderPoly]=polynomialDivisorFunc(inputPoly,divisorPoly)
    % This function get as input a binary input polynomial (defined by its
    % coefficients :
    % inputPoly(1)+inputPoly(2)*x+...+inputPoly(i)x^(i-1)+..., a divisior
    % polynomial and computes the remainder of dividing inputPoly by the
    % divisior.
    
    % find the degree of the divisor polynomial
    degreeDivisor = max(find(divisorPoly));
    divisorPoly=divisorPoly(1:1:degreeDivisor);
    % prepare the remainder in division 
    if(length(inputPoly)<degreeDivisor) % if the degree of the input poly is smaller than that of the divisior then
        % the input polynomial is the remainder.
        remainderPoly=[inputPoly zeros(degreeDivisor-1-length(inputPoly),1)];
    end
    
    % otherwise compute the remainder in an LFSR manner
    remainderPoly = inputPoly((end-degreeDivisor+2):end);
    
    
    for nextInput = (length(inputPoly)-degreeDivisor+1):-1:1
        % perform shift to the right
        remainderPoly = mod([inputPoly(nextInput) remainderPoly(1:1:(end-1))]+remainderPoly(end)*divisorPoly(1:1:(end-1)),2);
    end