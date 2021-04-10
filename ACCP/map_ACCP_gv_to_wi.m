function w_i = map_ACCP_gv_to_wi(gvi);
% w_i = map_gv_to_wi(gvi);
% for a given GV#, returns the index into the W array
gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73];
w_i = [];
gv_ = interp1(gv,[1:length(gv)],gvi);

if ~isempty(gv_)
WN = [1:27]; 
W_GV(2*[1:13]-1) = WN(1:13);
W_GV(2*[1:13]) = WN(1:13);
W_GV(27) = WN(14);
W_GV(2*[15:27]-2) = WN(15:27);
W_GV(2*[15:27]-1) = WN(15:27); %Mapping the original 27 weights against 54 GVs
% W_GV is a vector of the 53 GVs we are reporting mapped to supplied W indexes
W_gv = NaN([1,73]);
w_i = W_GV(gv_);

end
end

