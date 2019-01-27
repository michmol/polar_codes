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

function ZOut = ZEstimationRS4(Z, n)

ZOut = zeros(1,n);


%cell array of matrices to save intermediate results. this helps to save
%time since same results won't be calculated several times
ZRes = zeros(1, log10(n)/log10(4) + 1);

%go over Symbol-channels
for i = 1:n
    clc;
    display(['Working on symbol-channel ', num2str(i)]);
    
    Index = dec2base(i-1, 4, log10(n)/log10(4));
    
    %upon building a new bit-channel (starting from the 2nd, delete
    %intermediate results slots that should be recalculated
    if i > 1
        IndexPrev = dec2base(i-2, 4, log10(n)/log10(4));
        IndexStart = find(Index ~= IndexPrev, 1);
    else
        IndexStart = 1;
        ZRes(1) = Z;
    end
     
    %build a bit channel
    for j = IndexStart: log10(n)/log10(4)
        switch str2double(Index(j))
            case 0
                ZRes(j + 1) = 4*ZRes(j) + 12*ZRes(j)^2 + 28*ZRes(j)^3 +20*ZRes(j)^4;
                ZRes(j + 1) = 4*ZRes(j) - 6*ZRes(j)^2 + 4*ZRes(j)^3 - ZRes(j)^4;
            case 1
                ZRes(j + 1) = 6*ZRes(j)^2 + 4*ZRes(j)^3 +6*ZRes(j)^4;
                ZRes(j + 1) = 6*ZRes(j)^2 - 8*ZRes(j)^3 + 3*ZRes(j)^4;
            case 2
                ZRes(j + 1) = 4*ZRes(j)^3;
                ZRes(j + 1) = 4*ZRes(j)^3 - 3*ZRes(j)^4;
            case 3
                ZRes(j + 1) = ZRes(j)^4;
        end
        
        if ZRes(j + 1) > 1
            ZRes(j + 1) = 1;
        end
    end
    
    ZOut(i) = ZRes(end);%update final result
end