function [mfr,anc_mfr] = read_mfr(filename);
% [mfr,anc_mfr] = read_mfr(filename);
% Patterned after "read_mpl" this function attempts to read an mfr
% file in a variety of input formats and provide two consistent
% formats as output; anc_mfr suitable for ancsave and a more terse mfr
% This function calls ancload, anc2mfr, and read_rsr
% 
%     $Revision: 1.1 $      
%     $Date: 2013/12/11 04:25:44 $          

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: read_mfr.m,v $         
%   $Revision: 1.1 $        
%   $Date: 2013/12/11 04:25:44 $            
%
%   $Log: read_mfr.m,v $
%   Revision 1.1  2013/12/11 04:25:44  cflynn
%   Commit mfrsr processing code
%
%   Revision 1.1  2011/04/08 13:50:07  cflynn
%   *** empty log message ***
%
%   Revision 1.1  2007/11/09 01:24:49  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:09:07  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.1  2006/08/10 19:41:20  cflynn
%   Committing a whole slew of mfrsr processing scripts so I can use them from my other PC.
%             
%
%-------------------------------------------------------------------
if nargin==0
    disp(['Select an MFR data file'])
    [fid, fname, pname] = getfile('*.*', 'mfr_data');
    filename = [pname fname];
    fclose(fid);
end
status = 0;
ncid = ncmex('open', filename, 'write');
if (ncid>0)  %It's a valid netcdf file so read it
    ncmex('close', ncid);
    anc_mfr = ancload(filename);
    mfr = anc2mfr(anc_mfr);
else
   [mfr, anc_mfr] = read_rsr(filename);
   
end

