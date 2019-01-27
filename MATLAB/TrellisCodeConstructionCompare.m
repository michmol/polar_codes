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

function TrellisCodeConstructionCompare(a,b,c)

Diffs1 = zeros(1,length(a));
[~, a] = sort(a);

if nargin > 1
    Diffs2 = zeros(1,length(a));
    [~, b] = sort(b);
end

if nargin > 2
    Diffs3 = zeros(1,length(a));
    [~,c] = sort(c);
end

for ind = 1:length(a)
    a1 = zeros(1,length(a)); a1((a(1:ind))) = 1;
    
    if nargin > 1
        b1 = zeros(1,length(b)); b1((b(1:ind))) = 1;
    end
    
    if nargin > 2
        c1 = zeros(1,length(c)); c1((c(1:ind))) = 1;
    end
    
    Diffs1(ind) = sum(a1 ~= b1) / 2;
    
    if nargin > 2
        Diffs2(ind) = sum(a1 ~= c1) / 2;
        Diffs3(ind) = sum(b1 ~= c1) / 2;
    end
end

T1 = zeros(1,length(a));

if nargin > 1
    T2 = Diffs1;%T1 + Diffs1;
end

if nargin > 2
    T3 = T1 + Diffs2 * 4*Diffs3;
end

C = ['b', 'g', 'r'];
figure;hold on;
for ind = 1: nargin
    plot((1:length(T1))/length(T1), eval(['T', num2str(ind)]), C(ind));
end
xlabel('Rate');
ylabel('Trellis State');
axis tight;
hold off;