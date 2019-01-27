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
#include "LRLinkedList.h"


LRListMember :: LRListMember()
{

}
LRListMember :: LRListMember(double a, double a1, double b, double b1, double DeltaI, int h)
{
     Prev = NULL;
	 Next = NULL;
     
	 this->a = a;
	 this->a1 = a1;
	 this->b = b;
	 this->b1 = b1;
	 this->DeltaI = DeltaI;
	 this->h = h;
}

void LRListMember::Delete()
{
	if (Next != NULL)
		Next->Prev = Prev;
	
	if (Prev != NULL)
			Prev->Next = Next;

	Prev = NULL;
	Next = NULL;
}

LRList::LRList(int s)
{
	Members = VecList(s);
	Head = &Members[0];
	Size = Members.size();
}

void LRListMember::InsertAfter(LRListMember &NodeAfter)
{
	NodeAfter.Prev = this;
	Next = &NodeAfter;

	return;
}

void LRList::DeleteMember(LRListMember  *d)
{
	if (d == Head)
		Head = Head->Next;

	d->Delete();
	Size--;
}