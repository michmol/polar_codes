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

#include "stdafx.h"
#include "LRHeap.h"

LRHeap::LRHeap(const int HeapMaxSize)
{
	Heap = new LRListMember* [HeapMaxSize];
	//LRListMember *Heap[HeapMaxSize];

	HeapSize  = 0;
}

void LRHeap::InsertMember(LRListMember &NewMember)
{
	HeapSize++;//indicate that the heap has grown by 1
	NewMember.h = HeapSize - 1;//1st, put the new member at the end of the list
	Heap[HeapSize - 1] = &NewMember;
	HeapifyUpwards(HeapSize - 1);
}

LRListMember* LRHeap::GetMin()
{
	return Heap[0];
}


void LRHeap::Heapify(int i)
{
	int l = 2 * (i + 1) - 1;
	int r = 2 * (i + 1);
	int Smallest;

	if (l <= HeapSize - 1  &&  Heap[l]->DeltaI  <  Heap[i]->DeltaI)
		Smallest = l;
	else
		Smallest = i;

	if (r <= HeapSize - 1  &&  Heap[r]->DeltaI  <  Heap[Smallest]->DeltaI)
		Smallest = r;
	
	if (Smallest != i)
	{
		LRListMember *temp = Heap[i];
		Heap[i] = Heap[Smallest];
		Heap[i]->h = i;
		Heap[Smallest] = temp;
		Heap[Smallest]->h = Smallest;
		Heapify(Smallest);
	}
}

void LRHeap::HeapifyUpwards(int i)
{
	int f = (int)floor((double)(i + 1) / 2) - 1;
	LRListMember *temp;

	while (i > 0  &&  Heap[f]->DeltaI  >  Heap[i]->DeltaI)
		{
			temp = Heap[i];
			Heap[i] = Heap[f];
			Heap[i]->h = i;
			Heap[f] = temp;
			Heap[f]->h = f;
		}
}

void LRHeap::ReplaceMember(int i)
{
	int f = (int)floor((double)(i + 1) / 2) - 1;

	if (i > 0  &&  Heap[f]->DeltaI  >  Heap[i]->DeltaI)
		HeapifyUpwards(i);
	else
		Heapify(i);
}

void LRHeap::DeleteMember(int i)
{
	Heap[i] = Heap[HeapSize - 1];
	Heap[i]->h = i;
	HeapSize--;
	Heapify(i);
}

LRHeap::~LRHeap()
{
	delete [] Heap;
}