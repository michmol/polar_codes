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

function [ZLow, ZHigh] = ZEstimationNew(ZLowIn, ZHighIn)

n = length(ZLowIn);

if n == 2
    ZLow = [(ZLowIn(1) + ZLowIn(2))/2 , ZLowIn(1) * ZLowIn(2)];
    ZHigh = [ZHighIn(1) + ZHighIn(2) - ZHighIn(1) * ZHighIn(2), ZHighIn(1) * ZHighIn(2)];
    return;
end

[ZLow1, ZHigh1] = ZEstimationNew(ZLowIn(1:n/2), ZHighIn(1:n/2));
[ZLow2, ZHigh2] = ZEstimationNew(ZLowIn(n/2 +1 :end), ZHighIn(n/2 + 1 :end));

ZLow = reshape([(ZLow1 + ZLow2)/2 ; ZLow1 .* ZLow2], 1, []);
ZHigh = reshape([ZHigh1 + ZHigh2 - ZHigh1 .* ZHigh2; ZHigh1 .* ZHigh2], 1, []);