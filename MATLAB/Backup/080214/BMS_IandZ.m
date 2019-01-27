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

function [I, Z] = BMS_IandZ(W)
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

I = sum(sum(0.5 * W .* log2(W ./ repmat(0.5*(W(1,:) + W(2,:)),2,1))));%inner sum is over 'x' and the outer is over 'y')

Z = sum(sqrt(W(1,:) .* W(2,:)));