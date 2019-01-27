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

function [Q, Z] = DegradedPolarChannel(W, mu, n)
% function Q = DegradedPolarChannel(y,W, mu, n)
%
% Description:
% ~~~~~~~~~~~
% This function performs channel degradation according to Tal & Vardy's
% Algorithm
%
% Inputs:
% ~~~~~~
% W - the undelying channel or the probabillity vector for the continiuous
% case
% mu - The desired channel size
% n - the total amount of bit channels in the polar transform. Must be a
% power of 2
%
% Outputs:
% ~~~~~~~
% Q - the  degraded  bit channels


Q1 = log2(W);%work with logarithmic values

Q = cell(1,n);
[Q{:}] = deal(Q1);%prepare initial result for each bit-channel

%cell array of matrices to save intermediate results. this helps to save
%time since same results won't be calculated several times
QRes = cell(1, log2(n) + 1);

[~, z] = IandZ(W);
Z = z*ones(1,n);

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
            w = ChannelTrasform0_Long(QRes{j});%1st Arikan channel transorm
               Z(i + 1) = 2*Z(i) - Z(i)^2;
        else
            w = ChannelTrasform1_Long(QRes{j});%2nd Arikan channel transorm
                Z(i + 1) = Z(i)^2;
        end
        
        QRes{j + 1} = log2(DegradedMerge2Double(2.^w, mu));%again, bound the size of the output alphabet which had grown;
        
        %%%%QRes_2nd{j + 1} = DegradingMerge2(w, mu);
    end
    
    Q{i} = QRes{end};%update final result
%     save('Q_temp', 'Q', 'i','QRes');
end

for ind = 1:n
    Q{ind} = 2 .^ Q{ind}; %go back to normal probabillities
end
end


%%
function w = ChannelTrasform0(Q)
w = zeros(size(Q,1), size(Q,2).^2 /2);%initialization
N = size(Q,2);
for i = 1:size(Q,1)
    for n = 1:N
        for m = 1:N/2
            %w(i,m,n) = 0.5 * (Q(xor(i-1,0)+1, m) * Q(1,n) + Q(xor(i-1,1)+1, m) * Q(2,n));
            if ~mod(n, 2)
                l = ceil(n/2);
            else
                l = N - n/2 + 1;
            end
            
            w(i, m + N/2 *(l - 1)) = LogAdd(Q(xor(i-1,0)+1, m) +  Q(1,n), Q(xor(i-1,1)+1, m) + Q(2,n));
        end
    end
end
end

function w = ChannelTrasform0_Long(Q)
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
w = zeros(size(Q,1), size(Q,2), size(Q,2), 1);%initialization
for i = 1:size(Q,1)
    for j = 1
        for m = 1:size(Q,2)
            for n = 1:size(Q,2)
                %w(i, m + (n-1)*size(Q,2) + (j-1)*size(Q,2)^2) = 0.5 * Q(xor(i-1,j-1)+1, m) * Q(j, n);
                w(i, m, n, j) = Q(xor(i-1,j-1)+1, m) + Q(i, n);
            end
        end
    end
end
%w = reshape(w, size(Q,1), size(Q,2) .^ 2 * size(Q,1));
w = reshape(w, size(Q,1), size(Q,2) .^ 2);
end

function w = ChannelTrasform1_Long(Q)
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

LLR = w(1,:) - w(2,:);
[~, LRSortIndices] = sort(LLR);
LRSortIndicesBig = LRSortIndices(end/2 + 1: end);

a = w(1,LRSortIndicesBig(1));   b = w(2,LRSortIndicesBig(1));
a1 = w(1,LRSortIndicesBig(2));  b1 = w(2,LRSortIndicesBig(2));
DeltaI = CalcDeltaI(2^a, 2^b, 2^a1, 2^b1);

d = LRListMember(a,b,a1,b1,DeltaI);

List = repmat(d,1, L-1);
Heap = LRHeap(d, L-1);

for i = 2: L-1
    a = w(1,LRSortIndicesBig(i));           b = w(2,LRSortIndicesBig(i));
    a1 = w(1,LRSortIndicesBig(i+1));        b1 = w(2,LRSortIndicesBig(i+1));
    DeltaI = CalcDeltaI(2^a, 2^b, 2^a1, 2^b1);
    
    List(i) = LRListMember(a,b,a1,b1,DeltaI);%create a new LR member
    
    insertAfter(List(i), List(i-1));%put the new member into the linked list
    
    minHeapInsert(Heap, List(i));%put the new member into the heap
end

l = L;
while 2*l > mu;
    d = heapMinimum(Heap);
    
    a2 = LogAdd(d.a, d.a1);     b2 = LogAdd(d.b, d.b1);
    
    if(~isempty(d.Prev))
        d.Prev.a1 = a2;
        d.Prev.b1 = b2;
        d.Prev.DeltaI = CalcDeltaI(2^d.Prev.a, 2^d.Prev.b, 2^a2, 2^b2);
        heapReplaceMember(Heap, d.Prev);
    end
    
    if (~isempty(d.Next))
        d.Next.a = a2;
        d.Next.b = b2;
        d.Next.DeltaI = CalcDeltaI(2^a2, 2^b2, 2^d.Next.a1, 2^d.Next.b1);
        heapReplaceMember(Heap, d.Next);
    end
    
    l = l-1;
    heapDeleteMember(Heap,d);% remove d from the heap
    delete(d);%Delete d from the linked list
end

List = List(List.isvalid);%leave only valid member of the list. dispose all the deleted ones
Q = zeros(2, length(List) + 1);
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


%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function Q = DegradingMerge2(w, mu)
% w = 2 .^ w;
% 
% phi = w./(2 * repmat(sum(w),2,1));
% 
% b_phi = b(phi, mu);
% 
% mu1 = ceil(mu/exp(1)/log(2));
% SymbolNorms = b_phi(1,:) + 2*mu1* b_phi(2,:);
% NewSymbols = unique(SymbolNorms);
% Q = zeros(2,length(NewSymbols));
% for ind = 1:length(NewSymbols)
%     SymbolaToMerge = w(:, SymbolNorms == NewSymbols(ind));
%     Q(:,ind) = log2(sum(SymbolaToMerge,2));
% end
% end
%%
% function s = b(x, mu)
% 
% persistent alpha;
% persistent beta;
% 
% if isempty(alpha) || isempty(beta)
%     alpha  = 1/exp(1);
%     beta = 1/(exp(1)*log(2));
% end
% 
% mu1 = ceil(beta * mu);
% eta = -x .* log2(x);
% j = ceil(eta * mu);
% 
% s = zeros(size(x));
% s(x < alpha) = j(x < alpha);
% s(x == alpha) = mu1;
% s(x > alpha)= 2*mu1 + 1 - j(x > alpha);
% 
% end