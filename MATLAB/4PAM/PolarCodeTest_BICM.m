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
%clear;

%Create Parralel comupting pool
%Pool = gcp;%Get Current Pool. if one doesn't exist create it using parpool
NumOfWorkers = 2;%Pool.NumWorkers;

M = 100000;%amount of simulation iterations

N = 1024;%codeword length
EsNo = 2;%[dB]

Symbols4PAM = 1/sqrt(5)*[-3, -1, 1, 3];

EsNoLin = 10 ^ (EsNo / 10);
S2 = 1 / (2*EsNoLin);%Noise Variance

U = zeros(NumOfWorkers,N);
X = zeros(NumOfWorkers,N);
X_Reshaped = zeros(NumOfWorkers,2, N/2);
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


T = tic;
for ParInd = 1:NumOfWorkers
    for ind = 1:M/NumOfWorkers
        if (ParInd == 1 && ~mod(ind,25))
            display(['Iteration ', num2str(ind*NumOfWorkers), ' out of ', num2str(M),'. Elapsed Time: ' num2str(toc(T)), '[sec]']);
        end
        
        U(ParInd,:) = round(rand(1, N));%generate random input vector
        
        X(ParInd,:) = PolarEncodeC(U(ParInd,:));%polar encoding
        
        X1(ParInd,:) =  X(ParInd,1:2:end);
        X2(ParInd,:) =  X(ParInd,2:2:end);
        
        %X1(ParInd,:) = wkeep(squeeze(X_Reshaped(ParInd,:,:)),[1 N/2],[1 1]);%take the 1st row - BUG
        %X2(ParInd,:) = wkeep(squeeze(X_Reshaped(ParInd,:,:)),[1 N/2],[2 1]);%take the 2nd row - BUG
        
        %Symbols For PAM
        %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        %X1(ParInd,:) = randintrlv(X1(ParInd,:),3);%interleave bits - odds and evens seperately
        %X2(ParInd,:) = randintrlv(X2(ParInd,:),3);%interleave bits - odds and evens seperately
        
        X1(ParInd,:) = 2*X1(ParInd,:) - 1;
        X2(ParInd,:) = 2*X2(ParInd,:) - 1;
        
        
        %Channel - 4-PAM
        %~~~~~~~~~~~~~~~~~
        S_4PAM(ParInd,:) =  1/sqrt(5)*(2 * X1(ParInd,:)  - X1(ParInd,:) .* X2(ParInd,:)); %Grey Labeling
        
        Y_4PAM(ParInd,:) = S_4PAM(ParInd,:) + sqrt(S2)*randn(size(S_4PAM(ParInd,:)));%AWGN channel
        
        %LLR Decoding
        L1(ParInd,:) = log((exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(1)).^2 / (2*S2)) + exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(2)).^2 / (2*S2))) ./ (exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(4)).^2 / (2*S2)) + exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(3)).^2 / (2*S2))));
        L2(ParInd,:) = log((exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(1)).^2 / (2*S2)) + exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(4)).^2 / (2*S2))) ./ (exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(2)).^2 / (2*S2)) + exp(-(Y_4PAM(ParInd,:) - Symbols4PAM(3)).^2 / (2*S2))));
        
        %L1(ParInd,:) = randdeintrlv(L1(ParInd,:),3);%deinterleave symbols
        %L2(ParInd,:) = randdeintrlv(L2(ParInd,:),3);%deinterleave symbols
        
        
        UTag(ParInd,:) = PolarDecodeC(reshape([L1(ParInd,:); L2(ParInd,:)],1,[]), U(ParInd,:));%polar decoding
        
        ErrorVec(ParInd,:) = (ErrorVec(ParInd,:)*(ind-1) + double(xor(UTag(ParInd,:), U(ParInd,:)))) / ind;
        
        pause(0.1);
        P = sum(ErrorVec)/NumOfWorkers;
        plot(P,'.');
        save TempP P;
    end
end

P = sum(ErrorVec)/NumOfWorkers;
figure;plot(P,'.')
xlabel('Channel Index');
ylabel('Error Probabillity');
axis tight;

ZSort = sort(P);
k = round(0.9*N) : N;
Pe = zeros(size(k));
for ind = 1:length(Pe)
    Pe(ind) = sum(ZSort(1:k(ind)));
end
