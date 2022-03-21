function [parmin,resnom,res,exitflag]= fit2voigt(dat,par0)
%from input parameters calculates voigt linshape
% input  --v: wavenumber
%        --par0: initial parameters. 4 by g matrix,first row is peak
%                position, second row is intensity,third row is Gaussain width, 
%                fourth row is Lorentzian width
%               
% output -- parmin: best fit parameter,
%        -- resnom: sum fo residual squares, and so on

% written by Mahmut Ruzi, Latrobe Institue for Molecular Sciences, La Trobe
% University, Melbourne, Australia, June 2016
% Dedicated to mom and dad,who have been suffering under the ethnic cleansing policy of Chinese government 
% and were mostly probably kept in one of the hundreds of concentration camps in Xinjiang.

[~,ii]=sort(dat(:,1));      % sort wavenumber in increasing order
dat=dat(ii,:);

%%
% note - Gaussian and Lorentzian width ratio ahould be between 1e-4 to 100
% so that the voigt function is accurate. for details see:

% Sanjar M. Abrarov and Brendan M. Quine, A rational approximation for efficient
% computation of the Voigt function inquantitative spectroscopy, http://arxiv.org/abs/1504.00322


Lb=[0.001 10];  % Lorentzian width range [lower upper]
Gb=[0.1 10];     % Gaussian width range [lower upper]
%
maxfeval=150*numel(par0); % maximum number of function evaluation
lb=([dat(1,1).*ones(1,length(par0(1,:))); 0*ones(1,length(par0(1,:)));...
    Gb(1)*ones(1,length(par0(1,:)));Lb(1)*ones(1,length(par0(1,:)));]);
ub=([dat(end,1).*ones(1,length(par0(1,:)));inf* ones(1,length(par0(1,:)));...
    Gb(2)*ones(1,length(par0(1,:)));Lb(2)*ones(1,length(par0(1,:)))]);

options=optimoptions('lsqnonlin','Algorithm','trust-region-reflective',...
    'jacobian','on','display','iter-detailed','DerivativeCheck','off',...
    'TolFun',1e-6,'TolX',1e-6,'maxfunevals',maxfeval);

[parmin,resnom,res,exitflag]=lsqnonlin(@(par) voigtfitmin(dat,par),par0,lb,ub,options);
%%
function [res,jac]= voigtfitmin(dat,par)
% lsqnonlin minimiser
% vf=voigt_f(dat(:,1),par);
[vf,dvdpar]= fadderiv(dat(:,1),par);
res=vf-dat(:,2);

% Jacobian
    if nargout>1
      jac=dvdpar;
    end
end

end

