
function ancstruct ()

% ANCSTRUCT shows the outline of the Matlab NetCDF structure.
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also ANCCHECK, ANCLIST.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: ancstruct.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: ancstruct.m,v $
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
%   Revision 1.8  2006/06/19 18:41:47  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------

disp('=========================================================');
disp('Matlab NetCDF Structure:');
disp('---------------------------------------------------------');
disp(' ancstruct.fname                  <string>');
disp(' ');
disp(' ancstruct.atts');
disp('          .atts.name');
disp('               .name.data         <string|vector>');
disp('               .name.datatype     <scalar>');
disp('               .name.id           <scalar>');
disp('                ...');
disp(' ');
disp(' ancstruct.dims');
disp('          .dims.name');
disp('               .name.id           <scalar>');
disp('               .name.isunlim      <boolean>');
disp('               .name.length       <scalar>');
disp('                ...');
disp(' ');
disp(' ancstruct.recdim.name            <string>');
disp('                 .id              <scalar>');
disp('                 .length          <scalar>');
disp(' ');
disp(' ancstruct.vars');
disp('          .vars.name');
disp('               .name.atts');
disp('                    .atts.name');
disp('                         .name.data      <string|vector>');
disp('                         .name.datatype  <scalar>');
disp('                         .name.id        <scalar>');
disp('                          ...');
disp('               .name.data         <scalar|vector|matrix>');
disp('               .name.datatype     <scalar>');
disp('               .name.dims         <cell array>');
disp('               .name.id           <scalar>');
disp('                ...');
disp(' ');

% disp('  ncstruct');
% disp('    |');
% disp('    |_fname                      <string>');
% disp('    |');
% disp('    |_atts');
% disp('    |   |');
% disp('    |   |_[attname]');
% disp('    |   |   |_data               <string|vector>');
% disp('    |   |   |_datatype           <scalar>');
% disp('    |   |   |_id                 <scalar>');
% disp('    |   |');
% disp('    |   |_[...]');
% disp('    |');
% disp('    |_dims <struct>');
% disp('    |   |');
% disp('    |   |_[dimname]');
% disp('    |   |   |_id                 <scalar>');
% disp('    |   |   |_isunlim            <boolean>');
% disp('    |   |   |_length             <scalar>');
% disp('    |   |');
% disp('    |   |_[...]');
% disp('    |');
% disp('    |_vars');
% disp('        |');
% disp('        |_[varname]');
% disp('        |   |_atts');
% disp('        |   |   |');
% disp('        |   |   |_[attname]');
% disp('        |   |   |   |_data       <string|vector>');
% disp('        |   |   |   |_datatype   <scalar>');
% disp('        |   |   |   |_id         <scalar>');
% disp('        |   |   |');
% disp('        |   |   |_[...]');
% disp('        |   |');
% disp('        |   |_data               <scalar|vector|matrix>');
% disp('        |   |_datatype           <scalar>');
% disp('        |   |_dims               <cell array>');
% disp('        |   |_id                 <scalar>');
% disp('        |');
% disp('        |_[...]');

disp('=========================================================');

return
