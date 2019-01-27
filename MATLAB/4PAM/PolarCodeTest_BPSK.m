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
% Polar Code Test Script - BPSK
% % % % % % % % % % % % % % %
clc;
clear;

%Create Parralel comupting pool
%Pool = gcp;%Get Current Pool. if one doesn't exist create it using parpool
NumOfWorkers =1;% Pool.NumWorkers;


M = 100000;%amount of simulation iterations

N = 1024;%codeword length
EsNo = 5;%[dB]

EsNoLin = 10 ^ (EsNo / 10);
S2 = 1 / (2*EsNoLin);%Noise Variance

U = zeros(NumOfWorkers,N);
X = zeros(NumOfWorkers,N);
X_Reshaped = zeros(NumOfWorkers,N);
S = zeros(NumOfWorkers,N);
Y = zeros(NumOfWorkers,N);
L = zeros(NumOfWorkers,N);
UTag = zeros(NumOfWorkers,N);
ErrorVec = zeros(NumOfWorkers,N);

T = tic;
for ParInd = 1:NumOfWorkers
    for ind = 1:M/NumOfWorkers
        if (ParInd == 1 && ~mod(ind,25))
            display(['Iteration ', num2str(ind*NumOfWorkers), ' out of ', num2str(M),'. Elapsed Time: ' num2str(toc(T)), '[sec]']);
            P = sum(ErrorVec)/NumOfWorkers;
            save TempBPSKResults P;
        end
        
        U(ParInd,:) = round(rand(1, N));%generate random input vector
        
        X(ParInd,:) = PolarEncodeC(U(ParInd,:));%polar encoding
        
        X_Reshaped(ParInd,:) = 2*X(ParInd,:) - 1;
        
        S(ParInd,:) =  X_Reshaped(ParInd,:);
        
        
        Y(ParInd,:) = S(ParInd,:) + sqrt(S2)*randn(1,N);%AWGN channel
        
        %LLR Decoding
        L(ParInd,:) = -2*Y(ParInd,:)/S2;
        
        UTag(ParInd,:) = PolarDecodeC(L(ParInd,:),U(ParInd,:));%polar decoding
                
        ErrorVec(ParInd,:) = (ErrorVec(ParInd,:)*(ind-1) + double(xor(UTag(ParInd,:), U(ParInd,:)))) / ind;
    end
end

P = sum(ErrorVec)/NumOfWorkers;
figure;plot(P,'.')
xlabel('Channel Index');
ylabel('Error Probabillity');
axis tight;

% ZSort = sort(P);
% k = round(0.9*N) : N;
% Pe = zeros(size(k));
% for ind = 1:length(Pe)
%     Pe(ind) = sum(ZSort(1:k(ind)));
% end
% figure;plot(k/N, log10(Pe));axis tight; grid on;
% xlabel('Rate');
% ylabel('Log Of Sum Of Error Probabilities');
