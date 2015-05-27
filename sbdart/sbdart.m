%--------------------------------------------------------------------------
%
% SBDART MATLAB INTERFACE
%                                                    Written by Paul Schou
%--------------------------------------------------------------------------
%   Version 1.04, 13 March 2008
%
% SBDART, (Santa Barbara DISORT Atmospheric Radiative Transfer).  SBDART is
% a software tool that computes plane-parallel radiative transfer in clear 
% and cloudy conditions within the Earth's atmosphere and at the surface.  
% For a general description and review of the program please refer to 
% Ricchiazzi et al 1998. (Bulletin of the American Meteorological Society, 
% October 1998).
%
% For more information and updates go to http://paulschou.com/tools/sbdart/
%
%DEFAULT INPUTS:
%
%   idatm   =  4           amix    =  0.0         isat    =  0         
%   wlinf   =  0.550       wlsup   =  0.550       wlinc   =  0.0       
%   sza     =  0.0         csza    =  -1.0        solfac  =  1.0       
%   nf      =  2           iday    =  0           time    =  16.0      
%   alat    =  -64.7670    alon    =  -64.0670    zpres   =  -1.0      
%   pbar    =  -1.0        sclh2o  =  -1.0        uw      =  -1.0      
%   uo3     =  -1.0        o3trp   =  -1.0        ztrp    =  0.0       
%   xrsc    =  1.0         xn2     =  -1.0        xo2     =  -1.0      
%   xco2    =  -1.0        xch4    =  -1.0        xn2o    =  -1.0      
%   xco     =  -1.0        xno2    =  -1.0        xso2    =  -1.0      
%   xnh3    =  -1.0        xno     =  -1.0        xhno3   =  -1.0      
%   xo4     =  1.0         isalb   =  0           albcon  =  0.0       
%   sc      =  1.0,3*0.0   zcloud  =  5*0.0       tcloud  =  5*0.0     
%   lwp     =  5*0.0       nre     =  5*8.0       rhcld   =  -1.0      
%   krhclr  =  0           jaer    =  5*0         zaer    =  5*0.0     
%   taerst  =  5*0.0       iaer    =  0           vis     =  23.0      
%   rhaer   =  -1.0        wlbaer  =  47*0.0      tbaer   =  47*0.0    
%   abaer   =  -1.0        wbaer   =  47*0.950    gbaer   =  47*0.70   
%   pmaer   =  940*0.0     zbaer   =  50*-1.0     dbaer   =  50*-1.0   
%   nothrm  =  -1          nosct   =  0           kdist   =  3         
%   zgrid1  =  0.0         zgrid2  =  30.0        ngrid   =  50        
%   zout    =  0.0,100.0   iout    =  10          deltam  =  t         
%   lamber  =  t           ibcnd   =  0           saza    =  180.0     
%   prnt    =  7*f         ipth    =  1           fisot   =  0.0       
%   temis   =  0.0         nstr    =  4           nzen    =  0         
%   uzen    =  20*-1.0     vzen    = 20*90        nphi    =  0         
%   phi     =  20*-1.0     imomc   =  3           imoma   =  3         
%   ttemp   =  -1.0        btemp   =  -1.0        spowder =  f         
%   idb     =  20*0
%  
%
%USAGE:
%
%  Example #1:
%
%     [WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR] = sbdart('idatm',4,...
%         'isat',0,'wlinf',.25,'wlsup',1.0,'wlinc',.005,'iout',1);
%     plot(WL,BOTDN)
%
%  Example #2:
%
%     r=[]; % Initialize the data array
% 
%     for albcon = [0 .2 .4 .6 .8 1] 
%     for tcloud = [0 1 2 4 8 16 32 64]
%     r=[r sbdart(...
%      'tcloud', tcloud, ...
%      'albcon', albcon, ...
%      'idatm', 4, ...
%      'isat', 0, ...
%      'wlinf', .55, ...
%      'wlsup', .55, ...
%      'isalb', 0, ...
%      'iout', 10, ...
%      'sza', 30)'];
%     end
%     end
% 
%     % Plot of the Surface Irradiance and Planetry Albedo:
%     semilogx([0 1 2 4 8 16 32 64],reshape(r(7,:),8,6))
%     axis tight; ylim([0 2])
%     title('Monochromatic Surface Irradiance (\lambda=0.55, SZA=30)')
%     ylabel('w/m^2/{\mu}m');xlabel('wavelength (microns)');
%     legend(num2str([0 .2 .4 .6 .8 1]','%3.1f'),3)
% 
%     figure
%     semilogx([0 1 2 4 8 16 32 64],reshape(r(5,:),8,6))
%     axis tight; ylim([0 1.6])
%     title('Planetary Albedo (\lambda=0.55, SZA=30)')
%     ylabel('w/m^2/{\mu}m');xlabel('wavelength (microns)');
%     legend(num2str([0 .2 .4 .6 .8 1]','%3.1f'),4)
%
%
%  Example #3:
%
%     d = [];
% 
%     for tcloud = [0 1 5]
% 
%     d=[d; sbdart( ...
%       'tcloud', tcloud, ...
%       'zcloud', 8, ...
%       'nre', 10, ...
%       'idatm', 4, ...
%       'sza', 95, ...
%       'wlinf', 4, ...
%       'wlsup', 20, ...
%       'wlinc', -.01, ...
%       'iout', 1)];
% 
%     end
% 
%     plot(d(1:end/3,1),reshape(d(:,6),length(d)/3,3)')
%     hold on
%     lam = repmat((4:.5:20)',1,4);
%     T = repmat([220 240 260 280],33,1);
%     irr = 3.74E8 ./(lam.^5 .*exp(1.442E4./(lam .* T))-1);
%     plot(lam,irr,'k--');
% 
%     title('Downward Surface Irradiance');
%     ylabel('w/m^2/{\mu}m');xlabel('wavelength (microns)');
%     legend('Tcloud = 0','Tcloud = 1','Tcloud = 5')
%     text(20,irr(end,1),'220K','HorizontalAlignment','right')
%     text(20,irr(end,2),'240K','HorizontalAlignment','right')
%     text(20,irr(end,3),'260K','HorizontalAlignment','right')
%     text(20,irr(end,4),'280K','HorizontalAlignment','right')
%
%
%IOUT - MATLAB OUTPUTS
%  1 -  Outputs: WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
% 
%       Ex: [WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR]= ...
%           sbdart('iout',1,'wlinf',0.2,'wlsup',1,'wlinc',.1); 
%  5 -  Outputs: wl,ffv,topdn,topup,topdir,botdn,botup,botdir,phi,uzen,uurs
%
%       Ex: [wl,ffv,topdn,topup,topdir,botdn,botup,botdir,phi,uzen,uurs]...
%           =sbdart('iout',5,'wlinf',0.2,'wlsup',1.2,'wlinc',.1);
%
%  6 -  Same as 5
%
%  7 -  Outputs: WL,Z,fdird,fdifd,flxdn,flxup
%
%       Ex: [WL,Z,fdird,fdifd,flxdn,flxup]=...
%           sbdart('iout',7,'wlinf',0.2,'wlsup',1.2,'wlinc',.1);
%
% 10 -  Outputs: WLINF,WLSUP,FFEW,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
%
%       Ex: [WLINF,WLSUP,FFEW,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR]=...
%           sbdart('iout',10);
%
% 20 -  Outputs: WLINF,WLSUP,FFEW,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR,
%       phi,zen,r
%
%       Ex: [WLINF,WLSUP,FFEW,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR,phi,...
%           zen,r]=sbdart('wlinf',0.2,'wlsup',1.2,'wlinc',.1,'iout',20);
%
% 21 -  Same as 20
%
% 22 -  Outputs: ffew,phi,uzen,z,fxdn,fxup,fxdir,uurl
%       Note: uurl is in the coordinates of (phi,zen,nz)
%
%       Ex: [ffew,phi,uzen,z,fxdn,fxup,fxdir,uurl]=sbdart('iout',22);
%
% 23 -  Same as 20

function varargout = sbdart(varargin)

% expand any inline cells
varargin2 = {};
debug = 0;
for i = 1:length(varargin);
    if(strcmpi(varargin{i},'debug')); debug = 1; else
    varargin2 = [varargin2 varargin{i}]; end
end

% General usage checks
if(mod(length(varargin2),2) == 1)
    error('Each argument must be a pair of properties and values');
end

% Sanitize the inputs
if(debug); disp('Sanitizing inputs.'); end
qry = '';
iout = 10;
for i = 1:2:length(varargin2);
    if(~isstr(varargin2{i}))
        error(['The variable name at position ' num2str(i) ' is not a string.'])
    end
    if(~isnumeric(varargin2{i+1}))
        error(['The value at position ' num2str(i+1) ' is not a number. ' ...
            10 '(NOTE: False is 0)'])
    end
    if strcmpi('iout',varargin2{i}); iout = varargin2{i+1}; end
    qry = [qry urlencode(varargin2{i}) '=' ...
        urlencode(num2str(reshape(varargin2{i+1},1,[]))) '&'];
end

if(debug); disp('Checking output types.'); end

% Check that the output is ready
if iout == 1 && ~(nargout == 8 || nargout <= 1)
    error('Incorrect number of outputs, Required outputs: WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR')
end
if (iout == 5 || iout == 6) && ~(nargout == 11 || nargout <= 1)
    error('Incorrect number of outputs, Required outputs: wl,ffv,topdn,topup,topdir,botdn,botup,botdir,phi,uzen,uurs')
end
if iout == 7 && ~(nargout == 6 || nargout <= 1)
    error('Incorrect number of outputs, Required outputs: WL,Z,fdird,fdifd,flxdn,flxup')
end
if iout == 10 && ~(nargout == 9 || nargout <= 1)
    error('Incorrect number of outputs, Required outputs: WLINF,WLSUP,FFEW,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR')
end
if iout == 11 && ~(nargout == 8 || nargout <= 1)
    error('Incorrect number of outputs, Required outputs: phidw,zz,pp,fxdn,fxup,fxdir,dfdz,heat')
end
if (iout == 20 || iout == 21 || iout == 23) && ~(nargout == 12 || nargout <= 1)
    error('Incorrect number of outputs, Required outputs: WLINF,WLSUP,FFEW,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR, phi,zen,r')
end
if (iout == 22) && ~(nargout == 8 || nargout <= 1)
    error('Incorrect number of outputs, Required outputs: ffew,phi,uzen,z,fxdn,fxup,fxdir,uurl')
end

if(debug); disp('Opening server connection.'); end

% run SBDART and put the result in dat
try
	server = urlread('http://paulschou.com/tools/sbdart/getserver.php');
catch
	error(['You must be connected to the internet for this code work.']);
end
try
    if(debug); disp(['Query command: ' server 'cliver=1.04&' qry]); end
	dat = urlread([server 'cliver=1.04&' qry]);
catch
	try
	urlread(['http://paulschou.com/tools/sbdart/failed.php?' server]);
	catch; end;
	error(['The work server you attempted to use has not responded. ' 10 ...
		'  SBDART Server: ' server 10 10 '  Go to ' ...
		'http://paulschou.com/tools/sbdart for further information.']);
end

if(length(dat) < 4)
    error('No output generated.  Please check your inputs.')
end
    
if(debug); disp('Parsing output.'); end

% Format the output
if iout == 1
    sp = find(dat(1:40) == 10, 3); %find newlines to split on
    if nargout <= 1
        varargout = {sscanf(dat(sp(3):end),'%f',[8 inf])'};
    elseif nargout == 8
        n = sscanf(dat(sp(2):sp(3)),'%d');
        varargout = mat2cell(sscanf(dat(sp(3):end),'%f',[8 inf])',n,ones(8,1));
    end
    return
end

if iout == 5 || iout == 6
    sp = find(dat(1:40) == 10, 3); %find newlines to split on    
    d = sscanf(dat(sp(3):end),'%f');
    nphi = d(9);
    nzen = d(10);
    tot = (nphi*nzen+nphi+nzen+2+8);
    n = length(d) / tot;
    fls = [];
    ret = [];
    for m = 1:n
        st = 1+tot*(m-1);
        fls(:,m) = d(st:st+7);
        ret(:,:,m) = reshape(d(st+10+nphi+nzen:tot*m),nphi,nzen)';
    end
    if nargout <= 1
        varargout = {ret};
    elseif nargout == 11
        phi = d(9+2:10+nphi);
        zen = d(9+2+nphi:10+nphi+nzen);
        varargout = [mat2cell(fls',n,ones(8,1)), ...
            {phi}, {zen}, {ret}];
    end
    return
end

if iout == 7
    sp = find(dat(1:50) == 10,5); %find newlines to split on
    nz = sscanf(dat(sp(2):sp(3)),'%f');
    d = sscanf(dat(sp(5):end),'%f');
    nw = length(d)/(nz*5+1);
    ret = [];
    wl = [];
    for m = 1:nw
        st = 1+(nz*5+1)*(m-1);
        wl(m) = d(st);
        ret(:,:,m) = reshape(d(st+1:(nz*5+1)*m),nz,5);
    end
    if nargout <= 1
        varargout = {ret};
    elseif nargout == 6
        t = sscanf(dat(1:sp),'%d', 2);
        varargout = [{wl}, {squeeze(ret(:,1,:))},{squeeze(ret(:,2,:))},...
            {squeeze(ret(:,3,:))},{squeeze(ret(:,4,:))},{squeeze(ret(:,5,:))}];
    end
    return
end

if iout == 10 
    if nargout <= 1
        varargout = {sscanf(dat,'%f',9)'};
    elseif nargout == 9
        varargout = mat2cell(sscanf(dat,'%f',9)',1,ones(9,1));
    end
    return
end

if iout == 11
    sp = find(dat(1:40) == 10,1); %find newlines to split on
    if nargout <= 1
        varargout = {sscanf(dat(sp:end),'%f',[7 inf])'};
    elseif nargout == 8
        t = sscanf(dat(1:sp),'%d', 2);
        varargout = [{t(2)}, mat2cell(sscanf(dat(sp:end),'%f',[7 inf])',t(1),ones(7,1))];
    end
    return
end

if iout == 20 || iout == 21 || iout == 23
    d = sscanf(dat,'%f');
    nphi = d(10); %19
    nzen = d(11);
    if nargout <= 1
        varargout = {reshape(d(9+2+nphi+nzen+1:end),nphi,nzen)'};
    elseif nargout == 12
        phi = d(9+2+1:11+nphi);
        zen = d(9+2+1+nphi:11+nphi+nzen);
        varargout = [mat2cell(sscanf(dat,'%f',9)',1,ones(9,1)), ...
            {phi}, {zen}, {reshape(d(9+2+nphi+nzen+1:end),nphi,nzen)'}];
    end
    return
end

if iout == 22
%    disp(dat);
    d = sscanf(dat,'%f');
    nphi = d(1);
    nzen = d(2);
    nz = d(3);
    ffew = d(4);
    ret = reshape(d(5+nphi+nzen+4*nz:end),[nphi,nzen,nz]);
    if nargout <= 1
        varargout = {ret};
    elseif nargout == 8
        reshape(d(5+nphi+nzen:4+nphi+nzen+4*nz),4,nz);
        varargout = [ffew,d(5:4+nphi), d(5+nphi:4+nphi+nzen), ...
            d(5+nphi+nzen:4+nphi+nzen+1*nz), ...
            d(5+nphi+nzen+nz:4+nphi+nzen+2*nz), ...
            d(5+nphi+nzen+2*nz:4+nphi+nzen+3*nz), ...
            d(5+nphi+nzen+3*nz:4+nphi+nzen+4*nz), ...
            {ret}];
    end
    return
end

if(debug); disp('No iout type matched dataset.  Dumping result.'); end

disp(dat)


