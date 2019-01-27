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

clc;

%FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\DegradedChannels_1024_256_AWGN_1_1.csv';
%FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\DegradedChannels_1024_256_BSC_001.csv';
%FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\DegradedChannels_1024_256_BSC_011.csv';
%FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\DegradedChannels_1024_256_BSC_01147.csv';
%FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\DegradedChannels_1024_128_BSC_0147.csv';
%FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\DegradedChannels_1024_256_BSC_0127.csv';
%FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\DegradedChannels_1024_256_BEC_05492.csv';
%FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\DegradedChannels_1024_256_BSC_01155.csv';
%FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\DegradedChannels_1024_512_AWGN_SNR_5.csv';

FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\Results\DegradedChannels_1024_512_AWGN_SNR_5.csv';
FilePath = 'C:\Users\Michael\Dropbox\Codes\C Code\DegradedChannel_TV\Debug\Results\UpgradedChannels_New.csv';

D =  textread(FilePath,'','delimiter',',');

%I = sum(sum(0.5 * W .* log2(W ./ repmat(0.5*(W(1,:) + W(2,:)),2,1))));

Z = zeros(1, size(D,1));
Perr = zeros(1, size(D,1));
for ind = 1:length(Z)
    C = D(ind, :);
    C(C == -1) = [];
    Cconj = fliplr(C);
    
    %    PSym = (Ch + ChConj) * 0.5; %probaility to receive each symbol
    %    PeGivenSym = min(Ch, ChConj) ./ (Ch + ChConj);
    %    Perr(ind) = sum(PeGivenSym .* PSym);
    
    Z(ind) = sum(sqrt(C .* Cconj));
    Perr(ind) = 0.5 * sum(min(C, Cconj));
end

% figure;plot(1:length(Z), Z,'.');
% title('C++ Simulation Z');

figure;plot(1:length(Z), Perr,'.');axis tight;

ZSort = sort(Perr);
%ZSort = sort(Z);
k = 1 : 1024;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end

figure;plot(k/1024, log10(Pe));
axis tight; grid on;
