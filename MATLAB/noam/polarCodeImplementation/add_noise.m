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

function [ noisy_vector_llrs ] = add_noise( encoded_vector,dB,R )
%The inputs are encoded_vector : the vector of encoded bits, dB : The noise
%power in dB, R: the rate of the code
%The output is the llr vector  of the encoded vector
bpsk_bits=ones(1,length(encoded_vector));
bpsk_bits(find(encoded_vector))=-1;
SNRpbit=10.^(dB/10);                % Eb/No conversion from dB to decimal
No_uncoded=1./SNRpbit;              % since Eb=1
No=No_uncoded./R;
sigma=sqrt(No/2);
rx_waveform=bpsk_bits + sigma*randn(1,length(bpsk_bits));
noisy_vector_llrs=(4/No)*rx_waveform;
end

