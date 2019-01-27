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

classdef LRListMember < handle
    properties
        a
        b
        a1
        b1
        DeltaI
        h
    end
    properties(SetAccess = private)
        Next
        Prev
    end
    
    methods
        function obj = LRListMember(a, b, a1, b1, DeltaI, h)
            % Object Constructor
            if nargin > 0
                obj.a = a;
                obj.b = b;
                obj.a1 = a1;
                obj.b1 = b1;
                obj.DeltaI = DeltaI;
            end
        end
        
        function insertAfter(newNode, nodeBefore)
            % insertAfter  Inserts newNode after nodeBefore.
            disconnect(newNode);
            newNode.Next = nodeBefore.Next;
            newNode.Prev = nodeBefore;
            if ~isempty(nodeBefore.Next)
                nodeBefore.Next.Prev = newNode;
            end
            nodeBefore.Next = newNode;
        end
        
        function insertBefore(newNode, nodeAfter)
            % insertBefore  Inserts newNode before nodeAfter.
            disconnect(newNode);
            newNode.Next = nodeAfter;
            newNode.Prev = nodeAfter.Prev;
            if ~isempty(nodeAfter.Prev)
                nodeAfter.Prev.Next = newNode;
            end
            nodeAfter.Prev = newNode;
        end
        
        function disconnect(node)
            % DISCONNECT  Removes a node from a linked list.
            % The node can be reconnected or moved to a different list.
            prevNode = node.Prev;
            nextNode = node.Next;
            if ~isempty(prevNode)
                prevNode.Next = nextNode;
            end
            if ~isempty(nextNode)
                nextNode.Prev = prevNode;
            end
            node.Next = [];
            node.Prev = [];
        end
        
        function delete(node)
            % DELETE  Deletes a dlnode from a linked list.
            disconnect(node);
        end
        
    end
end