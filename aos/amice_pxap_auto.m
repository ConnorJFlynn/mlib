function pxap = amice_pxap_auto;

pxapr = rd_pxapr;
[pxapo, resets] = rd_pxapo;
% zoom into a time window of Tr_ to select a period to normalize against or...
% Possibly implement a fixed temporal window since we expect to urn purge air at the 
% beginning of each run
%Or something else such as screened values during some initial start-up period
% or a test for stability, especially during purge air?
Tr_ = pxapr.rel_BGR./pxapr.rel_BGR(1,:);






end