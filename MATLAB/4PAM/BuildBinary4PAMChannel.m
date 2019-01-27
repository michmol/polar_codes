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

function [Q, Z] = BuildBinary4PAMChannel(W1, W2, Wtot, mu, n)


Q1 = log2(W1);
Q2 = log2(W2);
Qtot = log2(Wtot);

Q = cell(1,n);
[Q{:}] = deal(Q1);%prepare initial result for each bit-channel

%cell array of matrices to save intermediate results. this helps to save
%time since same results won't be calculated several times
QRes = cell(1, log2(n) + 1);

% [~, Z1] = IandZ(W1);
% [~, Z2] = IandZ(W2);
[~, Z02] = IandZ(Wtot([1,3],:));
[~, Z13] = IandZ(Wtot([2,4],:));
[~, Z03] = IandZ(Wtot([1,4],:));
[~, Z01] = IandZ(Wtot([1,2],:));
[~, Z23] = IandZ(Wtot([3,4],:));
[~, Z21] = IandZ(Wtot([3,2],:));

ZRes = cell(1,log2(n) + 1);
[ZRes{:}] = deal(Z02);

%go over bit-channels
for i = 1:n
    clc;
    display(['Working on bit-channel ', num2str(i)]);
    
    iBin = dec2bin(i-1,log2(n));
    
    %upon building a new bit-channel (starting from the 2nd, delete
    %intermediate results slots that should be recalculated
    if i > 1
        iBinPrev = dec2bin(i-2,log2(n));
        IndexStart = find(xor(str2num(iBin(:)), str2num(iBinPrev(:))), 1);
    else
        IndexStart = 1;
        QRes{1} = Q{i};
    end
    
    %build a bit channel
    for j = IndexStart:log2(n)
        if j == 1
%             w = ChannelTransformC_FirstStep(str2double(iBin(j)), Q1, Q2);
%             w = w - log2(sum(sum(2.^w,2))/2);
              w = ChannelTransform_DualInput(str2double(iBin(j)), Qtot);
        else
            w = ChannelTransformC_Full_2nd_transform(str2double(iBin(j)), QRes{j});
        end
        
        if j ==1
            if (str2double(iBin(j)))
                ZRes{j + 1} = min(1, 0.5*(Z03 + Z01 + Z23 + Z21));
            else
                ZRes{j + 1} = 0.5*(Z02 + Z13);
            end
        else
            if (str2double(iBin(j)))
                ZRes{j + 1} = ZRes{j}^2;
            else
                ZRes{j + 1} = 2*ZRes{j} - ZRes{j}.^2;
            end
        end
            
        QRes{j + 1} = log2(DegradedMerge2Double(2.^ w,mu));%again, bound the size of the output alphabet which had grown;
    end
       
    Q{i} = QRes{end};%update final result;
    Z{i} = ZRes{end};
end

for ind = 1:n
    Q{ind} = 2 .^ Q{ind}; %go back to normal probabillities
end

Z = cell2mat(Z);