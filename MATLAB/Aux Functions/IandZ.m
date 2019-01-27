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

function [I, Z] = IandZ(W)
% function I = BMS_IandZ(W)
% 
% Decription:
% ~~~~~~~~~~
% Calculate the mutual information of the channel W and the Bhattacharyya
% parameter
% 
% Input: W - the channel matrix
% Output: I - the mutual information
%         Z - the Bhattacharyya parameter

W(W == 0) = 1e-30;

XSizeInv = 1/size(W,1);
Py = XSizeInv * sum(W);

I = sum(sum(XSizeInv * W .* log2(W ./ repmat(Py,size(W,1),1))));%inner sum is over 'x' and the outer is over 'y'

Zold = sum(sqrt(prod(W)));

Din = size(W,1);
Z = 0;
for ind = 1:Din
    for jnd = 1:Din
      if (jnd == ind)
          continue;
      else
          Z = Z + sum(sqrt(W(ind,:) .* W(jnd,:)));
      end
    end
end
Z = Z / Din / (Din - 1);