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

% % % % % % % % % % % % % % % % % % % % % % 
% Check the degrading merge script
% % % % % % % % % % % % % % % % % % % % % % 
clc;
%clear;
addpath('C:\Users\Michael\Dropbox\Codes\MATLAB\Aux Functions');
addpath('C:\Users\Michael\Dropbox\Codes\MATLAB');


mu = 256;%bound on the output alphabet size
N = 1024;%number of bit channel in the polar code

%Random diecrete cahnnel
%W = randomBMSChannel(N);

%Create Gaussian distribution
EsNo = 2;%[dB]

m = 1;%Expectancy
EsNoLin = 10 ^ (EsNo / 10);
S2 = 1 / (2*EsNoLin);%Noise Variance
d = 1;

Symbols4PAM = 1/sqrt(5)*[-3, -1, 1, 3];
SymbolsBPSK = [-1, 1];

y = linspace(-5, 5 , 1000000);%Argument axis

W = 1/sqrt(2*pi*S2)*...
    [exp(-(y - Symbols4PAM(1)).^2/(2*S2));...
     exp(-(y - Symbols4PAM(2)).^2/(2*S2));...
     exp(-(y - Symbols4PAM(3)).^2/(2*S2));...
     exp(-(y - Symbols4PAM(4)).^2/(2*S2))];%Gaussian Distribution over 4-PAM
 
W1 = 0.5* [sum(W([1,2],:)); sum(W([3,4],:))];
W2 = 0.5* [sum(W([1,4],:)); sum(W([2,3],:))];

% W1 = [exp(-(y - SymbolsBPSK(1)).^2/(2*S2));...
%      exp(-(y - SymbolsBPSK(2)).^2/(2*S2))];%BPSK Channel

W1 = W1 / sum(sum(W1,2))*2;
W2 = W2 / sum(sum(W2,2))*2;

Wtot = DegradedMerge4Double(W / sum(sum(W,2))*4, mu);

WTemp = DegradedMerge4Double([W1;W2], mu);
W1 = WTemp(1:2,:);
W2 = WTemp(3:4,:);

%find the degraded bit channels for the above distribution
[Q, Z] = BuildBinary4PAMChannel(W1, W2, Wtot, mu, N);

% W2 = DegradedMerge2Double(W2, mu);
% [Q, Z] = DegradedPolarChannel(W2, mu, N);

IDegraded = zeros(1,N);
ZDegraded = zeros(1,N);
PerrDegraded = zeros(1,N);
for ind = 1:N
    %[IDegraded(ind), ZDegraded(ind)] = IandZ(Q{ind});
    %PerrDegraded(ind) = 0.5 * sum(min(Q{ind}(1,:), Q{ind}(2,:)));
    PerrDegraded(ind) = sum(min(Q{ind})) / sum(sum(Q{ind}));
end

ZSort = sort(PerrDegraded);
%ZSort = sort(Z);
k = round(0.9*N) : N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
% figure;plot(k/N, log10(Pe));axis tight; grid on;
% xlabel('Rate');
% ylabel('Log Of Sum Of Error Probabilities');

figure;plot(1:N, [PerrDegraded],'.');
axis tight; 
xlabel('Channel Index');