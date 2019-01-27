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
clear;


mu = 7;%bound on the output alphabet size
N = 2^10;%number of bit channel in the polar codind

%Random diecrete cahnnel
%W = randomBMSChannel(N);

%Create Gaussian distribution
m = 1;%Expectancy
s = 1;%Variance
y = linspace(-15, 15 , 1000000);%Argument axis
W = 1/sqrt(2*pi*s^2)*exp(-(y-m).^2/(2*s^2));%Gaussian Distribution

%Gaussian Channel Capacity
I = 0.5 * log2(1 + m/s);

%BSC Channel
p = 0.001;
W = [1-p, p; p 1-p];

%find the degraded bit channels for the above distribution
Q = degradedPolarChannel(y, W, mu, N);

IDegraded = zeros(1,N);
ZDegraded = zeros(1,N);
for ind = 1:N
    [IDegraded(ind), ZDegraded(ind)] = BMS_IandZ(Q{ind});
end

% figure;plot(IDegraded,'.');
figure;plot(ZDegraded,'.');