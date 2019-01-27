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

function [estimatedInfoWord, estimatedCodeword,decodedCodewordPassedTheCRC] = SCLDecoding(inLLMat,frozenSymbolsIndicator, polarCodeConfig,crcPolynomial,maxListSize)
% The assumption in this function is that inLLMat is a 2D matrix in which
   % # or rows == polarCodeConfig.alphabetSize
   % # of columns == codeLength in symbols (note that each codeword symbol
   % is composed of  polarCodeConfig.symbolSizeInBits bits. 
   % frozenSymbolsIndicator is size(inLLMat,2) vector having 1 in symbols
   % that are frozen.
   % maxListSize - is the maximum list size allowed in the SCL algorithm.
   
   % the crc size in bits
   crcSize = length(crcPolynomial)-1; 
   [ listOfDecidedCodewords, listOfDecidedInfoWords,sOut ] = decodeFromInputLLRegister(inLLMat,frozenSymbolsIndicator,maxListSize,polarCodeConfig);
   
   % for each estimated codeword that passes the crc 
   % calculate the log-likelihood score, and for choose the one with the
   % maximum score and give it as output.
   
   outListSize = size(listOfDecidedInfoWords,1);
   llscoresList = zeros(outListSize,1);
   passesTheCRC = zeros(outListSize,1);
   
   codeLengthInSymbols = size(inLLMat,2);
   symbolsSizeInBits = log2(size(inLLMat,1));
   sizeOfInformationAndCRCInSymbols = sum(frozenSymbolsIndicator);
   sizeOfInformationAndCRCInBits = sizeOfInformationAndCRCInSymbols*polarCodeConfig.symbolSizeInBits;
   
   weightVectorToConvertBitsToSymbols = 2.^(0:(symbolsSizeInBits-1));
   informationwordPlusCRC = zeros(outListSize,sizeOfInformationAndCRCInBits);
   indicesOfNonFrozenSymbols = find(frozenSymbolsIndicator==0);
   for idxList = 1:1:outListSize
      
       for idxSymbol = 1:1:codeLengthInSymbols
           currentSymbol = weightVectorToConvertBitsToSymbols*listOfDecidedCodewords(idxList,(idxSymbol-1)*symbolsSizeInBits+(1:1:symbolsSizeInBits))';
           llscoresList(idxList) = llscoresList(idxList)+ inLLMat(currentSymbol+1,idxSymbol);
       end
       % calculate the crc for the information part:
            % retrieve the information part (i.e. get rid of the frozen
            % symbols)
            for idxInfoAndCRC = 1:1:length(indicesOfNonFrozenSymbols)
               informationwordPlusCRC(idxList,(idxInfoAndCRC-1)*polarCodeConfig.symbolSizeInBits+(1:1:polarCodeConfig.symbolSizeInBits)) =...
                   listOfDecidedInfoWords(idxList,(indicesOfNonFrozenSymbols(idxInfoAndCRC)-1)*polarCodeConfig.symbolSizeInBits+(1:1:polarCodeConfig.symbolSizeInBits));
            end
            crcPartOfDecodedInformationWord = informationwordPlusCRC(idxList,1:1:crcSize);
            streamOfUserInformationBitsWithoutCRC = informationwordPlusCRC(idxList,(crcSize+1):end);
            % calculate the CRC
            [crcOfDecodedInfoWord]=polynomialDivisorFunc([zeros(1,crcSize) streamOfUserInformationBitsWithoutCRC],crcPolynomial);
             passesTheCRC(idxList) = isequal(crcOfDecodedInfoWord, crcPartOfDecodedInformationWord);
   end
   
   

   decodedCodewordPassedTheCRC = any(passesTheCRC);
   if(decodedCodewordPassedTheCRC)
       % at least one estimated codeword passed the crc --> choose from the
       % ones that passed the crc check the one with the best score
       indicesOfEstimatedInfowordsThatPassedTheCRC = find(passesTheCRC==1);
       [val indexOfMaxLogLLOption]=max(llscoresList(indicesOfEstimatedInfowordsThatPassedTheCRC));
       estimatedInfoWord = informationwordPlusCRC(indicesOfEstimatedInfowordsThatPassedTheCRC(indexOfMaxLogLLOption),(crcSize+1):end);
       estimatedCodeword = listOfDecidedCodewords(indicesOfEstimatedInfowordsThatPassedTheCRC(indexOfMaxLogLLOption),:);
   else
          % if no estimated information word passes the crc choose the one with
            % the maximum score
            
       [val indexOfMaxLogLLOption]=max(llscoresList);
       estimatedInfoWord = informationwordPlusCRC(indexOfMaxLogLLOption,(crcSize+1):end);
       estimatedCodeword = listOfDecidedCodewords(indexOfMaxLogLLOption,:);
   end