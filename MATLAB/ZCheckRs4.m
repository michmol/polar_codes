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


N = 256;%number of bit channel in the polar coding

%Create Gaussian distribution
EsN0 = -3;
EsNoLin = 10 ^ (EsN0 / 10);
s = 1 / (2*EsNoLin);%Noise Variance
m = 1;
y = linspace(-2, 2 , 1000);%Argument axis

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
w = w ./ repmat(sum(w,2),1, size(w,2));


% BEC Channel
e = 0.3;
W = [1-e  0   0   0   e;...
     0    1-e 0   0   e;...
     0    0   1-e 0   e;...
     0    0   0   1-e e];

[~, Z] = IandZ(W([1,4],:));

%find the degraded bit channels for the above distribution
ZHigh = ZEstimationRS4(Z, N);

[ZSort, ZInd] = sort(ZHigh);

figure;plot((1:length(ZHigh))/ length(ZHigh), ZHigh,'.');
axis tight;
xlabel('Symbol-Channel Index');
ylabel('Bhattacharyya Parameter');
legend('Z High');

% ZLowSort = sort(PerrDegraded);
% ZHighSort = sort(ZHigh);
% ZDegradedSort = sort(ZDegraded);


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