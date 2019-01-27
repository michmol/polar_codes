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

function Q = UpgradedMerge4(w, mu)

phi = w./repmat(sum(w),4,1);

b_phi = r(phi, mu);

%mu1 = ceil(mu*(exp(2)+1)/exp(2));
mu1 = ceil(mu/exp(1)/log(2));

SymbolNorms = b_phi(1,:) + 2*mu1* b_phi(2,:) + (2*mu1)^2 * b_phi(3,:) + (2*mu1)^3 * b_phi(4,:);
clear b_phi;
NewSymbols = unique(SymbolNorms);

Qz = zeros(size(w,1),length(NewSymbols), 'single');
alpha = zeros(size(phi), 'single');

for ind = 1:length(NewSymbols)
    SymbolIndices =  SymbolNorms == NewSymbols(ind);
    SymbolaToMerge = w(:,SymbolIndices);
    phiToMerge = phi(:,SymbolIndices);
    
    [~, MaxSymbol] = max(max(phiToMerge));
    [~, LeaderInput] = max(phiToMerge(:,MaxSymbol));
    
    psy = zeros(size(w,1),1, 'single');
    OtherIndices = [1:LeaderInput - 1, LeaderInput + 1 :size(w,1)];
    psy(OtherIndices) = min(phiToMerge(OtherIndices,:), [], 2);
    psy(LeaderInput) = 1 - sum(psy(OtherIndices));
    
    alpha(:,SymbolIndices) = repmat(psy, 1, size(SymbolaToMerge,2)) ./ phiToMerge .* repmat(phiToMerge(LeaderInput, :), size(w,1),1) ./ psy(LeaderInput);
    alpha(isnan(alpha)) = 1;
    
    Qz(:,ind) = sum(alpha(:,SymbolIndices) .* SymbolaToMerge ,2);
end

e = sum((1-alpha) .* w, 2);
Qk = diag(e);
Qk(:, sum(Qk) == 0) = [];

Q = [Qz, Qk];
end

%%
function s = b(x, mu)

persistent alpha;
persistent beta;

x(x < 1e-20) = 1e-20;

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

end

%% Upgrading merge binning operator
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
    
    x1 = double(evalin(symengine, ['numeric::solve(-t*log(t) = ',num2str(j1),'/',num2str(mu),', t = ',num2str(beta-1/mu),'..',num2str(beta+2/mu),')']));
    m1 = mu;
end

s = zeros(size(x),'single');
s(x < x1) = j(x < x1);


x2 = x - x1;
i = floor(x2 * mu);


s(x >= x1) = j1 + 1 + i(x >= x1);
end