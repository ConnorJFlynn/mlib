function anc = missing2nan(anc);
% anc = missing2nan(anc)
%
%   anc = missing2nan(anc) detects various attributes used to specify missing 
%   values and replaces occurences in the data with NaN.
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: missing2nan.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: missing2nan.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:29  cflynn
%   *** empty log message ***
%
%   Revision 1.1  2007/11/09 01:24:20  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:08:56  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.3  2006/06/21 23:36:41  cflynn
%   *** empty log message ***
%
%
%-------------------------------------------------------------------

%example of missing value attributes:
% "missing-data"
% field-level :missing_data
% field-level :missing_value
gatts = fieldnames(anc.atts);
gmiss = [];
for g = 1:length(gatts)
   if findstr(char(gatts(g)),'missing')|findstr(char(gatts(g)),'Missing')
      if anc.atts.(char(gatts(g))).datatype==2
         gmiss = unique([gmiss, sscanf(anc.atts.(char(gatts(g))).data,'%f')]);
      else
         gmiss = unique([gmiss, anc.atts.(char(gatts(g))).data]);
      end
      anc.atts.(char(gatts(g))).data = NaN;
   end
end
varnames = fieldnames(anc.vars);
for v = 1:length(varnames)
   vmiss = [];
   missing_values = gmiss;
   if isfield(anc.vars.(char(varnames(v))), 'atts')
      vatts = fieldnames(anc.vars.(char(varnames(v))).atts);
      for va = 1:length(vatts)
         if findstr(char(vatts(va)),'missing')|findstr(char(vatts(va)),'Missing')
            if anc.vars.(char(varnames(v))).atts.(char(vatts(va))).datatype==2
               vmiss = unique([vmiss, sscanf(anc.vars.(char(varnames(v))).atts.(char(vatts(va))).data,'%f')]);
            else
               vmiss = unique([vmiss, anc.vars.(char(varnames(v))).atts.(char(vatts(va))).data]);
            end
            anc.vars.(char(varnames(v))).atts.(char(vatts(va))).data = NaN;
         end
         missing_values = unique([gmiss, vmiss]);
      end
   end
   for m = missing_values
      missings = find(abs((anc.vars.(char(varnames(v))).data - m)/m)<1e-6);
      anc.vars.(char(varnames(v))).data(missings) = NaN;
   end

end
