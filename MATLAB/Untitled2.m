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
N = 1024;%number of bit channel in the polar coding
Type = 'Degrading';

load ([cd,'\4PAM\Results\Genie_1024_BPSK_ESN0_5']);

ZSort = sort(P);

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

load ([cd,'\4PAM\Results\Degraded_1024_256_BPSK_ESN0_5']);

ZSort = sort(PerrDegraded);
k = 1:N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
plot(k/N, log10(Pe),'r');
axis tight; grid on;



title('AWGN, N = 1024 , EsN0 = 5dB');
legend('Genie-Aided', 'Degraded Approximation');