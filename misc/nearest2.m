function [Aind, Bind] = nearest(A,B,nearby);
% [Aind, Bind] = nearest(A,B,nearby);
% Returns the semi-unique set of one-to-one paired indices having least
% separation. That is, the points identified by Aind and Bind represent
% matched pairs from A and B which are closest to one another.  It is
% semi-unique because it is possible for multiple points to be equidistant,
% for example staggered points with equal separation.

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
k = 1;
i = 1;
j = 1;

while length(uA)&&length(uB)
    change = true;
    while change&&(i<(length(uA)-1))&&(j<(length(uB)-1))
        change = false;
        while (abs(uA(i)-uB(j))>=abs(uA(i)-uB(j+1))) &&(i<(length(uA)-1))&&(j<(length(uB)-1))
            %         d = abs(uA(i)-uB(j));
            j = j+1;
            change = true;
        end
        while (abs(uA(i)-uB(j))>abs(uA(i+1)-uB(j))) &&(i<(length(uA)-1))&&(j<(length(uB)-1))
            %         d = abs(uA(i)-uB(j));
            i = i+1;
            change = true;
        end
    end
    Aind(k) = i;
    Bind(k) = j;
    
    i = i+1;
    j = j+1;
    k = k+1;
    %     [Aind, Bind]
    %     found matched pair
    %     Save it as a pair
    %     advance both counters
end
Aind(k+1:end) = [];
Bind(k+1:end) = [];
near = abs(uA(Aind)-uB(Bind))<nearby;
Aind = Aind(near);
Bind = Bind(near); 