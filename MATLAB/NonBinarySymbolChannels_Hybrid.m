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

function Q = NonBinarySymbolChannels_Hybrid(W, mu, n)

W(W < 1e-20) = 1e-20;
W = log2(W);%work with logarithmic values

Q = cell(1,n);
[Q{:}] = deal(W);%prepare initial result for each bit-channel

%cell array of matrices to save intermediate results. this helps to save
%time since same results won't be calculated several times
QRes = cell(1, log10(n)/log10(4) + 1);

for i = 1:n
    %clc;
    display(['Working on symbol-channel ', num2str(i)]);
    display('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    
    Index = dec2base(i-1, 4, log10(n)/log10(4));
    
    %upon building a new bit-channel (starting from the 2nd, delete
    %intermediate results slots that should be recalculated
    if i > 1
        IndexPrev = dec2base(i-2, 4, log10(n)/log10(4));
        IndexStart = find(Index ~= IndexPrev, 1);
    else
        IndexStart = 1;
        QRes{1} = Q{i};
    end
    
    %build a symbol channel
    %for j = IndexStart : log10(n)/log10(4)
    for j = IndexStart : log10(n)/log10(4)
        display(['The Depth is: ',num2str(j),', The Channel Size Before Transform Is: ', num2str(size(QRes{j},2)), '. Using Transform: ', Index(j)]);
        tic;
        
        QRes{j + 1} = ChannelTransformRSTrellis_Hybrid(single(QRes{j}), str2double(Index(j)), mu);% %Arikan channel transorm
        
        toc;
       
    end
    
    CurrentIndex = i;
    Q{i} = 2.^ QRes{end};%update final result
    save('Q_temp', 'Q', 'CurrentIndex','QRes');
    display(' ');
end
end