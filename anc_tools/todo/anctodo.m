
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add this to ancsave?

function nc = upd_vers(nc);
% populates a global att with the required ARM standard version info
% how is this determined?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nc] = nc_mesh(nc1, nc2, dim)
%meshes two input structs along the specified dim.  This is only possible
%with dims having a coord field.  The resulting nc_struct will have a
%proper coord field (no dups, no missing, monotonic)
% This almost works but currently retains the DOD of the first file.

function [nc1, nc2] = nc_slice(nc, dim, dim_index);
%Returns two nc_structs formed by splitting the input struct at the
%specified dimension index.  The first struct nc1 contains all values with
%dim index <= the specified index value.  If either struct contains zero
%records, it is still returned as a fully-qualified nc_struct but with the
%dimension length set to zero for recdim or [] for non-recdim.  Might as
%well use nc_sift beneath the surface.

function status = nc_diff(nc1, nc2, arg);
%you know what this does.

function [array_of_nc] = nc_bundle(nc, bundle);
%Some of the actual file IO functions I'm not yet clear on such as
%reading/writing portions of an existing file either field by field, as a
%subset of the recdim, or as a hyperslab.

function status = check_coords(nc);
%Checks each dimension for existence and proper content of a coordinate field
% Checks that coord field is: single-dimensioned, monotonic, unique, not missing


anclink ==>> ancdod (includes all static definitions)
add checksum for statics
if failed checksum, try and test

      
ancwriterec(writes anc records for all fields dimensioned against recdim to t_i : t_j. Could include check to see if t_i is at end of 
   current recdim length.  
ancreadrec (reads records r_i to r_j for all fields dimensioned against recdim.  Checks that r_i and r_j <= recdimlen
ancwritevar
ancreadvar

Other ideas...
   Generate a checksum of some kind composed of the dims, gatts, var_names, vatts, that would identify 
a specific DOD.  Create a persistent database of these checksums and of the bare DODs.  When saving an 
ncstruct, check to see if the DOD already exists.  If so, copy the template rather than go through the 
entire def process.

Maybe include a checksum for each field in the read and write process so we can check if a value has 
has changed.  If not, don't write it out again.  If doing this, must also support "force" that will 
write it out regardless.

Things that must be the same for it to be the same DOD:
ndims
recdim
dimlens (except for recdim)
ngatts
ngattnames, ngatttype, more?
nvars, varnames, vardims,
nvatts, nvattnames, nvatttype, ...
   
What needn't be the same?  recdim length.