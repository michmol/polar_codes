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

classdef LRHeap < handle
    %%
    % Heap is a class for representing heap Data types
    % Inherits from handle class
    %
    % Implements heap Data type.
    %
    properties
        Data
    end
    properties(SetAccess = private)
        heapSize
        MaxSize
    end
    
    methods
        %Constructor
        function heap = LRHeap(d, MaxSize)
            heap.Data = repmat(d, 1, MaxSize);
            heap.Data(1).h = 1;
            heap.heapSize = 1;
            heap.MaxSize = MaxSize;
        end
        
        %the index of the minimal heap member
        function min = heapMinimum(heap)
            min = heap.Data(1);
        end
        
        function min = heapExtractMin(heap)
            if heap.heapSize < 1
                error('heap underflow');
            end
            min = heapMinimum(heap);%get the minimum
            heap.Data(1) = heap.Data(heap.heapSize);%put the last elemnt of the heap at the top
            heap.Data(1).h = 1;%update the location of the 1st new element
            heap.heapSize = heap.heapSize - 1;%decrease the heap size
            minHeapify(heap, 1);%heapify
        end
        
        function heapReplaceMember(heap, d)
            i = d.h;
            heap.Data(i) = d;
            heap.Data(i).h = i;
            
            if  i > 1 && heap.Data(floor(i/2)).DeltaI > heap.Data(i).DeltaI
                while i > 1 && heap.Data(floor(i/2)).DeltaI > heap.Data(i).DeltaI
                    temp = heap.Data(i);
                    heap.Data(i) = heap.Data(floor(i/2));
                    heap.Data(i).h = i;
                    heap.Data(floor(i/2)) = temp;
                    heap.Data(floor(i/2)).h = floor(i/2);
                    i = floor(i/2);
                end
            else
                minHeapify(heap, i);
            end                       
        end
        
        function minHeapInsert(heap, d)
            heap.heapSize = heap.heapSize + 1;
            d.h = heap.heapSize;
            heapReplaceMember(heap, d);
        end
        
        function heapDeleteMember(heap, d)
            heap.Data(d.h) = heap.Data(heap.heapSize);%put the last elemnt of the heap at replaced place
            heap.Data(d.h).h = d.h;%update the location of the new location
            heap.heapSize = heap.heapSize - 1;%decrease the heap size
            minHeapify(heap, d.h);%heapify
        end
    end
    
    methods(Access=private)
        
        function minHeapify(heap, i)
            l = 2 * i;
            r = 2 * i + 1;
            
            %find the smallest element in the triplet i,l,r
            if l <= heap.heapSize && heap.Data(l).DeltaI < heap.Data(i).DeltaI
                smallest = l;
            else
                smallest = i;
            end
            
            if r <= heap.heapSize && heap.Data(r).DeltaI < heap.Data(smallest).DeltaI
                smallest = r;
            end
            
            if smallest ~= i
                %perform a swap and than heapify again
                temp = heap.Data(i);
                heap.Data(i) = heap.Data(smallest);
                heap.Data(i).h = i;
                heap.Data(smallest) = temp;
                heap.Data(smallest).h = smallest;
                minHeapify(heap, smallest);
            end
            
        end
    end
end