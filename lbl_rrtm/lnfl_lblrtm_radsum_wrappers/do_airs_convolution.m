function [rad_vec_out,out_chan]=do_airs_convolution(rad_vec_in,in_chan)
%function [rad_vec_out,out_chan]=do_airs_convolution(rad_vec_in,in_chan)
%
%(C) Dan Feldman 2009, all rights retained
%    Disclaimer of Warranty. DANIEL FELDMAN PROVIDES THE SOFTWARE AND THE SERVICES "AS IS" WITHOUT WARRANTY 
%    OF ANY KIND EITHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
%    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. ALL RISK OF QUALITY AND PERFORMANCE OF THE 
%    SOFTWARE OR SERVICES REMAINS WITH YOU. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL PART OF THIS AGREEMENT.
%
%    Limitation of Remedies. IN NO EVENT WILL DANIEL FELDMAN, DISTRIBUTORS, DIRECTORS OR AGENTS BE LIABLE 
%    FOR ANY INDIRECT DAMAGES OR OTHER RELIEF ARISING OUT OF YOUR USE OR INABILITY TO USE THE SOFTWARE OR 
%    SERVICES INCLUDING, BY WAY OF ILLUSTRATION AND NOT LIMITATION, LOST PROFITS, LOST BUSINESS OR LOST  
%    OPPORTUNITY, OR ANY INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL OR EXEMPLARY DAMAGES,  
%    INCLUDING LEGAL FEES, ARISING OUT OF SUCH USE OR INABILITY TO USE THE PROGRAM, EVEN IF DANIEL FELDMAN 
%    OR AN AUTHORIZED LICENSOR DEALER, DISTRIBUTOR OR SUPPLIER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES, 
%    OR FOR ANY CLAIM BY ANY OTHER PARTY. BECAUSE SOME STATES OR JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR THE  
%    LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES, IN SUCH STATES OR JURISDICTIONS, 
%    DANIEL FELDMAN'S LIABILITY SHALL BE LIMITED TO THE EXTENT PERMITTED BY LAW.
%
%    Daniel Feldman's Liability. Daniel Feldman assumes no liability hereunder for, 
%    and shall have no obligation to defend you or to pay costs, damages or attorney's fees for, 
%    any claim based upon: (i) any method or process in which the Software or Services may be used by you; 
%    (ii) any results of using the Software or Services; 
%    (iii) any use of other than a current unaltered release of the Software; or 
%    (iv) the combination, operation or use of any of the Software or Services furnished hereunder 
%    with other programs or data if such infringement would have been avoided by the combination, 
%    operation, or use of the Software or Services with other programs or data. 
%
%    If you do not agree to these terms, discontinue use of this software immediately.
%    Daniel Feldman is not affiliated with AER, Inc.
%
%This function will perform an AIRS calculation according to the
%file srftables-020818v1.hdf which is the SRF table of the AIRS
%instrument as of August 18,2002
%The srftable is located at
%http://asl.umbc.edu/pub/airs/srf/srftables-020818v1.hdf
%%%%%%%%%%%%%%%%%%%
%%Input Variables%%
%%%%%%%%%%%%%%%%%%%
%rad_vec_in  = input radiance vector 
% (any units, but standard is W/m^2/sr/cm^-1)
%in_chan     = input channels (cm^-1)
%
%%%%%%%%%%%%%%%%%%%%
%%Output Variables%%
%%%%%%%%%%%%%%%%%%%%
%rad_vec_out = output radiance vector (same units as rad_vec_in)
%out_chan    = AIRS channels (cm^-1)
%
%%%%%%%%%%%%%%%%%
%%Program notes%%
%%%%%%%%%%%%%%%%%
%1. Get airs channel limits
%2. Check monotonicity of channels, set flags,nonmonotonic areas 
%   if nonmonotonic
%3. Index-match airs channels to high-resolution channel for centers
%4. Index-match airs channels to high-resolution channel for low wing
%5. Index-match airs channels to high-resolution channel for low wing
%6. Spline channel ils to high-res grid, perform numerical convolution
%
%%%%%%%%%%%%%%%%%%%%%%
%%Internal variables%%
%%%%%%%%%%%%%%%%%%%%%%
%chan_airs = airs channels in wavenumber
%fwgrid = finite full-width grid over which srf will operate (-10:10)
%srfval = finite grid with srf values corresponding to fwgrid distance from channel center (between 0 and 1)
%width = size of full-width in wavenumbers (~0.5-1)
%chan_limits = airs channel limits
%out_width = vector of airs channel widths (from variable width) 
%start_up_index = chan_limits index to jump to after nonmonotonic event so that channels are monotonic
%loop = generic dummy variable for while loop calculations
%index = generic dummy variable to keep track of updates in while loop
%diff = generic dummy variable for index-matching
%diff_comp = generic dummy variable for index-matching
%i = generic for loop index variable
%dummy = generic dummy variable for assignment, transfer of values
%index_chan_in = variable used to parse airs channels within chan_limits so they are monotonic
%index_chan_out = same as index_chan_in
%out_chan_prime = vector used to parse out_chan
%out_width_prime = vector used to parse out_widtch
%chan_in_center = vector of high-res indices corresponding to airs channel centers
%index_hr = index used to find high-res index corresponding to airs_channel low wing
%low_wing = low wavenumber value of wing of airs channel
%chan_in_low_hr = vector of high-res indices corresponding to airs_channel low wing value
%high_wing  = high wavenumber value of wing of airs channel
%chan_in_high_hr = vector of high-res indices corresponding to airs_channel high wing value
%srf_indices = high-res indices for each airs channel convolution
%chan_srf_in = high-res wavenumbers for each airs channel convolution 
%rad_srf = high-res radiances for each airs channel convlution
%lr_srf = low-res srf as determined by fwgrid
%hr_srf = splined high-res srf as determined by chan_srf_in

s_identify = 'do_airs_convolution.m' 


try
  load('/home/drf/airs3/packages/sartaV104/Test/bin/srf_hdf.mat')
catch
  %hdf file ~4.3 megabytes
  s_url = 'http://asl.umbc.edu/pub/airs/srf/srftables-020818v1.hdf';
  
  %mirrored url =
  %http://www.gps.caltech.edu/~drf/airs_retrieval/srftables-020818v1.hdf
  
  s = strcat(['wget ',s_url]);
  system(s);
  
  [alist,fattr] = h4sdread('srftables_020818v1.hdf');
  a = alist{1,2};
  chan_airs = double(a{1,2});
  b = alist{1,3};
  fwgrid = double(b{1,2});
  c = alist{1,4};
  srfval = double(c{1,2});
  d = alist{1,5};
  width = double(d{1,2});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get AIRS band channel indices%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

chan_indices = zeros(size(chan_airs));

mult_fact = [9 11];

if min(in_chan)<650 & max(in_chan)>2664
  chan_indices = ones(size(chan_indices));
else
  min_in_chan = min(in_chan);
  max_in_chan = max(in_chan);
  for i=1:length(chan_indices)
    if chan_airs(i)>=min_in_chan+10*width(i) & ...
	  chan_airs(i)<=max_in_chan-10*width(i) 
      a = length(find(abs(chan_airs(i)-in_chan)<10*width(i)));
      if a >= 1
	chan_indices(i) = 1;
      end
    end
  end
end

index = 1;
rad_vec_out = zeros(1,sum(chan_indices));
out_chan = zeros(1,sum(chan_indices));

full_channel_flag = 0;

%get breakpoints where there is anomalous channel spacing
a = zeros(1,length(in_chan)-1);
breakpoints = zeros(size(in_chan));
lblrtm_spacing = zeros(size(in_chan));
for i=1:length(a)
  a(i) = in_chan(i+1)-in_chan(i);
  if a(i)>1
    breakpoints(i) = 1;
  end
end

dummy = a(1);
for i=1:length(lblrtm_spacing)
  lblrtm_spacing(i) = dummy;
  if breakpoints(i) == 1
    dummy = a(i+1);
  end
end

breakpoints = zeros(size(chan_airs));
chan_airs_spacing = zeros(1,length(chan_airs)-1);
for i=1:length(chan_airs_spacing)
  chan_airs_spacing(i) = chan_airs(i+1)-chan_airs(i);
  if abs(chan_airs_spacing(i))>2
    breakpoints(i) = 1;
    breakpoints(i+1) = 1;
  end
end

%get initial starting indices
start_point = 1;
chan_in_low_hr = ...
    find(abs(in_chan-chan_airs(start_point)+10*width(start_point)) ...
	 ==min(abs((in_chan-chan_airs(start_point)+10*width(start_point)))));
chan_in_high_hr = ...
    find(abs(in_chan-chan_airs(start_point)-10*width(start_point)) ...
	 ==min(abs((in_chan-chan_airs(start_point)-10*width(start_point)))));
tolerance = 2;

for i=start_point:length(chan_indices)
  if chan_indices(i) == 1
    %[i length(chan_indices)]
    clear srf_indices
    if i>1 & breakpoints(i) == 0
      %!!! approximate values
      chan_center_previous = round((chan_in_high_hr+ ...
				    chan_in_low_hr)/2);
      chan_center_next = round(chan_center_previous + ...
	  chan_airs_spacing(i-1)/lblrtm_spacing(chan_center_previous));
      
      %get range for chan_in_low_hr and chan_in_high_hr
      a_low1 = round(chan_center_next-mult_fact(2)*width(i)/ ...
		     lblrtm_spacing(chan_center_next));
      a_low2 = round(chan_center_next-mult_fact(1)*width(i)/ ...
		     lblrtm_spacing(chan_center_next));
      a_high1 = round(chan_center_next+mult_fact(1)*width(i)/ ...
		      lblrtm_spacing(chan_center_next));
      a_high2 = round(chan_center_next+mult_fact(2)*width(i)/ ...
		      lblrtm_spacing(chan_center_next));
      
      if a_low1<0
	a_low1=1;
      end
      if a_low2<0
	a_low2=1;
      end
      if a_high1>length(in_chan)
	a_high1=length(in_chan);
      end
      if a_high2>length(in_chan)
	a_high2=length(in_chan);
      end
      
      dummy = [a_low1:a_low2];
      dummy2 = zeros(size(dummy));
      for j=1:length(dummy)
	dummy2(j) = in_chan(dummy(j));
      end
      
      chan_in_low_hr = find(abs(dummy2-chan_airs(i)+10*width(i))...
			    ==min(abs((dummy2-chan_airs(i)+10*width(i)))));
      chan_in_low_hr = chan_in_low_hr + a_low1;
      
      dummy = [a_high1:a_high2];
      dummy2 = zeros(size(dummy));
      for j=1:length(dummy)
	dummy2(j) = in_chan(dummy(j));
      end
      
      chan_in_high_hr = find(abs(dummy2-chan_airs(i)-10*width(i))...
			    ==min(abs((dummy2-chan_airs(i)-10*width(i)))));
      chan_in_high_hr = chan_in_high_hr + a_high1;
      
    elseif breakpoints(i) == 1
      s = strcat('break:',int2str(i));
      disp(s)
      
      chan_in_low_hr = find(abs(in_chan-chan_airs(i)+10*width(i)) ...
			    ==min(abs((in_chan- ...
				       chan_airs(i)+10*width(i)))));
      chan_in_high_hr = find(abs(in_chan-chan_airs(i)-10*width(i)) ...
			     ==min(abs((in_chan- ...
					chan_airs(i)-10*width(i)))));
    end
    if abs(chan_airs(i)-10*width(i)-in_chan(chan_in_low_hr))>tolerance
      disp('refind indices')
      chan_in_low_hr = find(abs(in_chan-chan_airs(i)+10*width(i)) ...
			    ==min(abs((in_chan- ...
				       chan_airs(i)+10*width(i)))));
    end
    if abs(chan_airs(i)+10*width(i)-in_chan(chan_in_high_hr))>tolerance
      chan_in_high_hr = find(abs(in_chan-chan_airs(i)-10*width(i)) ...
			    ==min(abs((in_chan- ...
				       chan_airs(i)-10*width(i)))));
    end
    
    srf_indices = [chan_in_low_hr:chan_in_high_hr];
    chan_srf_in = zeros(1,length(srf_indices));
    rad_srf = zeros(1,length(srf_indices));
    lr_chan = zeros(1,length(fwgrid));
    for j=1:length(srf_indices)
      chan_srf_in(j) = in_chan(srf_indices(j));
      rad_srf(j) = rad_vec_in(srf_indices(j));
    end
    lr_chan = chan_airs(i)+fwgrid*width(i);
    
    hr_srf = extrap1(lr_chan,srfval(:,i),chan_srf_in,'nearest');
    rad_vec_out(index) = sum(hr_srf.*rad_srf)/sum(hr_srf);
    out_chan(index) = chan_airs(i);
    index = index + 1;
  end
end

