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

function [ listOfDecidedCodewords, listOfDecidedInfoWords,sOut ] = decodeFromInputLLRegister(inputLLMatrix,frozenIndVecIn,maxListSize,polarCodeConfig)
% this function gets as input the loglikelihood matrix from the channel:
% its first dimension is the code alphabet size, its second is the code
% length in symbols and the third dimension is the list size.
% a vector indicating which symbols are frozen, the possible allowed
% maximum list size and polar code configuration structure. 
    

    codeLengthInBits = size(inputLLMatrix,2)*log2(size(inputLLMatrix,1));
    numberOfOuterCodes = polarCodeConfig.kernelSizeInSymbols;
    outerCodeLengthInBits = codeLengthInBits/numberOfOuterCodes;
    outerCodeLengthInSymbols = outerCodeLengthInBits/polarCodeConfig.symbolSizeInBits;
    currentListSize = size(inputLLMatrix,3);
    % normalize the LL Matrix:
    inputLLMatrixNormalized = normalizeInputList( inputLLMatrix );
    estCodewordList= zeros(currentListSize,codeLengthInBits);
    outerCodeCodeWordDataStruct = zeros(maxListSize,outerCodeLengthInBits,numberOfOuterCodes);
    informationWordDataStruct = zeros(maxListSize,outerCodeLengthInBits,numberOfOuterCodes);
    sOut = ( 1:1:currentListSize ) - 1;
    sVector = cell(1,numberOfOuterCodes);
    
    
    if(codeLengthInBits == polarCodeConfig.kernelSizeInBits)
        [ listOfDecidedCodewords, listOfDecidedInfoWords,sOut ] = findInformationWordBaseCase(inputLLMatrixNormalized,frozenIndVecIn,maxListSize,polarCodeConfig);
        return;
    else
        if(isempty(polarCodeConfig.outerCode))
            polarCodeConfigForOuterCodes = polarCodeConfig;
        else
            polarCodeConfigForOuterCodes = polarCodeConfig.outerCode;
        end
        for idxStep = 1:1:numberOfOuterCodes
            numberOfProcessedOuterCodes = idxStep-1;
            frozenIndVecForOuterCode = frozenIndVecIn(numberOfProcessedOuterCodes*outerCodeLengthInSymbols + (1:1:outerCodeLengthInSymbols));
            % update the coset repository
            if(numberOfProcessedOuterCodes)
                %numOfCodesProcessedSoFar,sOutIn,sPreviousStep,previousDecisionVec,estCodewordListIn,polarCodeConfig)      
                [estCodewordList , sOut] = updateCosetsOfInnerCodes(numberOfProcessedOuterCodes,sOut,sPreviousStep,outerCodeCodeWordDataStruct(1:currentListSize,:,numberOfProcessedOuterCodes),estCodewordList,polarCodeConfig);
            end
            % set the likelihood caclulation method:
            specificCalcLLFunciton = @(inLLMat,cosetLeader) generaCalcLLFunction(polarCodeConfig.decodingfunction{idxStep},inLLMat,cosetLeader,polarCodeConfig.alphabetPermutationTable,polarCodeConfig.binWeightVector);
            
            outerCodeDecoderLLInputContainer = calcLogLikelihoodsOfList(sOut,specificCalcLLFunciton,inputLLMatrixNormalized,estCodewordList,polarCodeConfig);
                
             [ listOfDecidedCodewords, listOfDecidedInfoWord,sPreviousStep ] = decodeFromInputLLRegister(outerCodeDecoderLLInputContainer,frozenIndVecForOuterCode,maxListSize,polarCodeConfigForOuterCodes);
             sVector{idxStep} = sPreviousStep;
             
             
             currentListSize = size(listOfDecidedCodewords,1);
             outerCodeCodeWordDataStruct(1:currentListSize,:,idxStep) = listOfDecidedCodewords;
             informationWordDataStruct(1:currentListSize,:,idxStep) = listOfDecidedInfoWord;
        end
        
    end
    
      [listOfDecidedCodewords , sOut] = updateCosetsOfInnerCodes(numberOfOuterCodes,sOut,sPreviousStep,outerCodeCodeWordDataStruct(1:currentListSize,:,numberOfOuterCodes),estCodewordList,polarCodeConfig);
       listOfDecidedInfoWords = updateInfoListVector(informationWordDataStruct,sVector);
end

