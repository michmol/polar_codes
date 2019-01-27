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

function G = ComputeG(N)
% function G = ComputeG(N)
% 
% Description:
% ~~~~~~~~~~~
% his function computes the Encoding matrix G of the polar encoder
% 
% Input:
% ~~~~~
% N - The order of the matrix
% 
% Output:
% ~~~~~~
% G - The NxN encoding matrix

G2 = gf([1 0; 1 1],2); %the basic block - in GF(2)
G2 = [1 0; 1 1];

%the base of the recursion
if N == 2
    G = G2;
    return;
end

S = kron(eye(N/2), G2);% a block matrix with G2 along its diagonal

R = RevereseShuffleMat1(N);% the reverese shuffle matrix of order N

GAux = ComputeG(N/2); %using a recursion compute the G of previous order

V = kron(eye(2), GAux);%an NxN block matrix of 2x2 containing GAux along the diagonal

G = S * R * V; %total calculation of the matrix G


function R = RevereseShuffleMat(N)
n = dec2bin(0 : N-1, log2(N));%create a binary representation of 0 : N-1 using log2(N) bits 
n1 = bin2dec(fliplr(n));%reverse bits and convert back to decimal

n1 = n1 + 1;%start from 1 instead of 0

I = eye(N);

R = I(:,n1);%reorder the columns of I so it would fit the reversal

function R = RevereseShuffleMat1(N)
I = eye(N);

n1 = [1:2:N, 2:2:N];

R = I(:,n1);%reorder the columns of I so it would fit the reversal