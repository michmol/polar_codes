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

% % % % % % % % % % % % % % % % % %
% BPSK Vs 4PAM
% % % % % % % % % % % % % % % % % %
clc;
clear;

N = 1e6;%codeword length
EsNo = 0:15;%[dB]

SymbolsBPSK = [-1, 1];
Symbols4PAM = 1/sqrt(5)*[-3, -1, 1, 3];


for ind = 1:length(EsNo)
    
    EsNoLin = 10 ^ (EsNo(ind) / 10);
    S2 = 1 / (2*EsNoLin);%Noise Variance
      
    U = round(rand(1, N));%generate random input vector
    
    %Symbols for BPSK
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    S_BPSK = 2*U - 1;
    
    %Symbols For PAM
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    U_Reshaped = reshape(2*U - 1, 2, []);
    S_4PAM =  1/sqrt(5)*(2 * U_Reshaped(1,:)  - U_Reshaped(1,:) .* U_Reshaped(2,:)); %Grey Labeling
    %S_4PAM = (2 * U_Reshaped(1,:) + U_Reshaped(2,:)); %Natural Labeling
    
    
    %AWGN Channel
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Y_BPSK = S_BPSK + sqrt(S2)*randn(size(S_BPSK));
    Y_4PAM = S_4PAM + sqrt(S2)*randn(size(S_4PAM));
    
    %BPSK Reciever
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Distances_BPSK = [  abs(Y_BPSK - SymbolsBPSK(1));...
                        abs(Y_BPSK - SymbolsBPSK(2))];
    
                    [~, STag_BPSK_Index] = min(Distances_BPSK);
    
    UTag_BPSK = STag_BPSK_Index - 1;
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    %4PAM Reciever #1
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Distances_4PAM = [  abs(Y_4PAM - Symbols4PAM(1));...
                        abs(Y_4PAM - Symbols4PAM(2));...
                        abs(Y_4PAM - Symbols4PAM(3));...
                        abs(Y_4PAM - Symbols4PAM(4))];
    
    
    [~, STag_4PAM_Index] = min(Distances_4PAM);
        
    %swap for Gray Labeling
    STag_4PAM_Index(STag_4PAM_Index == 4) = 5;
    STag_4PAM_Index(STag_4PAM_Index == 3) = 4;
    STag_4PAM_Index(STag_4PAM_Index == 5) = 3;
    
    %transfer symbols to bits
    UTag_4PAM = dec2bin(STag_4PAM_Index - 1);
    UTag_4PAM = reshape(UTag_4PAM', [], numel(UTag_4PAM)); 
    UTag_4PAM = double(UTag_4PAM) - 48;
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
%     %4PAM Reciever #2 - bitwise detector for gray labeling
%     %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%     LLR1 = log((exp(-(Y_4PAM + 3).^2/(2*S2)) + exp(-(Y_4PAM + 1).^2/(2*S2))) ./ (exp(-(Y_4PAM - 3).^2/(2*S2)) + exp(-(Y_4PAM - 1).^2/(2*S2))));
%     LLR2 = log((exp(-(Y_4PAM + 3).^2/(2*S2)) + exp(-(Y_4PAM - 3).^2/(2*S2))) ./ (exp(-(Y_4PAM + 1).^2/(2*S2)) + exp(-(Y_4PAM - 1).^2/(2*S2))));
%     
%     UTag1 = zeros(size(LLR1)); UTag1(LLR1 < 0) = 1;
%     UTag2 = zeros(size(LLR2)); UTag2(LLR2 < 0) = 1;
%     
%     UTag_4PAM = [UTag1; UTag2]; UTag_4PAM = UTag_4PAM(:)';
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    %Calculate BER
    BER_BPSK(ind) = sum(xor(UTag_BPSK, U)) / N;
    BER_4PAM(ind) = sum(xor(UTag_4PAM, U)) / N;
    BER_4PAM_Odd(ind) = 2 * sum(xor(UTag_4PAM(1:2:end), U(1:2:end))) / N;
    BER_4PAM_Even(ind) = 2 * sum(xor(UTag_4PAM(2:2:end), U(2:2:end))) / N;
end

% figure;semilogy(EsNo, qfunc(sqrt(2*10.^(EsNo/10))),'--', EsNo, qfunc(sqrt(2*10.^(EsNo/10)))/2,'--', EsNo, BER_4PAM, EsNo, BER_4PAM_Odd, EsNo, BER_4PAM_Even);
% title('4-PAM Constellation');
% xlabel('EbNo [dB]');
% ylabel('BER');
% legend('Q(.)', 'Q(.)/2', '4-PAM', '4-PAM Odd', '4-PAM Even');

figure;semilogy(EsNo, BER_BPSK,  EsNo, BER_4PAM);
title('4-PAM Constellation');
xlabel('EsNo [dB]');
ylabel('BER');
legend('BPSK', '4-PAM');