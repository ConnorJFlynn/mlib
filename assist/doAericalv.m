% $Id: doAericalv.m,v 1.1 2012/10/06 20:02:45 dataman Exp $
function [Lsky,response,ratio,wtH1,wtC1,wtH2,wtC2,TimeLsky] = doAericalv(...
  cxvf,cxvb,chNo,filetype,...
  cavfactor,Th,Tc,Ta,flagBBwtErr,imodelBBE,flagVerbose)
%
% function [Lsky,response,ratio,wtH1,wtC1,wtH2,wtC2] = doAericalv(...
%   cxvf,cxvb,chNo,filetype,...
%   cavfactor,Th,Tc,Ta,flagBBwtErr,imodelBBE,flagVerbose)
%
% Purpose: To perform the same steps as done in "AERICALV" for the PAERI processing
% 
% Input variables
%
%   cxvf,cxvb:   structured array for uncalibrated spectra
%   chNo:        channel number (1 or 2)
%   filetype:    CXV for channel 1 (nlapp applied), CXS for channel 2
%   cavfactor:   Blackbody cavity factor
%   Th,Tc:       calibration temps for hot blackbody and cold blackbody
%   Ta:          "Ambient" temperature, as measured on instrument somewhere
%   flagBBwtErr: 0 (no error in weighting of bbs), 1 (first error)
%   imodelBBE:   0 (old BBE model), 9 (new BBE model)
%   flagVerbose: 0 => little/no output, 1=> output messages to screen
%
% Output variables (where d='f' or 'b')
%   Lsky.f/b:     Calibrated radiance, = rlc files "atmosphericRadiance."
%   response.f/b:	Instrument response, (Ch-Cc)/(Bh-Bc)
%   ratio.f/b:    Ratio, (Cs-Cc) / (Ch-Cc)
%   wtH1, wtH2:   Weights for uncalibrated HBB spectra before and after sky
%   wtC1, wtC2:   Weights for uncalibrated HBB spectra before and after sky
%
% updates (9 Dec. 2009):
%   Removed "abs" from uncalibrated blackbody spectrum weights (around lines 105 and 113) so that
%     the weights will be normalized (sum to one) even when one is negative.  
%     Note that this error, due to incorrect times in the cxvf file, needs to be fixed!
%   Converted time variables to double for calculation of blackbody weights to that they normalize
%     to within 1e-13.
%   Added warnings for hot and cold blackbody weights if not normalized to 1e-13.
%
% by Penny M. Rowe
% prowe@harbornet.com
%



% Variables that do not change with nu or you can do once
nup       = cxvf.wnum1;

for mirdir=1:2
  if mirdir==1
    cxv = cxvf;
    Smirdir='Forward';
    d='f';
  elseif mirdir==2
    cxv = cxvb;
    Smirdir='Backward';
    d='b';
  end
  
  % Get info from cxv file
  if strcmpi(filetype,'cxv')
    C.(d)    = cxv.RealPartCounts +1i*cxv.ImagPartCounts ;
  elseif strcmpi(filetype,'cxs')
    C.(d)  = cxv.(['Ch' num2str(chNo) Smirdir 'ScanRealPartCounts'])+...
      1i*cxv.(['Ch' num2str(chNo) Smirdir 'ScanImagPartCounts']);    
  end
end

% Get indices to cxv for sky, hot, and cold scenes
iskiesAll = find(cxvf.sceneMirrorAngle~=120 & cxvf.sceneMirrorAngle~=60);
ihots     = find(cxvf.sceneMirrorAngle==60);
icolds    = find(cxvf.sceneMirrorAngle==120);

% Sometimes the last spectrum is missing from HBB etc vectors
if length(Th) < length(iskiesAll)
  iskiesAll = iskiesAll(1:length(Th));
end

% Get Times
if sum(cxvf.Time(iskiesAll)-cxvb.Time(iskiesAll))~=0
  error('I was expecting cxvf and cxvb to have same times for same sky spectra.');
end
TimeLsky = cxvf.Time(iskiesAll) ;

% Get dimensions
Nskies = length(iskiesAll);
Nnus   = length(nup);

% Initialize weights
wtH1 = zeros(1,Nskies);
wtH2 = zeros(1,Nskies);
wtC1 = zeros(1,Nskies);
wtC2 = zeros(1,Nskies);

% Loop over indices to sky views in set of calibrated sky spectra
if flagVerbose
  fprintf(1,'Performing matlab AERIcalv: Percent complete: ');
  pcento=0;
  alldone=0;
end
for mirdir=1:2
  if mirdir==1
    cxv = cxvf;
    d   = 'f';
  elseif mirdir==2
    cxv = cxvb;
    d   = 'b';
  end
  
  % preallocate
  Lsky.(d)    = zeros(Nnus,Nskies);
  response.(d) = zeros(Nnus,Nskies);
  ratio.(d)    = zeros(Nnus,Nskies);
  for iskyf = 1:Nskies
    is  = iskiesAll(iskyf);   % index to cxv sky view for current
    ih  = find(ihots>is,1) ;  % index to ihots, or index to index to cxv
    ic  = find(icolds>is,1) ;
    
    ih1 = ihots(ih-1);  ih2=ihots(ih);  % indices to hbb cxv spectra
    ic1 = icolds(ic-1); ic2=icolds(ic);
    
    deltH = double(cxv.Time(ih2)-cxv.Time(ih1)) ;
    wh1 = double(cxv.Time(ih2)-cxv.Time(is)) /deltH ;
    wh2 = double(cxv.Time(is)-cxv.Time(ih1)) /deltH ;

    if abs(wh1+wh2 - 1) > 1e-13
      fprintf(['HBB weights are not normalized at index ' num2str(iskyf) '.\n'])
    end

    deltC = double(cxv.Time(ic2)-cxv.Time(ic1)) ;
    wc1 = double(cxv.Time(ic2)-cxv.Time(is))/ deltC ;
    wc2 = double(cxv.Time(is)-cxv.Time(ic1))/ deltC ;

	if abs(wc1+wc2 - 1) > 1e-13
	  fprintf(['CBB weights are not normalized at index ' num2str(iskyf) '.\n'])
	end


    %if length(find([wh1 wh2 wc1 wc2]<=0))
%	    disp([wh1 wh2 wh1+wh2 wc1 wc2 wc1+wc2]);
%            disp([cxv.Time(ih1) cxv.Time(is) cxv.Time(ih2)]);
%            pause
%    end
    
    % Save the weights
    wtH1(iskyf) = wh1 ;
    wtH2(iskyf) = wh2 ;
    
    wtC1(iskyf) = wc1 ;
    wtC2(iskyf) = wc2 ;
    %     nsech=(cxv.Time(is)-cxv.Time(ih1)) ;
    %     msech=(cxv.Time(ih2)-cxv.Time(ih1)) ;
    %     wh2 = nsech/msech;
    %     wh1 = 1-nsech/msech;
    %     nsech=(cxv.Time(is)-cxv.Time(ic1)) ;
    %     msech=(cxv.Time(ic2)-cxv.Time(ic1)) ;
    %     wc2 = nsech/msech;
    %     wc1 =1-nsech/msech;
    
    if flagBBwtErr
      % Start over if first spectrum in calibration sequence
      if is==ih1+1 || is==ic1+1
        Ch.(d)  = wh1*C.(d)(:,ih1) + wh2*C.(d)(:,ih2) ;  % AVG HBS
        Cc.(d)  = wc1*C.(d)(:,ic1) + wc2*C.(d)(:,ic2) ;  % AVG CBS
        Cho.(d) = Ch.(d) ;
        Cco.(d) = Cc.(d) ;
      else
        Ch.(d)  = wh1*Cho.(d) + wh2*C.(d)(:,ih2) ;  % AVG HBS
        Cc.(d)  = wc1*Cco.(d) + wc2*C.(d)(:,ic2) ;  % AVG CBS
        Cho.(d) = Ch.(d) ;
        Cco.(d) = Cc.(d) ;
      end
    else
      Ch.(d)  = wh1*C.(d)(:,ih1) + wh2*C.(d)(:,ih2) ;  % AVG HBS
      Cc.(d)  = wc1*C.(d)(:,ic1) + wc2*C.(d)(:,ic2) ;  % AVG CBS
    end
    
    
    % Get blackbody emissivity
    [emis,fov_emis,eh] = get_aeri_bb_emis(nup,imodelBBE,cavfactor) ;
    % imodelBBE is 9 in the new AERI processing, 0 in the old
    % Using 0 and fixing later only gives errors of 1e-5 RU
    
    
    % Compute the radiances for the various temperatures
    % I'm not sure about the original code here ...
    % Note: using Ta = Tamb(iskyf);  can account for only 0.005 RU
    b_th = 1e3*plancknu(nup,Th(iskyf));
    b_tc = 1e3*plancknu(nup,Tc(iskyf));
    b_tr = 1e3*plancknu(nup,Ta(iskyf));
    
    % Compute pseudo radiances
    Bh = eh .* b_th + (1-eh) .* b_tr ;
    Bc = eh .* b_tc + (1-eh) .* b_tr ;
    
    thisratio = ( C.(d)(:,is)-Cc.(d) ) ./ ( Ch.(d)-Cc.(d) )  ;
    
    % Make assignments that depend on mirror direction
    Lsky.(d)(:,iskyf)     = thisratio .* (Bh - Bc) + Bc ;
    response.(d)(:,iskyf)  = abs(Ch.(d)-Cc.(d))./(Bh - Bc) ;
    ratio.(d)(:,iskyf)     = thisratio  ;
    
    if flagVerbose
      
      pcent = iskyf/length(iskiesAll)*100 ;
      if pcent>=pcento+10
        fprintf([num2str(round(pcent)) ' ']);
        pcento=pcent;
      elseif iskyf==length(iskiesAll)
        alldone=alldone+1;
        if alldone==2
          fprintf([num2str(round(pcent)) '.\n']);
        end
      end
    end
    
  end
  
  
end   % of loop over mirror directions 1 and 2

