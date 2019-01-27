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

function Q = DegradedMergeContinuous(y,W, mu)
L = W(y>0) ./ fliplr(W(y<0)); %likelihood ratio
C = 1 - L./(L+1) .* log2(1 + 1./L) - 1./(L+1) .* log2(L + 1);%auxilary function
v = floor(mu/2);

%find indices the positive side of the axis for which the later integral will be calculated
Indices = zeros(1,v);
for ind = 1: v-1;
    Indices(ind) = find(C > ind / v, 1);
end
Indices = [1, Indices]; Indices(end) = length(C); %add margianl indices

%calculate the discrete approximation using integration on the appropriate
%intervals over the intitial continuous distribution
Q = zeros(1, 2*v);
for ind = 1:v
    %y1 = y(length(W)/2 + Indices(ind): length(W)/2 + Indices(ind + 1));
    %y2 = y(length(W)/2 - Indices(ind + 1) + 1: length(W)/2 - Indices(ind)+1);
    W1 = W(length(W)/2 + Indices(ind): length(W)/2 + Indices(ind + 1));
    W2 = W(length(W)/2 - Indices(ind + 1) + 1: length(W)/2 - Indices(ind)+1);
    %Q(ind) = trapz(y1,W1);
    %Q(end - ind + 1) = trapz(y2,W2);
    Q(ind) = sum(W1) * (y(2) - y(1));
    Q(end - ind + 1) = sum(W2) * (y(2) - y(1));
end
%Q = Q/sum(Q);
Q = [Q; fliplr(Q)];
end