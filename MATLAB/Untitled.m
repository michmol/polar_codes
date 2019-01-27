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

mu = 5;%bound on the output alphabet size
N = 64;%number of bit channel in the polar coding
Type = 'Degrading';

load RS4_N_64_Genie_EsN0-3
ZSort = sort(PGen);

k = 1:N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
plot(k/N, log10(Pe),'b');
axis tight; grid on;
xlabel('Rate');
ylabel('Log Of Sum Of Error Probabilities')

hold on;

load RS4_N_64_mu_3_Degrading_EsN0-3_backup

ZSort = sort(PerrDegraded);
k = 1:N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
plot(k/N, log10(Pe),'g');
axis tight; grid on;

load 'RS4_N_64_mu_4_Degrading_EsN0-3'

ZSort = sort(PerrDegraded);
k = 1:N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
plot(k/N, log10(Pe),'r');
axis tight; grid on;

load RS4_N_64_mu_5_Degrading

ZSort = sort(PerrDegraded);
k = 1:N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
plot(k/N, log10(Pe),'c');
axis tight; grid on;

title('RS-4, N = 64, AWGN, EsN0 = -3dB');
legend('Genie-Aided', '\mu = 3', '\mu = 4', '\mu = 5');


