function fieldname=formalizefieldname(str)

% Yohei, 2004-05-22
% Formalizes the given string into a string acceptable for a field name.
% This is mainly for raw###2mat.m where ### is opc, dma, aps, nep, dat or
% air.

replacecharacter=' ,./#()+-­*[]><@&^:%={}\';
replacement=repmat('_', 1,length(replacecharacter));
for i=1:length(replacecharacter);
    str(find(str==replacecharacter(i)))=replacement(i); % replace unacceptable characters with replacements
end;
if isempty(str);
elseif str(1)=='i' | str(1)=='j'
elseif ~isempty(str2num(str(1))) | str(1)=='_'; % the first character is a number, which is not acceptable for a field name
    str=['c' str]; % add a character "c".  it does not have to be "c", though.
end;
fieldname=str;