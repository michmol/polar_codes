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

function Q = NonBinarySymbolChannels_Half(W, mu, n)

W(W < 1e-20) = 1e-20;
W = log2(W);%work with logarithmic values

Q = cell(1,n);
[Q{:}] = deal(W);%prepare initial result for each bit-channel

%cell array of matrices to save intermediate results. this helps to save
%time since same results won't be calculated several times
QRes = cell(1, log10(n)/log10(4) + 1);
SymType = 3 * ones(1, log10(n)/log10(4) + 1);

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
    for j = IndexStart : log10(n)/log10(4)
        display(['The Depth is: ',num2str(j),', The Channel Size Before Transform Is: ', num2str(size(QRes{j},2)), ' Using Transform: ', Index(j)]);
        tic;
        
        %when the size is odd, divide the middle symbol into two symbols to
        %make even amount of symbols
        Size = size(QRes{j},2);
        if mod(Size,2) == 1
            QRes{j} = [QRes{j}(:,1:floor(Size/2)), QRes{j}(:,ceil(Size/2))-3, QRes{j}(:,ceil(Size/2))-3, QRes{j}(:,ceil(Size/2) + 1: end)];
        end
        
        %A = QRes{j}(1,:); B = QRes{j}(2,:); Af = QRes{j}(3,:); Bf = QRes{j}(4,:);
        %QRes{j} = [B; Bf; A; Af];
        
        wBig = ChannelTransformRSTrellis(single(QRes{j}), 1);% %Arikan channel transorm
        
        % a faster way to perform the same action
        w = ChannelTransformRSTrellisHalf(single(QRes{j}), 1);% %Arikan channel transorm 
        
        %exploit symmetry to rebuild the full channel
        w2 = fliplr(w);
        switch SymType(j)
            case 2
                w2 = [w2(3,:); w2(4,:); w2(1,:); w2(2,:)];
                SymType(j+1) = 3;
            case 3
                w2 = [w2(4,:); w2(3,:); w2(2,:); w2(1,:)];
                SymType(j+1) = 4;
            case 4
                w2 = [w2(2,:); w2(1,:); w2(4,:); w2(3,:)];
                SymType(j+1) = 2;
        end
        
        w = [w, w2];
      
        w = 2 .^ w;
                
        w(:, sum(w) == 0) = [];%remove zero symbols
        
        %seperate a really big channel into chunks
        MaxChunkSize = 1e6;
        NumOfChunks = ceil(size(w,2) / MaxChunkSize);
        w1 = cell(1, NumOfChunks);
        
        %NEED TO FIX. TAKE CHUNKS FROM THE CENTER OUTWARDS!!!!!!
        for k = 1:NumOfChunks
            
            w1{k} = DegradedMerge4(w(:, (k-1)*MaxChunkSize + 1: min(k*MaxChunkSize, size(w,2))), mu);%again, bound the size of the output alphabet which had grown
            
            %merge with previous chunk
            if k > 1
                w1{k} =  DegradedMerge4([w1{k-1}, w1{k}]);
            end
        end
               
        QRes{j + 1} = w1{NumOfChunks};
        clear w1;
        
        QRes{j + 1}(QRes{j + 1} < 1e-20) = 1e-20;
        QRes{j + 1} = log2(QRes{j + 1});
        toc;
    end
    
    Q{i} = QRes{end};%update final result
    display(' ');
end

for ind = 1:n
    Q{ind} = 2 .^ Q{ind}; %go back to normal probabillities
end

end

%%
function w = ChannelTransformRSm(Q, Index)
persistent G;

if isempty(G)
    G =[1 1 1 0;...
        2 3 1 0;...
        3 2 1 0;
        1 1 1 2];
    G = gf(G, 2);
end


L = size(Q,2);
switch Index
    %1st RS(4) transform
    %~~~~~~~~~~~~~~~~~~~
    case 0
        w = ones(4, L^4) * -inf;
        for i = 0:L-1
            for j = 0:L-1
                for k = 0:L-1
                    for l = 0:L-1
                        for u1 = 0:3
                            for u2 = 0:3
                                for u3 = 0:3
                                    for u4 = 0:3
                                        IndicesGF = [u1 u2 u3 u4] * G;
                                        Indices = IndicesGF.x + 1;
                                        w(u1+1, 1 + i + L*j + L^2 *k + L^3 *l) = LogAdd(w(u1+1, 1 + i + L*j + L^2 *k + L^3 *l), ...
                                            -6 + Q(Indices(1), i+1) + Q(Indices(2), j+1) + Q(Indices(3), k+1) + Q(Indices(4), l+1));
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        %2nd RS(4) transform
        %~~~~~~~~~~~~~~~~~~~
    case 1
        w = ones(4, 4*L^4) * -inf;
        for i = 1:L
            for j = 1:L
                for k = 1:L
                    for l = 1:L
                        for u1 = 0:3
                            for u2 = 0:3
                                for u3 = 0:3
                                    for u4 = 0:3
                                        IndicesGF = [u1 u2 u3 u4] * G;
                                        Indices = IndicesGF.x + 1;
                                        w(u2+1, i + L*(j-1) + L^2 * (k-1) + L^3 * (l-1) + u1 * L^4) = LogAdd(w(u2+1, i + L*(j-1) + L^2 * (k-1) + L^3 * (l-1) + u1 * L^4),...
                                            -6 + Q(Indices(1), i) + Q(Indices(2), j) + Q(Indices(3), k) + Q(Indices(4), l));
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        %3rd RS(4) transform
        %~~~~~~~~~~~~~~~~~~~
    case 2
        w = ones(4, 16*L^4) * -inf;
        for i = 1:L
            for j = 1:L
                for k = 1:L
                    for l = 1:L
                        for u1 = 0:3
                            for u2 = 0:3
                                for u3 = 0:3
                                    for u4 = 0:3
                                        IndicesGF = [u1 u2 u3 u4] * G;
                                        Indices = IndicesGF.x + 1;
                                        w(u3+1, i + L*(j-1) + L^2 * (k-1) + L^3 * (l-1) + u1 * L^4 + u2 * 4*L^4) = LogAdd(w(u3+1, i + L*(j-1) + L^2 * (k-1) + L^3 * (l-1) + u1 * L^4 + u2 * 4*L^4),...
                                            -6 + Q(Indices(1), i) + Q(Indices(2), j) + Q(Indices(3), k) + Q(Indices(4), l));
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        %4th RS(4) transform
        %~~~~~~~~~~~~~~~~~~~
    otherwise
        w = ones(4, 64*L^4) * -inf;
        for i = 1:L
            for j = 1:L
                for k = 1:L
                    for l = 1:L
                        for u1 = 0:3
                            for u2 = 0:3
                                for u3 = 0:3
                                    for u4 = 0:3
                                        IndicesGF = [u1 u2 u3 u4] * G;
                                        Indices = IndicesGF.x + 1;
                                        w(u4+1, i + L*(j-1) + L^2 * (k-1) + L^3 * (l-1) + u1 * L^4 + u2 * 4*L^4 + u3 * 16*L^4) = LogAdd(w(u4+1, i + L*(j-1) + L^2 * (k-1) + L^3 * (l-1) + u1 * L^4 + u2 * 4*L^4 + u3 * 16*L^4),...
                                            -6 + Q(Indices(1), i) + Q(Indices(2), j) + Q(Indices(3), k) + Q(Indices(4), l));
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end;
end

end