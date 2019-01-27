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
% Polar Code Test Script - BICM
% % % % % % % % % % % % % % %
clc;
%clear;

M = 100;%amount of simulation iterations

N = 1024;%codeword length
EsNo = 5;%[dB]

EsNoLin = 10 ^ (EsNo / 10);
S2 = 1 / (2*EsNoLin);%Noise Variance

ErrorVec = zeros(1,N);

%figure;
pause(0.01);
for ind = 1:M
    clc;
    display(['Iteration ', num2str(ind)]);
    
    U = round(rand(1, N));%generate random input vector
    
    X = PolarEncodeC(U);%polar encoding
    
    X_Reshaped = 2*X - 1;
    
    S =  X_Reshaped;
    
    
    Y = S + sqrt(S2)*randn(size(S));%AWGN channel
    
    %LLR Decoding
    %L = log(exp(-(Y + 1).^2 / (2*S2)) ./ exp(-(Y - 1).^2 / (2*S2)));
    L = -2*Y/S2;
    
    UTag = PolarDecodeC(L,U);%polar decoding
    ErrorVec = (ErrorVec*(ind-1) + double(xor(UTag, U))) / ind;
    
    P = ErrorVec;
    plot(P,'.')
    xlabel('Channel Index');
    ylabel('Error Probabillity');
    axis tight;
    pause(0.01);
end

ZSort = sort(P);
%ZSort = sort(Z);
k = round(0.9*N) : N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
figure;plot(k/N, log10(Pe));axis tight; grid on;
xlabel('Rate');
ylabel('Log Of Sum Of Error Probabilities');
