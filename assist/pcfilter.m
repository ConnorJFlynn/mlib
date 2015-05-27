function [spec_sig,npcs,spec_noise,IND,U,coefs,mean_spec] = pcfilter(spec,s)
% function [spec_sig,npcs,IND,U,coefs] = pcfilter(spec);
%    Input:
%    ------
%    spec - spectra as [temporal elements vs spectral elements]
%    Output:
%    -------
%    spec_sig - spectra with noise removed by PCA filtering
%             = U(:,1:npcs)*coefs(:,1:npcs)' + M'*ones(1,t) ;
%             with coefs = (spec - ones(t,1)*mean(spec)) * U;
%    npcs     - Number of eigenvectors used for PC filtering;
%               this is an important parameter related to how good
%               the training set is for the filter.
%    IND      - Factor "indicator" function Malinowski, Turner
%    U      - from svd
%
%    ....This version of pcfilter.m applies the method of Turner et al,
%    2006: Noise reduction of Atmospheric Emitted Radiance Interferometer
%    (AERI) observations using Principal Component Analysis, J. Ocean.
%    Atmos. Tech, 23, 1223-1238 to spectra with normal noise.
%

%
% Modified by PMR, 23 May 2009.  See initials within for changes
% Modified by CJF, 14 Nov 2010.  See initials within for changes
if ~exist('s','var')
   s = 1;
end
spec = spec(:,1:s:end);
[t,n] = size(spec);
disp(['Size(spec): ',num2str(size(spec))]);
disp(['Size(cov): ',num2str(size(cov(spec)))])
disp('Call svd...');
tic
[U,D]     = svd( cov(spec-ones(t,1)*mean(spec)) );  % We don't need "V" (PMR)
l       = diag(D);
clear D
toc
% STEP 4
%   Determine the optimal number of eigenvectors to use (using the "factor
%   indicator function IND from Turner et al (2006).

disp('Determine optimal number of eigenvectors...');

for k = n-1:-1:1
   lo(k) = sum(l(k+1:n));
end

REk     = sqrt( lo ./ (t.*(n-(1:(n-1)))) );
IND     = REk ./ (n-(1:(n-1))).^2;
% lim = 
% npcs = sum(IND>max(IND/1e4));
npcs    = find(min(IND(1:floor(length(REk)./2))) == IND(1:floor(length(REk)./2)))
figure; plot([1:length(IND)],IND,'-b.',npcs,IND(npcs),'ro');


% STEP 5
%   Project each spectrum onto the vector space spanned by eigenvectors.

M     = mean( spec );
coefs = (spec - ones(t,1)*M) * U;
% figure; plot([1:length(IND)],IND,'-b.');
% STEP 6
%   Re-construct the data using the projection coefficients
disp('Re-construct spectra...\n');
spec_sig = (U(:,1:npcs)*coefs(:,1:npcs)')' + ones(t,1)*M ;
spec_noise = (U(:,npcs+1:end)*coefs(:,npcs+1:end)')' + ones(t,1)*M ;
%%
% figure; plot([1:length(M)],M,'m-',...
%    [1:length(M)],(U(:,5)*coefs(:,5)')','-',...
%    [1:length(M)],(U(:,6)*coefs(6,:)')','-');
% legend('mean','pc1','pc2')
%%
%    [1:length(M)],(U(:,1)*coefs(:,1)')','-',...
%    [1:length(M)],(U(:,2)*coefs(:,2)')','-',...
%    [1:length(M)],(U(:,3)*coefs(:,3)')','-',...
%    [1:length(M)],(U(:,4)*coefs(:,4)')','-',...
%%

%%

return

