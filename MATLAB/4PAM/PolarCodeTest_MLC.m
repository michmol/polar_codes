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
clear;

%Create Parralel comupting pool
Pool = gcp;%Get Current Pool. if one doesn't exist create it using parpool
NumOfWorkers = Pool.NumWorkers;

M = 1000000;%amount of simulation iterations

N = 1024;%codeword length
EsNo = 2;%[dB]

Symbols4PAM = 1/sqrt(5)*[-3, -1, 1, 3];

EsNoLin = 10 ^ (EsNo / 10);
S2 = 1 / (2*EsNoLin);%Noise Variance

U = zeros(NumOfWorkers,N);
U1 = zeros(NumOfWorkers,N/2);
U2 = zeros(NumOfWorkers,N/2);
X1 = zeros(NumOfWorkers,N/2);
X2 = zeros(NumOfWorkers,N/2);
S = zeros(NumOfWorkers,N);
S_4PAM = zeros(NumOfWorkers,N/2);
Y = zeros(NumOfWorkers,N/2);
Y_4PAM = zeros(NumOfWorkers,N/2);
L1 = zeros(NumOfWorkers,N/2);
L2 = zeros(NumOfWorkers,N/2);
UTag = zeros(NumOfWorkers,N);
UTag1 = zeros(NumOfWorkers,N/2);
UTag2 = zeros(NumOfWorkers,N/2);
ErrorVec = zeros(NumOfWorkers,N);

figure;
pause(0.001);
T = tic;
for ParInd = 1:NumOfWorkers
    for ind = 1:M/NumOfWorkers
        if (ParInd == 1 && ~mod(ind,25))
            display(['Iteration ', num2str(ind*NumOfWorkers), ' out of ', num2str(M),'. Elapsed Time: ' num2str(toc(T)), '[sec]']);
            
            P = sum(ErrorVec);
            plot(P,'.')
            xlabel('Channel Index');
            ylabel('Error Probabillity');
            axis tight;
            pause(0.01);
        end
        
        U1(ParInd,:) = round(rand(1, N/2));%generate random input vector
        U2(ParInd,:) = round(rand(1, N/2));%generate random input vector
        U(ParInd,:) = reshape([U1(ParInd,:); U2(ParInd,:)],1, []);
        
        X1(ParInd,:) = PolarEncodeC(U1(ParInd,:));%polar encoding
        X2(ParInd,:) = PolarEncodeC(U2(ParInd,:));%polar encoding
        
        %Symbols For PAM
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        %X = randintrlv(X,3);%interleave bits - odds and evens seperately
        %X = reshape(X,1,[]);
        
        X1(ParInd,:) = 2*X1(ParInd,:) - 1;
        X2(ParInd,:) = 2*X2(ParInd,:) - 1;
        
        %Channel - 4-PAM
        %~~~~~~~~~~~~~~~~~        
        S_4PAM(ParInd,:) =  1/sqrt(5)*(2 * X1(ParInd,:)  - X1(ParInd,:) .* X2(ParInd,:)); %Grey Labeling
        
        Y_4PAM(ParInd,:) = S_4PAM(ParInd,:) + sqrt(S2)*randn(size(S_4PAM(ParInd,:)));%AWGN channel
        
        %LLR Decoding
        L1(ParInd,:) = log((exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(1)).^2 / (2*S2)) + exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(2)).^2 / (2*S2))) ./ (exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(4)).^2 / (2*S2)) + exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(3)).^2 / (2*S2))));
        L2(ParInd,:) = log((exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(1)).^2 / (2*S2)) + exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(4)).^2 / (2*S2))) ./ (exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(2)).^2 / (2*S2)) + exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(3)).^2 / (2*S2))));
        
        %L = randdeintrlv([L0;L1],3);%deinterleave symbols
        %L(ParInd,:) = [L0(ParInd,:); L1(ParInd,:)];
        
        UTag1(ParInd,:) = PolarDecodeC(L1(ParInd,:),U1(ParInd,:));%polar decoding
        UTag2(ParInd,:) = PolarDecodeC(L2(ParInd,:),U2(ParInd,:));%polar decoding
        
        UTag(ParInd,:) = reshape([UTag1(ParInd,:); UTag2(ParInd,:)],1, []);
        
        ErrorVec(ParInd,:) = (ErrorVec(ParInd,:)*(ind-1) + double(xor(UTag(ParInd,:), U(ParInd,:)))) / ind;
    end
end

ZSort = sort(P);
k = round(0.9*N) : N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
