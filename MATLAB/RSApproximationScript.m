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
% Check the degrading merge for RS(4) script
% % % % % % % % % % % % % % % % % % % % % %
clc;
clear;
addpath('Aux Functions');
addpath 'Trellis Functions'


mu = 5;%bound on the output alphabet size
N = 64;%number of bit channel in the polar coding
Type = 'Degrading';
%Type = 'Upgrading';

%Random diecrete cahnnel
%W = randomBMSChannel(N);

%Create Gaussian distribution
EsN0 = -3;
EsNoLin = 10 ^ (EsN0 / 10);
s = 1 / (2*EsNoLin);%Noise Variance
m = 1;
y = linspace(-2, 2 , 1000);%Argument axis

% WCont = 1/sqrt(2*pi*s^2)*exp(-(y-m).^2/(2*s^2));%Gaussian Distribution
%
% WDisc = DegradedMergeContinuous2(y,WCont, mu);%for continuous channel, quantize it to mu levels
%
% W2D = WDisc(1,:)' * WDisc(1,:);
%
% W1 = W2D(:);
% W2 = rot90(W2D, 1);W2 = W2(:);
% W3 = rot90(W2D, 2);W3 = W3(:);
% W4 = rot90(W2D, 3);W4 = W4(:);
%
% W = [W1, W2, W3, W4]';
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~```

x = y;

[xx, yy] = meshgrid(x,y);
W2D = 1/(2*pi*s^2) * exp(-(yy-m).^2/(2*s^2) - (xx-m).^2/(2*s^2));
W1 = W2D;
W2 = rot90(W2D, 1);
W3 = rot90(W2D, 2);
W4 = rot90(W2D, 3);

% W is a channel with the following symmetry : w(1:2,:) = rot90(w(3:4,:),2)
w = cat(3,W1,W2,W3,W4);
w = permute(w,[3,1,2]);
w = reshape(w,4,[]);
W = w ./ repmat(sum(w,2),1, size(w,2));

%seperate a really big channel into chunks
MaxChunkSize = 0.5e6;
NumOfChunks = ceil(size(w,2) / MaxChunkSize);
w1 = cell(1, NumOfChunks);

% for k = 1:NumOfChunks
%     w1{k} = DegradedMerge4(w(:, (k-1)*MaxChunkSize + 1: min(k*MaxChunkSize, size(w,2))), mu);%again, bound the size of the output alphabet which had grown
%     
%     %merge with previous chunk
%     if k > 1
%         w1{k} =  DegradedMerge4([w1{k-1}, w1{k}], mu);
%     end
% end
% W = w1{NumOfChunks};

%Gaussian Channel Capacity
I = 0.5 * log2(1 + m/s);

%BSC Channel
% p = 0.001;
% W = [1-p, p; p 1-p];

% BEC Channel
% e = 0.6872;
% W = [1-e  0   0   0   e;...
%      0    1-e 0   0   e;...
%      0    0   1-e 0   e;...
%      0    0   0   1-e e];
    
W_BEC = UpgradedBEC(W);

%find the degraded bit channels for the above distribution
%Q = NonBinarySymbolChannels(W, mu, N, Type);
%Q = NonBinarySymbolChannels_Half(W, mu, N);
Q = NonBinarySymbolChannels_Hybrid(W_BEC, mu, N);

%IDegraded = zeros(1,N);
%ZDegraded = zeros(1,N);
PerrDegraded = zeros(1,N);
for ind = 1:N
    PerrDegraded(ind) = sum(sum(Q{ind}) - max(Q{ind})) / sum(sum(Q{ind}));
end

% eval(['save RS4_N_',num2str(N),'_mu_',num2str(mu),'_EsNo_',num2str(EsN0),'_Degraded PerrDegraded']);

ZSort = sort(PerrDegraded);
% %ZSort = sort(Z);
% k = 1 : 64;
% Pe = zeros(size(k));
% for ind = 1:length(Pe)
%     Pe(ind) = sum(ZSort(1:k(ind)));
% end
% plot(k/64, log10(Pe),'g');
% axis tight; grid on;
% 
% eval(['save RS4_N_',num2str(N),'_mu_',num2str(mu),'_',Type,' PerrDegraded']);

figure;plot(PerrDegraded,'.');axis tight;
xlabel('Channel Index');
ylabel('Symbol Error Probability');

% ZSort = sort(PerrDegraded);
%ZSort = sort(Z);
k = 1:N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
plot(k/N, log10(Pe),'g');
axis tight; grid on;
xlabel('Rate');
ylabel('Log Of Sum Of Error Probabilities')
