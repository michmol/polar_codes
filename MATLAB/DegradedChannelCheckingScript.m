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
addpath('Aux Functions');
addpath('4PAM');


mu = 256;%bound on the output alphabet size
N = 2^10;%number of bit channel in the polar coding

%Random diecrete cahnnel
%W = randomBMSChannel(N);

%Create Gaussian distribution
%Create Gaussian distribution
EsNo = 5;%[dB]

m = 1;%Expectancy
EsNoLin = 10 ^ (EsNo / 10);
S2 = 1 / (2*EsNoLin);%Noise Variance
d = 1;
y = linspace(-5, 5 , 1000000);%Argument axis

W = 1/sqrt(2*pi*S2)*exp(-(y-m).^2/(2*S2));%Gaussian Distribution

%W = DegradedMergeContinuous(y,W, mu);%for continuous channel, quantize it to mu levels

W = [W;fliplr(W)]/sum(W);

W = DegradedMerge2(W, mu);

%Gaussian Channel Capacity
I = 0.5 * log2(1 + m/sqrt(S2));

%BSC Channel
% p = 0.001;
% W = [1-p, p; p 1-p];

%find the degraded bit channels for the above distribution
[Q, Z] = DegradedPolarChannel(W, mu, N);

IDegraded = zeros(1,N);
ZDegraded = zeros(1,N);
PerrDegraded = zeros(1,N);
for ind = 1:N
    %[IDegraded(ind), ZDegraded(ind)] = IandZ(Q{ind});
    %PerrDegraded(ind) = 0.5 * sum(min(Q{ind}(1,:), Q{ind}(2,:)));
end

ZSort = sort(PerrDegraded);
%ZSort = sort(Z);
k = 1 : N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
figure;plot(k/N, log10(Pe));axis tight; grid on;
xlabel('Rate');
ylabel('Log Of Sum Of Error Probabilities');

% figure;plot(IDegraded,'.');
figure;plot(PerrDegraded,'.');
axis tight; 
xlabel('Channel Index');