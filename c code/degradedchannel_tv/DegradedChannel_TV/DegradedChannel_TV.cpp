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

// DegradedChannel_TV.cpp : Defines the entry point for the console application.
//
//I this file is implemented the algorithm of Tal & Vardy For a degraded Polar Channel

#include "stdafx.h"
#include "DegradedChannel_TV.h"


#define DIST_VEC_SIZE	1000000
#define	PI				3.1415
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int _tmain(int argc, _TCHAR* argv[])
{	
	int mu = 256;//a bound on the output alphabet size
	int muCont = 512;//a bound for the continious degrading transform
	int N = (int)pow(2, 10);//amount of bit channels in the polar code
	int MergeType = UPGRADING;//options: DEGRADING, UPGRADING

	cout << "Performing " << MergeType << " Merge" << endl ;

	////Create Gaussian Distribution
	double EsNo = 5;
	int m = 1;//expectancy
	double s = sqrt(1 / (2*pow(10, EsNo / 10)) / 2);//variance
	//double s = 1;
	
	//Gaussian Continious Channel
	VecD WCont(DIST_VEC_SIZE);//the vector for the distribution
	VecD yAxis(DIST_VEC_SIZE);//axis vector for the distribution
	int DistLimit = 15;
	for (int i = 0; i < DIST_VEC_SIZE; i++)
	{
		yAxis[i] = -DistLimit + (double)i * 2 * DistLimit / DIST_VEC_SIZE;
		WCont[i] = 1/sqrt(2 * PI * pow((float)s,2)) * exp(-pow(yAxis[i] - m, 2) / (2 * pow((float)s, 2)));//Gaussian distribution
	}
	cout << "AWGN channel - mu = " << m << ", sigma^2 = " << pow(s,2) << endl;

	Channel W;
	switch (MergeType)
	{
		case DEGRADING:
			W = ContiniousDegradingTransform(yAxis, WCont, muCont);
			break;
		case UPGRADING:
			W = ContiniousUpgradingTransform(yAxis, WCont, muCont);
			break;
	}

	//double I = 0.5 * log2(1 + (float)m / s);//I is the expacted capacity of a AWGN channel

	////BSC Channel
	//Channel W(2);
	//double p = 0.127;
	//VecD W0(2); W0[0] = 1-p; W0[1] = p;
	//VecD W1(2); W1[0] = p; W1[1] = 1-p;
	//W[0] = W0; W[1] = W1;

	//BEC channel
	/*Channel W(4);
	double e = 0.5492;
	VecD W0(2); W0[0] = 1-e; W0[1] = 0;
	VecD W1(2); W1[0] = e/2; W1[1] = e/2;
	VecD W2(2); W2[0] = e/2; W2[1] = e/2; 
	VecD W3(2); W3[0] = 0; W3[1] = 1-e;
	W[0] = W0; W[1] = W1; W[2]= W2; W[3] = W3;*/

	ChanVec Q = MergedPolarChannel(W, N, mu, MergeType);


	//put results to file
	//~~~~~~~~~~~~~~~~~~
	ofstream ResultsFile;
	ResultsFile.open ("UpgradedChannels.csv"); 
	//go back to normal probabilities by doing 2^X
	for (size_t i = 0; i < Q.size(); i++)
	{
		for(int j = 0; j < 2*floor(mu/2); j++)
		{
			if (j >=  (int)Q[i].size()) 
			{
				ResultsFile << -1;
			}
			else
			{
				Q[i][j][0] = pow(2, Q[i][j][0]);
				//Q[i][j][1] = pow(2, Q[i][j][1]);
				ResultsFile << Q[i][j][0];
			}
			
			if ( j != 2*floor(mu/2) - 1)
			ResultsFile << ",";
		}

		ResultsFile << endl;
	}
	ResultsFile.close(); 

	return 0;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ChanVec MergedPolarChannel(Channel W, int N, int mu, int MergeType)
{
	Channel Q1 = log2(W);//work in logarithmic values
	Q1 = PolarMerge(Q1, mu, MergeType);//perform initial degrading merge

	ChanVec Q(N, Q1);//prepare an array of channels - each one corresponds to a different bit channel
	ChanVec QRes((int)log2(N) + 1);//array of channels for saving intermidiate calculation results

	//Go over the bit channels
	for (int i = 0; i < N; i++)
	{
		cout <<"Working On Bit-Channel " << i <<endl;
		string iBin = dec2bin(i, (int)log2(N));//Binary representation of the bit-channel index

		int IndexStart;
		string iBinPrev;
		if (i > 0)
		{
			iBinPrev = dec2bin(i - 1, (int)log2(N));
			IndexStart = Find1stDifferentBit(iBin, iBinPrev);
		}
		else//when i == 0
		{
			IndexStart = 0;
			QRes[0] = Q[i]; 
		}

		//Construct a bit channel
		Channel w;
		for (int j = IndexStart; j < (int)log2(N); j++)
		{
			if (iBin[j] == '0')
				w = ChannelTransform0(QRes[j]);//1st arikan's transform
			else
				w = ChannelTransform1(QRes[j]);//2nd arikan's transform

			QRes[j + 1] = PolarMerge(w, mu, MergeType);
		}

		Q[i] = QRes[QRes.size() - 1];
	}
	return Q;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Channel  ChannelTransform0(Channel Q)
{
	//run only for half of the true Arikan's transform since boths halves have the same probabilities
	int NewSize = (int)pow(Q.size(), 2);
	VecD Zeros(2,0);
	Channel W(NewSize/2, Zeros);
	int k;

	int N = Q.size();
	for (int n = 0; n < N; n++)
		for (int m = 0; m < N/2; m++)
		{
			if (n % 2 == 0)
			{
			    k = m;
			}
			else
			{
				k = N/2 - m - 1;
			}

			W[k + N/2 * n][0] = LogAdd(Q[m][0] + Q[n][0] , Q[m][1] + Q[n][1]);
			W[k + N/2 * n][1] = LogAdd(Q[m][1] + Q[n][0] , Q[m][0] + Q[n][1]);
		}
	return W;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Channel  ChannelTransform1(Channel Q)
{
	//run only for half of the true Arikan's transform since boths halves have the same probabilities
	//Assumption - the 1st input u1 is 0

	int NewSize = 2 * (int)pow(Q.size(), 2);
	Channel W(NewSize/2, Q[1]);
	int N = Q.size();

	for (int n = 0; n < N; n++)
		for (int m = 0; m < N; m++)
		{
				W[m + n*N][0] = Q[m][0] + Q[n][0];
				W[m + n*N][1] = Q[m][1] + Q[n][1];
		}
	return W;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Channel ContiniousUpgradingTransform(VecD y, VecD WCont, int mu)
{
	cout <<"Transforming Continious Channel To Discrete using Upgrading "<< endl;

	VecD L(WCont.size() / 2);//Likelihood ratio vector
	VecD C(WCont.size() / 2);//Auxillary function
	int v = mu/2;
	vector<int> Indices(v+1, 0);
	vector<double> Theta(v, 0);
	
	int j = 0;
	int k = 1;
	for (size_t i = 0; i < C.size(); i++)
	{
		L[i] = WCont[C.size() + i] / WCont[C.size() - i - 1]; 
		C[i] = 1 - L[i]/(L[i] + 1) * log2(1 + 1/L[i]) - 1/(L[i] + 1) * log2(L[i] + 1);
		
		if (C[i] > (double)j / v)
		{
			Indices[j] = i;
			j++;
		}

		if (i > 0 && C[i - 1] < (double)k/v  &&  C[i] >= (double)k/v)
		{
			Theta[k-1] = L[i];
			k++;
		}
	}
	Indices[Indices.size() - 1] = C.size();
	
	Channel Q(2*v, VecD(2, 0));
	double a,b,pi;
	for (int i = 0; i < v; i++)
	{
		a = Trapz(y, WCont, WCont.size()/2 + Indices[i], WCont.size()/2 + Indices[i+1]);
		b = Trapz(y, WCont, WCont.size()/2 - Indices[i+1] + 1, WCont.size()/2 - Indices[i] + 1);
		pi = a + b;

		Q[i][0] = Theta[i] * pi / (Theta[i] + 1);
		Q[Q.size() - 1 - i][0] = pi / (Theta[i] + 1);
		Q[i][1] = Q[Q.size() - 1 - i][0];
		Q[Q.size() - 1 - i][1] = Q[i][0];
	}

	return Q;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Channel ContiniousDegradingTransform(VecD y, VecD WCont, int mu)
{
	cout <<"Transforming Continious Channel To Discrete using Degrading "<< endl;

	VecD L(WCont.size() / 2);//Likelihood ratio vector
	VecD C(WCont.size() / 2);//Auxillary function
	int v = mu/2;
	vector<int> Indices(v+1, 0);
	
	int j = 0;
	for (size_t i = 0; i < C.size(); i++)
	{
		L[i] = WCont[C.size() + i] / WCont[C.size() - i - 1]; 
		C[i] = 1 - L[i]/(L[i] + 1) * log2(1 + 1/L[i]) - 1/(L[i] + 1) * log2(L[i] + 1);
		
		if (C[i] > (double)j / v)
		{
			Indices[j] = i;
			j++;
		}
	}
	Indices[Indices.size() - 1] = C.size();
	
	Channel Q(2*v, VecD(2, 0));
	for (int i = 0; i < v; i++)
	{
		Q[i][0] = Trapz(y, WCont, WCont.size()/2 + Indices[i], WCont.size()/2 + Indices[i+1]);
		Q[i][1] = Trapz(y, WCont, WCont.size()/2 - Indices[i+1] + 1, WCont.size()/2 - Indices[i] + 1);
		Q[Q.size() - 1 - i][0] = Q[i][1];
		Q[Q.size() - 1 - i][1] = Q[i][0];
	}

	return Q;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Channel PolarMerge(Channel W, int mu, int MergeType)
{
	//if the size of the channel is already less the mu, then return 
	if (W.size() <= (size_t)mu)
		return W;

	//a vectors of pair which contains the LLR and the corresponding index
	VecDI LLR(W.size());
	double ZeroCounter = 0;
	double NonZeroSum = 0;

	VecD ZeroIndicator(LLR.size(), 0);
	for (size_t i = 0; i < LLR.size(); i++)
	{
		LLR[i] = make_pair(W[i][0] - W[i][1], i);
		if (LLR[i].first == 0)
		{
			ZeroCounter += 1;
			ZeroIndicator[i] = 1;
		}
		else
			NonZeroSum += pow(2, W[i][0]);
	}
	for (size_t i = 0; i < LLR.size(); i++)
	{
		if (ZeroIndicator[i])
		{
			W[i][0] = log2(1/ZeroCounter * max(1e-50, 1 - NonZeroSum));
			W[i][1] = log2(1/ZeroCounter * max(1e-50, 1 - NonZeroSum));
		}
	}

	sort(LLR.begin(), LLR.end(), PairComperator);//Sort the LLR vector using the PairComperatpr function

	VecDI LLRBig(LLR.begin() + W.size() / 2, LLR.end());//take the Half vector Of the LLRs that contains higher values

	//construct an array in which each member is a pair of probabilities that were chosen using the previous sort
	//In addition, in order to find the member with the minimal DeltaI, construct a heap
	LRList List(LLRBig.size() - 1);//the linked list vector containing linked list members
	LRHeap Heap(LLRBig.size() - 1);//Heap is the same size as the LRVec
	for (int i = 0; i < List.Size;  i++)
	{
		double a = W[LLRBig[i].second][0];
		double b = W[LLRBig[i].second][1];
		double a1 = W[LLRBig[i + 1].second][0];
		double b1 = W[LLRBig[i + 1].second][1];
		int h = 0;
		double DeltaI;

		switch (MergeType)
		{
			case DEGRADING:
				DeltaI = CalcDeltaI(pow(2,a), pow(2,b), pow(2,a1), pow(2,b1));
				break;
			case UPGRADING:
				double Lambda1 = a1 - b1;
				double alpha1 = Lambda1 + LogAdd(a, b) - LogAdd(Lambda1, 0);
				double beta1 = LogAdd(a, b) - LogAdd(Lambda1, 0);
				DeltaI = CalcDeltaI(pow(2,alpha1),  pow(2,beta1), pow(2,a1), pow(2,b1));
		}

		List.Members[i] = LRListMember(a, a1, b, b1,  DeltaI, h);

		Heap.InsertMember(List.Members[i]);//insert the new LRMember to the Heap
		
		//perform the connection within the linked list
		if (i > 0)
			List.Members[i - 1].InsertAfter(List.Members[i]);
	}

	int l = W.size() / 2;//l is the half of the size of the original channel at first
	while (2*l > mu)
	{
		LRListMember *d = Heap.GetMin();//a pointer the the LR member with the lowest DeltaI
		
		double a2, b2;
		switch (MergeType)
		{
			case DEGRADING:
				a2 = LogAdd(d->a, d->a1);
				b2 = LogAdd(d->b, d->b1);
				break;
			case UPGRADING:
				double Lambda1 = d->a1 - d->b1;
				double alpha1 = Lambda1 + LogAdd(d->a, d->b) - LogAdd(Lambda1, 0);
				double beta1 = LogAdd(d->a, d->b) - LogAdd(Lambda1, 0);

				double koko  = LogAdd(d->a, d->b) - LogAdd(alpha1, beta1);

				a2 = LogAdd(alpha1, d->a1);
				b2 = LogAdd(beta1, d->b1);
				break;
		}

		if (d->Prev != NULL)
		{
			//prepare new value
			d->Prev->a1 = a2;
			d->Prev->b1 = b2;
			d->Prev->DeltaI = CalcDeltaI(pow(2,d->Prev->a), pow(2,d->Prev->b), pow(2,a2), pow(2,b2));
			Heap.ReplaceMember(d->Prev->h);//update the structure of the heap 
		}

		if (d->Next != NULL)
		{
			//prepare new value
			d->Next->a = a2;
			d->Next->b = b2;
			d->Next->DeltaI = CalcDeltaI(pow(2,a2), pow(2,b2), pow(2,d->Next->a1), pow(2,d->Next->b1));
			Heap.ReplaceMember(d->Next->h);//update the structure of the heap 
		}

		l = l - 1;
		Heap.DeleteMember(d->h);//delete this member from the heap
		List.DeleteMember(d);//delete this member from from linked list 
	}

	//Create the output channel with alphabet size mu
	Channel Q(2 * (List.Size + 1), W[0]);
	LRListMember *CurrMember = List.Head ;

	for (int i = 0; i < List.Size; i++)
	{
		Q[i][0] = CurrMember->a;
		Q[Q.size() - i - 1][0] = CurrMember->b;
		
		Q[i][1] = CurrMember->b;
		Q[Q.size() - i - 1][1] = CurrMember->a;

		if (i == List.Size - 1)
		{
			Q[List.Size][0] = CurrMember->a1;
			Q[List.Size][1] = CurrMember->b1;

			Q[Q.size() - List.Size - 1][0] = CurrMember->b1;
			Q[Q.size() - List.Size - 1][1] = CurrMember->a1;
		}
		CurrMember = CurrMember->Next;
	}

	return Q;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//implementaion of the log2 function
template <class T>
double log2(T In)
{
	if (In == 0)
		return -50;
	else
		return (double)log(In) / log(2);
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
VecD log2(VecD In)
{
	VecD Out(In.size());

	for (size_t i = 0; i < In.size(); i++)
	{
		if (In[i] == 0)
			Out[i] = -50;
		else
			Out[i] = (double)log(In[i]) / log(2);
	}
	return Out;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Channel log2(Channel In)
{
	Channel Out(In.size(), In[1]);

	for (size_t i = 0; i < In.size(); i++)
		for (size_t j = 0; j < In[i].size(); j++)
		{
			if (In[i][j] == 0)
				Out[i][j] = -50;
			else
				Out[i][j] = (double)log(In[i][j]) / log(2);
		}
	return Out;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
string dec2bin (int v, int NumOfBits) 
{
	string bin;
    int oneorzero;
    for(int i = NumOfBits; i>0; i--) 
	{
		oneorzero = v % 2;
        if (oneorzero == 1)
           bin = "1" + bin;
		else
           bin = "0" + bin;
            
        v /= 2;
     }
        
    return bin;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int Find1stDifferentBit(string s1, string s2)
{
	int Size = min(s1.size(), s2.size());

	for (int i = 0; i < Size; i++)
	{
		if (s1[i] != s2[i])
			return i;
	}

	return Size;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double CalcDeltaI(double a, double b, double a1, double b1)
{
	double C, C1, C2;
	C = -(a+b)*log2((a+b)/2) + a*log2(a) + b*log2(b);
	C1 = -(a1+b1)*log2((a1+b1)/2) + a1*log2(a1) + b1*log2(b1);
	C2 =  -(a+b+a1+b1)*log2((a+b+a1+b1)/2) + (a+a1)*log2(a+a1) + (b+b1)*log2(b+b1);
	return fabs(C+C1-C2);
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double LogAdd(double a, double b)
{
	return max(a,b) + log2(1+pow(2,(-fabs(a-b))));
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
bool PairComperator (const PairDI l, const PairDI r)
{ 
	return l.first < r.first; 
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
double Trapz(VecD &y, VecD &W, int StartInd, int EndInd)
{
	int Length = EndInd - StartInd;
	double Sum = 0;

	for (int i = 0; i < Length - 1; i++)
		Sum += 0.5 * (W[StartInd + i] + W[StartInd + i + 1]) * (y[StartInd + i + 1] - y[StartInd + i]);

	return Sum;
}