
[k_true] = fitme(deadtime(:,1),deadtime(:,3),eq)
[row,col] = size(ProfileBins);
for w = 1:col
  X = ProfileBins(:,w);
  for v = 1:length(k_true)
    eval(['Y= ',num2str(k_true(v)),' .* ', eq(v,:),';']);
  end
end