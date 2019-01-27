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

function Q = DegradedPolarChannel(y,W, mu, n)
% function Q = DegradedPolarChannel(y,W, mu, n)
%
% Description:
% ~~~~~~~~~~~
% This function performs channel degradation according to Tal & Vardy's
% Algorithm
%
% Inputs:
% ~~~~~~
% y - the values for which W is their probabillity in the continuous case
% W - the undelying channel or the probabillity vector for the continiuous
% case
% mu - The desired channel size
% n - the total amount of bit channels in the polar transform. Must be a
% power of 2
%
% Outputs:
% ~~~~~~~
% Q - the  degraded  bit channels

Q1 = DegradingMerge(W, mu); %ensure that the initial Q alphabet size is not greater than mu
% Q1 = DegradedMergeContinuous(y,W, mu);%for continuous channel, quantize it to mu levels

Q = cell(1,n);
[Q{:}] = deal(log2(Q1));%prepare initial result for each bit-channel - work with logarithmic values

%cell array of matrices to save intermediate results. this helps to save
%time since same results won't be calculated several times
QRes = cell(1, log2(n) + 1);

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
        if strcmp(iBin(j), '0')
            w = ChannelTrasform0(QRes{j});%1st Arikan channel transorm
        else
            w = ChannelTrasform1(QRes{j});%2nd Arikan channel transorm
        end
        
        QRes{j + 1} = DegradingMerge(w, mu);%again, bound the size of the output alphabet which had grown;
    end
    
    Q{i} = QRes{end};%update final result
    save('Q_temp', 'Q', 'i','QRes');
end

for ind = 1:n
    Q{ind} = 2 .^ Q{ind}; %go back to normal probabillities
end
end
%%
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
    y1 = y(length(W)/2 + Indices(ind): length(W)/2 + Indices(ind + 1));
    y2 = y(length(W)/2 - Indices(ind + 1) + 1: length(W)/2 - Indices(ind)+1);
    W1 = W(length(W)/2 + Indices(ind): length(W)/2 + Indices(ind + 1));
    W2 = W(length(W)/2 - Indices(ind + 1) + 1: length(W)/2 - Indices(ind)+1);
    Q(ind) = trapz(y1,W1);
    Q(end - ind + 1) = trapz(y2,W2);
end
Q = Q/sum(Q);
Q = [Q; fliplr(Q)];
end
%%
function w = ChannelTrasform0(Q)
w = zeros(size(Q,1), size(Q,2), size(Q,2));%initialization
for i = 1:size(Q,1)
    for m = 1:size(Q,2)
        for n = 1:size(Q,2)
            %w(i,m,n) = 0.5 * (Q(xor(i-1,0)+1, m) * Q(1,n) + Q(xor(i-1,1)+1, m) * Q(2,n));
            w(i,m,n) = -1 + LogAdd(Q(xor(i-1,0)+1, m) +  Q(1,n), Q(xor(i-1,1)+1, m) + Q(2,n));
        end
    end
end
w = reshape(w, size(Q,1), size(Q,2) .^ 2);
end
%%
function w = ChannelTrasform1(Q)
w = zeros(size(Q,1), size(Q,2), size(Q,2), size(Q,1));%initialization
for i = 1:size(Q,1)
    for j = 1:size(Q,1)
        for m = 1:size(Q,2)
            for n = 1:size(Q,2)
                %w(i, m + (n-1)*size(Q,2) + (j-1)*size(Q,2)^2) = 0.5 * Q(xor(i-1,j-1)+1, m) * Q(j, n);
                w(i, m, n, j) = -1 +  Q(xor(i-1,j-1)+1, m) + Q(i, n);
            end
        end
    end
end
w = reshape(w, size(Q,1), size(Q,2) .^ 2 * size(Q,1));
end
%%
function Q = DegradingMerge(w, mu)
L = size(w,2) / 2;
if 2*L <= mu
    Q = w;
    return;
end

%LR = w(1,:) ./ w(2,:);
%[LRSort, LRSortIndices] = sort(LLR);
%LRSortIndicesBig = LRSortIndices(LRSort > 1);

LLR = w(1,:) - w(2,:);
[~, LRSortIndices] = sort(LLR);
LRSortIndicesBig = LRSortIndices(end/2 + 1: end);

%initialize the List to gain speed
d = [];
d.a = w(1,LRSortIndicesBig(1));         d.b = w(2,LRSortIndicesBig(1));
d.a1 = w(1,LRSortIndicesBig(2));      d.b1 = w(2,LRSortIndicesBig(2));
d.DeltaI = CalcDeltaI(2^d.a, 2^d.b, 2^d.a1, 2^d.b1);
d.h = 1;
List = repmat(d,1, L-1);

for i = 2: L-1
    d = [];
    d.a = w(1,LRSortIndicesBig(i));         d.b = w(2,LRSortIndicesBig(i));
    d.a1 = w(1,LRSortIndicesBig(i+1));      d.b1 = w(2,LRSortIndicesBig(i+1));
    d.DeltaI = CalcDeltaI(2^d.a, 2^d.b, 2^d.a1, 2^d.b1);
    d.h = 1;
    
%     InsertIndex = find([List(1: i-1).DeltaI] >= d.DeltaI);
%     if isempty(InsertIndex)
%         d.h = i; %this 'd' has the the largest DeltaI. put it in the end of the array
%     else
%         d.h = min(InsertIndex); %update the h of the current member
%         for j = InsertIndex
%             List(j).h = List(j).h + 1; %increase all the values following the added member by 1
%         end
%     end
    
    List(i) = d;
end



l = L;
while 2*l > mu;
    [~, MinIndex] = min([List.DeltaI]);
    d = List(MinIndex);
    a2 = LogAdd(d.a, d.a1);     b2 = LogAdd(d.b, d.b1);
    
    if(MinIndex - 1 > 0)
        List(MinIndex - 1).a1 = a2;
        List(MinIndex - 1).b1 = b2;
        List(MinIndex - 1).DeltaI = CalcDeltaI(2^List(MinIndex - 1).a, 2^List(MinIndex - 1).b, 2^a2, 2^b2);
    end
    
    if MinIndex + 1 <= length([List])
        List(MinIndex + 1).a = a2;
        List(MinIndex + 1).b = b2;
        List(MinIndex + 1).DeltaI = CalcDeltaI(2^a2, 2^b2, 2^List(MinIndex + 1).a1, 2^List(MinIndex + 1).b1);
    end
    
    l = l-1;
    List(MinIndex) = [];
end

Q = zeros(2, length([List]) + 1);
for ind = 1:size(Q,2)-1
    Q(1, ind) = List(ind).a;
    Q(2, ind)= List(ind).b;
end
Q(1,end) = List(end).a1;
Q(2,end) = List(end).b1;

Q = [Q, rot90(Q,2)];
end
%%
function DeltaI = CalcDeltaI(a,b,a1,b1)
C = -(a+b)*log2((a+b)/2) + a*log2(a) + b*log2(b);
C1 = -(a1+b1)*log2((a1+b1)/2) + a1*log2(a1) + b1*log2(b1);
C2 =  -(a+b+a1+b1)*log2((a+b+a1+b1)/2) + (a+a1)*log2(a+a1) + (b+b1)*log2(b+b1);
DeltaI = C+C1-C2;
end
%%
function s = LogAdd(a,b)
s = max(a,b) + log2(1+2^(-abs(a-b)));
end