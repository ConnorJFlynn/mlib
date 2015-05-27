function dev = sliding_std(in,hW);
% dev = sliding_std(in,hW);
if size(in,2)==1
    flip = true;
    in = in';
end

for h = 1:hW
    front = (1:hW+h-1);
    back = length(in)-front +1;
% dev(h) = stdnonan(in(front),2)';
% dev(length(in)+1-h) = stdnonan(in(back),2)';
dev(h) = nanstd(in(front),[],2)';
dev(length(in)+1-h) = nanstd(in(back),[],2)';

end
for h = 1:(1+2*hW)
    W = h:length(in) + h -(1+2*hW);
    ins(:,h) = in(W);
end
% dev(hW+1:length(dev)-hW) = stdnonan(ins,2)';
dev(hW+1:length(dev)-hW) = nanstd(ins,[],2)';

return