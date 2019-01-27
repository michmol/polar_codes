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

function Q = DegradedMerge4Double(w, mu)

w(w <  1e-20) = 1e-20;

phi = w./repmat(sum(w),4,1);

b_phi = r(phi, mu);

clear phi;

mu1 = ceil(mu/exp(1)/log(2));
SymbolNorms = b_phi(1,:) + 2*mu1* b_phi(2,:) + (2*mu1)^2 * b_phi(3,:) + (2*mu1)^3 * b_phi(4,:);
clear b_phi;
NewSymbols = unique(SymbolNorms);
Q = zeros(4,length(NewSymbols));
for ind = 1:length(NewSymbols)
    SymbolaToMerge = w(:, SymbolNorms == NewSymbols(ind));
    Q(:,ind) = sum(SymbolaToMerge,2);
end

Q(:,sum(Q)== 0) = [];
end
%%
function s = b(x, mu)

persistent alpha;
persistent beta;

x(x <  1e-20) = 1e-20;

if isempty(alpha) || isempty(beta)
    alpha  = 1/exp(1);
    beta = 1/(exp(1)*log(2));
end

mu1 = ceil(beta * mu);
eta = -x .* log2(x);
j = ceil(eta * mu);

s = zeros(size(x));
s(x < alpha) = j(x < alpha);
s(x == alpha) = mu1;
s(x > alpha)= 2*mu1 + 1 - j(x > alpha);

s(s <  1e-20) = 1e-20;
end

%% Degraded merge binning operator
function s = r(x, mu)

persistent alpha;
persistent beta;
persistent mu1;
persistent x1;
persistent j1;

if isempty(alpha) || isempty(beta)
    alpha  = 1/exp(1);
    beta = 1/exp(1)^2;
    mu1 = mu;
end

x(x <  1e-20) = 1e-20;

eta = -x .* log(x);
j = ceil(eta * mu);

if mu1 ~= mu || isempty(x1)
    j1 = floor(2 * mu /exp(2));
    
    if (j1+1)/mu < -alpha * log(alpha)
        j1 = j1 + 1;
    end
    
    x1 = double(evalin(symengine, ['numeric::solve(-t*log(t) = ',num2str(j1),'/',num2str(mu),', t = ',num2str(beta-1/mu),'..',num2str(beta+1/mu),')']));
    m1 = mu;
end

s = zeros(size(x));
s(x < x1) = j(x < x1);


x2 = x - x1;
i = floor(x2 * mu);


s(x >= x1) = j1 + 1 + i(x >= x1);
end