function [Aind, Bind] = nearest(A,B,nearby);
% [Aind, Bind] = nearest(A,B,nearby);
% Returns the unique set of one-to-one paired indices having least
% separation. That is, the points identified by Aind and Bind represent
% matched pairs from A and B which are closest to one another.

uA = unique(A);
uB = unique(B);
if (length(A)~=length(uA))|(length(B)~=length(uB))
    disp('Inputs must be unique')
    return
end
if any(uA~=A)|any(uB~=B)
    disp('Inputs must be strictly monotonic increasing')
    return
end
if ~exist('nearby','var')
    nearby = 2*max([uA(2)-uA(1),uB(2)-uB(1)]);
end
clear A B
Aind = zeros([min([length(uA),length(uB)]),1]);
Bind = Aind;
k = 0;
i = 0;
j = 0;

while (i<(length(uA)-1)) && (j<(length(uB)-1))
    i = i+1;
    j = j+1;
    k = k+1;
    change = true;
    while change && (i<(length(uA)-1)) && (j<(length(uB)-1))
        change = false;
%         while (abs(uA(i)-uB(j))>abs(uA(i)-uB(j+1))) && (i<(length(uA)-1)) && (j<(length(uB)-1))
         while (abs(uA(i)-uB(j))>abs(uA(i)-uB(j+1))) && (j<(length(uB)-1))
            %         d = abs(uA(i)-uB(j));
            j = j+1;
            change = true;
        end
        while (abs(uA(i)-uB(j))>abs(uA(i+1)-uB(j))) && (i<(length(uA)-1))
            %         d = abs(uA(i)-uB(j));
            i = i+1;
            change = true;
        end
    end
    %  [Aind, Bind]  Store matched pair    
    Aind(k) = i;
    Bind(k) = j;
end
% One list or the other has one element.
if i==(length(uA)-1) && j<(length(uB)-1)
        while (abs(uA(i)-uB(j))>abs(uA(i)-uB(j+1))) && (j<(length(uB)-1))
            j = j+1;
        end
elseif i<(length(uA)-1) && j==(length(uB)-1)
           while (abs(uA(i)-uB(j))>abs(uA(i+1)-uB(j))) && (i<(length(uA)-1))
            i = i+1;
           end
end
    i = i+1;
    j = j+1;
    k = k+1;
    Aind(k) = i;
    Bind(k) = j;
    %Aind(k+1:end) = [];
if k <length(uA)
  Aind((k+1):end) = [];
end
if k<length(uB)
   Bind((k+1):end) = [];
end
near = abs(uA(Aind)-uB(Bind))<nearby;
Aind = Aind(near);
Bind = Bind(near); 