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

W1 = [W/sum(W);fliplr(W)/sum(W)];


%BEC Channel
%~~~~~~~~~~~
% e = 0.2;
% W1 = [1- e e 0; 0 e 1-e];



%BSC Channel
% p = 0.001;
% W = [1-p, p; p 1-p];

[~, Z] = IandZ(W1);
Pe = 1 - sum(max(W1)) / sum(sum(W1));

%find the degraded bit channels for the above distribution
% ZLow = ZEstimationLow(Z, N);
ZHigh = ZEstimationHigh(Z, N);
ZLow = PEstimation(Pe,Z,N);

PHigh = ZHigh/2;
PLow =  ZLow;

load('C:\Users\Michael\Dropbox\Codes\MATLAB\4PAM\Results\Genie_1024_BPSK_EsNo_5_Matlab.mat')
r = (1:N)/N;

%TrellisCodeConstructionCompare(PHigh, PLow);

figure;semilogy(r, cumsum(sort(P)), r, cumsum(sort(PHigh)), '--', r, cumsum(sort(PLow)),'--');
% figure;plot(1:N, PHigh, '.', 1:N, PLow, '.');

%[ZLow, ZHigh] = ZEstimationNew(Z*ones(1,N), Z*ones(1,N));

% figure;plot(1:length(ZLow),[ZHigh; ZDegraded],'.');
% axis tight;
% xlabel('Bit-Channel Index');
% ylabel('Bhattacharyya Parameter');
% legend('Z High', 'Z Degraded');
% 
% ZLowSort = sort(PerrDegraded);
% ZHighSort = sort(ZHigh);
% ZDegradedSort = sort(ZDegraded);
% 
% k = round(0.65*N) : N;
% PLow = zeros(size(k));
% PHigh = zeros(size(k));
% PDegraded = zeros(size(k));
% for ind = 1:length(k)
%     PLow(ind) = sum(ZLowSort(1:k(ind)));
%     PHigh(ind) = sum(ZHighSort(1:k(ind)));
%     PDegraded(ind) = sum(ZDegradedSort(1:k(ind)));
% end
% 
% figure;plot(k/N, [log10(PHigh); log10(PDegraded)]);axis tight; grid on;
% xlabel('Rate');
% ylabel('Log Of Sum Of Error Probabilities');
% legend('Z High', 'Z Degraded');