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

        tic;
        mu2 = 0.1;
        A1 = QRes{j + 1};
        A = A1 - repmat(A1(1,:), 4, 1);
        D = ones(size(A1));
        
        for l = 1:size(A,2)
            Symbols = [];
            First = (abs(A(2,:)- A(2,l)) <= mu2);
            B = A;
            B(:, ~First) = nan;
            FirstInd = find(First);
            for m = FirstInd
               Second = (abs(B(3,:)- B(3,m)) <= mu2);
               C = B;
               B(:, ~Second) = nan;
               SecondInd = find(Second);
               for nn = SecondInd
                   Third = (abs(C(4,:)- C(4,nn)) <= mu2);
                   Symbols = [Symbols, A1(:,Third)];
                   A(:,Third) = nan;
                   B(:,Third) = nan;
                   C(:,Third) = nan;
               end
            end
            
            Symbol = repmat(-inf,4,1);
            
            for m = 1:size(Symbols,2)
                Symbol(1) = LogAdd(Symbol(1), Symbols(1,m));
                Symbol(2) = LogAdd(Symbol(2), Symbols(2,m));
                Symbol(3) = LogAdd(Symbol(3), Symbols(3,m));
                Symbol(4) = LogAdd(Symbol(4), Symbols(4,m));
            end
            
            if isinf(Symbol)
                Symbol = ones(4,1);
            end
            
            D(:, l) = Symbol;
        end
        D(:,sum(D) == 4) = [];
        
        toc;
        a = 5;