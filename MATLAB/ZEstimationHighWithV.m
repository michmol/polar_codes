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

function ZOut = ZEstimationHighWithV(Z,Pe, n)

ZOut = zeros(1,n);


%cell array of matrices to save intermediate results. this helps to save
%time since same results won't be calculated several times
ZRes = zeros(1, log2(n) + 1);

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
        ZRes(1) = Pe;%Z;%2*Pe;%Z;
    end
    
    %build a bit channel
    for j = IndexStart:log2(n)
        if strcmp(iBin(j), '0')
            P = ZRes(j)/2;
            P = ZRes(j);
            
            PeRes = 2*P *(1 - P);
            
            ZRes(j + 1) = 2*PeRes;%1st Arikan channel transorm 
            ZRes(j + 1) = PeRes;
        else
            ZRes(j + 1) = ZRes(j)^2;%2nd Arikan channel transorm
            ZRes(j + 1) = 2*ZRes(j)^2;
        end
    end
    
    ZOut(i) = ZRes(end);%update final result
    %ZOut(i) = PeRes(end);
end