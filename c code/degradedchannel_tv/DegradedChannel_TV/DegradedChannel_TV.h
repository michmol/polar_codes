//Copyright 2019 Michael Milkov
// 
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//documentation files (the "Software"), to deal in the Software without restriction, including without limitation
//the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
//and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//The above copyright notice and this permission notice shall be included in all copies or substantial portions
//of the Software.
// 
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
//THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#pragma once
#include "LRLinkedList.h"
#include "LRHeap.h"

typedef vector<double>			VecD;//vector of doubles
typedef vector<VecD>            Channel;
typedef vector<Channel>			ChanVec;//a vector of channels	
typedef pair<double, int>		PairDI;
typedef vector<PairDI>			VecDI;
enum {DEGRADING, UPGRADING};

// declaring functions
ChanVec MergedPolarChannel(Channel W, int N, int mu, int MergeType);
Channel PolarMerge(Channel W, int mu, int MergeType);
Channel ContiniousDegradingTransform(VecD yAxis, VecD WCont, int mu);
Channel ContiniousUpgradingTransform(VecD yAxis, VecD WCont, int mu);
Channel  ChannelTransform0(Channel Q);
Channel  ChannelTransform1(Channel Q);

template <class T> 
double log2(T In);

VecD log2(VecD In);
Channel log2(Channel In);

string dec2bin (int v, int NumOfBits); 
int Find1stDifferentBit(string s1, string s2);
double CalcDeltaI(double a, double b, double a1, double b1);
double LogAdd(double a, double b);
bool PairComperator (const PairDI l, const PairDI r);
double Trapz(VecD &y, VecD &W, int StartInd, int EndInd);