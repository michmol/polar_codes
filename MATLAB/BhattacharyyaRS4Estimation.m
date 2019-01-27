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

clc;
A = gf([3,1,2; 2,1,3; 1,1,1; 0 1 0],2);

MaxEqn = zeros(4, 4, 3);
for d1 = 0:3
    for d2 = 0:3
        for dx = 1:3
            Res = A * [d1; d2; dx];
            NumOfEqn = sum(Res == 0);
            MaxEqn(d1 + 1, d2 + 1, dx) = NumOfEqn;
        end
    end
end

MaxEqn2 = reshape(MaxEqn,4,4,3);
Z4Coeff = sum(sum(MaxEqn2(:,:,1) == 0));
Z3Coeff = sum(sum(MaxEqn2(:,:,1) == 1));
Z2Coeff = sum(sum(MaxEqn2(:,:,1) == 2));
Z1Coeff = sum(sum(MaxEqn2(:,:,1) == 3));

Z4Coeff = sum(sum(sum(MaxEqn == 0)))/3;
Z3Coeff = sum(sum(sum(MaxEqn == 1)))/3;
Z2Coeff = sum(sum(sum(MaxEqn == 2)))/3;
Z1Coeff = sum(sum(sum(MaxEqn == 3)))/3;


A = gf([2,3,1,1; 3,2,1,1; 1,1,1,1; 0,0,1,0],2);

MaxEqn = zeros(4, 4, 4, 3);
for d1 = 0:3
    for d2 = 0:3
        for d3 = 0:3
            for dx = 1:3
                Res = A * [d1; d2; d3; dx];
                NumOfEqn = sum(Res == 0);
                MaxEqn(d1 + 1, d2 + 1,d3 +1, dx) = NumOfEqn;
            end
        end
    end
end

MaxEqn2 = reshape(MaxEqn,4,16,3);
Z4Coeff = sum(sum(sum(MaxEqn2(:,:,3) == 0)));
Z3Coeff = sum(sum(sum(MaxEqn2(:,:,3) == 1)));
Z2Coeff = sum(sum(sum(MaxEqn2(:,:,3) == 2)));
Z1Coeff = sum(sum(sum(MaxEqn2(:,:,3) == 3)));

Z4Coeff = sum(sum(sum(sum(MaxEqn == 0))))/3;
Z3Coeff = sum(sum(sum(sum(MaxEqn == 1))))/3;
Z2Coeff = sum(sum(sum(sum(MaxEqn == 2))))/3;
Z1Coeff = sum(sum(sum(sum(MaxEqn == 3))))/3;