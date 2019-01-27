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

% % % % % % % % % % % % % % % 
% Polar Code Test Script
% % % % % % % % % % % % % % % 
clc;
clear;

M = 100;%amount of simulation iterations

N = 128;%codeword length
p = 0.1; %probability of error in the BSC channel



ErrorVec = zeros(1,N);
for ind = 1:M
   clc;
   display(['Iteration ', num2str(ind)]);
   
   U = round(rand(1, N));%generate random input vector
   
   X = PolarEncode(U);%polar encoding
   
   Y = bsc(X, p);%pass X through a BSC channel
   
   Utag = PolarDecodeBSC(Y,U,p);%polar decoding
   
   ErrorVec = ErrorVec + double(xor(Utag, U)) / M;
end

P = ErrorVec;
P(P>0.5) = 1-P(P>0.5);

H = p .* log2(1./p) + (1-p).*log2(1./(1-p));
C = 1-H;
Rmax = sum(P<1e-2) / M;

figure;plot(P,'.')
xlabel('Channel Index');
ylabel('Error Probabillity');

