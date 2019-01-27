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

%% test_RS4_CoreEncoder
NinBits = 2*4^7;
input = [ randi([0 1],1,NinBits) ];

codeword1 = polarRS4Encoder(input);
codeword2 = polarGenericEncoder(input,polarCodeConfigRS4);
isequal(codeword1,codeword2)
%% test_UVRS4_CoreEncoder
NinBits = 4^5;
input = [randi([0 1],1,NinBits/4) zeros(1,3*NinBits/4)  ];

codeword1 = polarUVRS4Encoder(input);
codeword2 = polarGenericEncoder(input,polarCodeConfigUVRS4);
isequal(codeword1,codeword2)

%% test Wrapper encoder
NinBits = 4^5;
crcUsed = zeros(1,17);
crcUsed([[0 2 15]+1 17])=1;
nonfrozenSymbols = (4^4)+3*(4^3)+(0:1:(4^3-1));
lengthOfInformation = length(nonfrozenSymbols)*2-16;
streamOfUserInformationBits = randi([0 1],1,lengthOfInformation) ;

encodedCodeword1 = polarUVRS4EncoderWrapper(NinBits,streamOfUserInformationBits,crcUsed,nonfrozenSymbols);
encodedCodeword = polarGenericEncoderWrapper(NinBits,streamOfUserInformationBits,crcUsed,nonfrozenSymbols,polarCodeConfigUVRS4);

isequal(encodedCodeword1,encodedCodeword)

%% load code design file
fid = fopen('codes\RS41024Symr500AWGNatEbN02.50');
vecOfDesign = fread(fid,'int');
NinSymbols = vecOfDesign(1);
fclose(fid);

%% test SCL decoder
polarCodeConfigScript;
profile on;
path(path,'..\LDPCImplementation');

polarCodeConfig=  polarCodeConfigRS4;
NinBits = NinSymbols*polarCodeConfig.symbolSizeInBits;
%crcUsed = zeros(1,17);
%crcUsed([[0 2 15]+1 17])=1;
crcUsed = zeros(1,9);
crcUsed([0     1     2 8]+1)=1;
DesignRatesOfCode = 0.5;
informationSizePlusCRCInSymbols = ceil((ceil(DesignRatesOfCode*NinBits)+length(crcUsed))/polarCodeConfig.symbolSizeInBits);
nonfrozenSymbols = sort(vecOfDesign(1+(1:1:informationSizePlusCRCInSymbols)));


lengthOfInformation = length(nonfrozenSymbols)*2-length(crcUsed);
streamOfUserInformationBits = randi([0 1],1,lengthOfInformation) ;
NUM_OF_TEST = 5;

% create frozen symbols indicator vector
frozenSymbolsIndicator = ones(1,NinBits/polarCodeConfig.symbolSizeInBits);
frozenSymbolsIndicator(nonfrozenSymbols+1)=0;
maxListSize = 32;
RageOfCode = lengthOfInformation/NinBits;
%add noise
Ebn0=1.8;
for idxTest = 1:1:NUM_OF_TEST
    informVec = randi(2,1,lengthOfInformation)-1;
    %informVec = [1 1 1 zeros(1,codeParameters.sizeOfInfoPerCodeword-3)];
    
   % encodedCodeword1 = polarUVRS4EncoderWrapper(N,informVec,crcUsed,nonfrozenSymbols);
    encodedCodeword = polarGenericEncoderWrapper(NinBits,informVec,crcUsed,nonfrozenSymbols,polarCodeConfig);

%     if(isequal(encodedCodeword,encodedCodeword))
%         fprintf(1,'Encoding OK\n');
%     else
%         fprintf(1,'Error in encoding\n');
%     end
  
    [ noisy_vector_llrs ] = add_noise( encodedCodeword,Ebn0,RageOfCode); %add noise, where Ebn0 is in dB.
    
    % prepare logLikelihoodInput matrix
    noisy_vector_llrsQuarternarySmbols = zeros(polarCodeConfig.alphabetSize, NinBits/polarCodeConfig.symbolSizeInBits);
    for idxSymbol = 1:1:polarCodeConfig.alphabetSize
        binRepOfSymbol = dec2binvec(idxSymbol-1,polarCodeConfig.symbolSizeInBits);
        for idxBit = 1:1:polarCodeConfig.symbolSizeInBits
            if(binRepOfSymbol(idxBit)==0)
                noisy_vector_llrsQuarternarySmbols(idxSymbol,:) = noisy_vector_llrsQuarternarySmbols(idxSymbol,:)+noisy_vector_llrs((polarCodeConfig.symbolSizeInBits*(0:1:(NinBits/polarCodeConfig.symbolSizeInBits-1)))+idxBit);
            end
        end
    end
    
    [estimatedInfoWord, estimatedCodeword] = SCLDecoding(noisy_vector_llrsQuarternarySmbols,frozenSymbolsIndicator, polarCodeConfig,crcUsed,maxListSize);

    if(isequal(estimatedInfoWord(1:1:lengthOfInformation), informVec)&& isequal(estimatedCodeword, encodedCodeword))
        fprintf(1,'Test %d - OK\n',idxTest);
    else
        fprintf(1,'Test %d - FAIL\n',idxTest);
    end
end

profile viewer
p = profile('info');
profsave(p,'profile_results_67');
profile off;






