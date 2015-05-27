function st=netcdfattr2struct(nc,prefixes)
%st=netcdfattr2struct(nc,prefixes)
%retrieve a structure from a netcdf attribute
%which was created by struct2netcdfattr.m
%st       = retrieved structure name
%nc       = netcdf file
%prefixes = prefix which was added by struct2netcdfattr

st=struct('testing____',1);
if ischar(prefixes)
  prefixes={prefixes};
end
plen=length(prefixes);
prefix=mergeVarName(prefixes);
substructs={};
for f = att(nc)
  f{1};
  fn=name(f{1});
  if ~isempty(strmatch(prefix,fn))
    fns=breakVarName(fn);
    if length(fns)==(plen+1)
      st.(fns{plen+1})=f{1}(:);
    elseif sum(strcmp(fns{plen+1},substructs))==0
      substructs={substructs{:} fns{plen+1}};
    end
  end
end
for f = substructs
  n=char(f);
  st.(n)=netcdfattr2struct(nc,{prefixes{:} n});
end
st=rmfield(st,'testing____');
return


function ret=breakVarName(str) %formatted as XXX__YYY__ZZZ to return
%{'XXX','YYY','ZZZ'}
delim='__';
lastidx=1;
ret={};
for d=strfind(str,delim)
  ret={ret{:} str(lastidx:(d-1))};
  lastidx=d+length(delim);
end
ret={ret{:} str(lastidx:length(str))};
return

function ret=mergeVarName(segments)
ret='';
for r=segments
  ret=strcat(ret,'__',char(r));
end
ret=ret(3:length(ret));
return
