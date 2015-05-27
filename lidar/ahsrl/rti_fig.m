function rti_fig(data,times,yext,cscale,title_str,units_str,type,fig,mask) 
%rti_fig(data,times,ylimValues,cscale,title_str,units_str,type,fig,[mask]) 
%rti_fig plots an rti image from a two-dimensional array.
%
%data      = two dimensional array of data
%times     = times(nshots), this array supplied in the form of matlab datenums.
%yext      = altitude limits in meters, for example: [0 15000], or
%            altitudes for each vertical record in meters
%type      = 'li'   general linear image      
%          = 'gg'   general log image
%          = 'wn'   AERI wave number plot
%          = 'cl'   discrete classes
%title_str = a string which will appear in figure title bar.
%units_str = a string which will appear under figure color bar.
%            when type = 'cl', units_str=a cellstr of class names
%                            eg units_str={'rain','cloud','cirrus'}
%mask    = optional mask array which is the same size as the data array.
%          points with mask==0 are plotted in grey scale 
%cscale  = color scale limits,  [climit_low climit_hi]
%           if cscale has more than two elements:
%                      climit_low=cscale(1), climit_hi=cscale(length(cscale))
%                      and ytics=cscale,  where ytics are the tick values
%                      on the color bar. 
%           when type = 'cl' climits is a color map
%                     with r g and b values for each discrete level
%                     ie   cscale(:,3)=cmap(1:n_levels,3)
%fig     = figure number if scalar, if vector is supplied
%        = [1 5 2 3] selects figure(1) and invokes subplot to draw in 
%          the 3rd plot of a 5 by 2 array of subplots in figure(1).
%
%
%usage example:
%title_str='Lidar backscatter cross section';
%units_str='1/(m sr)'
%rti_fig(data_array,time_nums,[0 12000],[1e-7 1e-3],title_str,units_str,'gg',1);
%creates a logrithmic rti for altitudes between 0 and 12km of 'data_array(times,altitudes)'
%The color bar extends from 1e-7 to 1e-3 and the data is plotted in figure(1).
%Most applications use mode 'gg' or 'li' to plot logrithmic or linear data.
%usage example tto plot:
%rti_fig(data_array,time_nums,[0 12000],[1 0 0;0 1 0;0 0 1],{'class1','class2','class3'}...
%           ,title_str,'cl',1)
%creates a plot of discrete classes labeled 'class1','class2' and 'class3' on the
%color bar that are colored red, green, and blue respectively.  Each point in the
%data array with a value of 1 is plotted in red and each point with a
%value of 2 is plotted in green and each point with a value of three is
%plotted in red. NaN's or zeros are colored gray.

%(c) 2007 Ed Eloranta, University of Wisconsin Lidar Group, Madison, Wisconsin

%plot type 'lg' is obsolete 
if nargin==9
  masked_plot=1;
else
  masked_plot=0;
end
grayscale=0;
min_alt=0;

if isstruct(times)
  sxvals=times.xaxis;
  sxformat=times.xformat;
  sxlabel=times.xlabel;
  times=times.times;
  usealtx=true;
else
  usealtx=false;
end

if prod(size(yext))==1
  ymax=yext;
  ymin=0;
else %if prod(size(yext))==2
  ymax=yext(length(yext));
  ymin=yext(1);
end
nshots=length(times);
nbins=prod(size(data))/nshots;
first_time=times(1);
last_time=times(nshots);

figure(fig(1));
if length(fig)>1;
  subplot(fig(2),fig(3),fig(4))
end;

set(gcf,'Name',title_str);
min_alt=0;
%date_nums in days to seconds
elapsed_plot_time=abs(last_time-first_time)*3600*24;

if ~isempty(cscale)
  if length(cscale)>2 & ~strcmp(type,'cl')
    ytics=cscale;
    cscale=[cscale(1) cscale(length(cscale))];
  end
      
  if strcmp(type,'li') || strcmp(type,'wn')  %general linear data transformation
    data=(63*(data-cscale(1))/(cscale(2)-cscale(1)))';
   data(data>63)=62; %clip data to range of colormap
   data(data<2)=2;
   if strcmp(type,'wn')
     clf;
   end
  elseif strcmp(type,'gg') 
    originalScale=cscale;
    B=log(10)*61/(log(cscale(2))-log(cscale(1)));
    A=1-B*log(cscale(1))/log(10);
    data(data<cscale(1))=1e-50;
    cscale(1:2)=[A B];
    data=A+B*log(data')/log(10);   
    data(data>63)=62; 
    data(data<2)=2;
    %data(isnan(data))=63;
    %data(~isfinite(data))=1;  %set all nan's to 1;
  elseif strcmp(type,'cl')
    n_classes=max(size(units_str));
    dy=round(64/(n_classes));
    data=data'*dy;
    data(data==0)=2;
  end;
end

if masked_plot
  mask=~mask';
  temp=zeros(size(mask));
  temp(mask==0)=floor(data(mask==0))+mod(data(mask==0),2);
  temp(mask==1)=floor(data(mask==1))+mod(data(mask==1),2)+1;
  data=temp;
 end

h_bs_image=image(data);
aspectratio=2;
imagefig=gcf;
if length(fig)==1
  figPos=get(imagefig,'Position');
  newPos = [figPos(1) figPos(2) figPos(4)*aspectratio figPos(4)];
  set(imagefig, 'Position', newPos);
end
rtifig_a=gca;
set(gca, 'YDir', 'Normal');
get(gca,'YTickLabel');
get(gca,'XTickLabel');
set(gca,'YTickMode','manual','YTickLabelMode','manual',...
	'XTickMode','manual','XTickLabelMode','manual');
if length(yext)>2
  if strcmp(type,'wn')
    sep=100;
    form='%6i';
    div=1;
  else
    if (yext(length(yext))-yext(1))>6000
     sep=1;
    elseif (yext(length(yext))-yext(1))>2000
      sep=0.5;
    else
      sep=0.2;
    end
    
    form='%.1f';
    div=1000;
  end
  nyext=yext./div;
  ymax=max(nyext);
  ymin=min(nyext);
  ymin=ymin-mod(ymin,sep);
  ys=[ymin:sep:ymax];
  labelIndexAxis('y',nyext,ys,@num2str,form);
else
  ydiffm=ymax-ymin;
  ydiff=ydiffm/1000;
  %if 1
  if nbins>50
    if ydiff>4
      Ytick=[0:floor(ydiff)]*nbins/ydiff;%every km
    else
      Ytick=[0:floor(ydiff*5)]*nbins/(ydiff*5);%every .2km
    end
   
    set(gca,'YTickMode','manual','YTick',Ytick);
    YTickNum=(round((Ytick*ydiffm)/nbins+ymin)/1000);
    YTickStr=num2str(YTickNum(:),'%.1f');
    
  
  else
    Ytick=get(gca,'YTick');
    YtickLabel=get(gca,'YTickLabel'); 
    YTickNum=(round((str2num(YtickLabel)*ydiffm)/nbins+ymin)/1000);
    YTickStr=num2str(YTickNum,'%3.1f');
  end
 
  if strcmp(type,'wn')
    YTickNum=round(YTickNum*10)*100;
    YTickStr=num2str(YTickNum(:),'%6i');
  end
  set(gca,'YTickLabelMode','manual','YTickLabel', YTickStr);
end


if usealtx
  sxm=find(isfinite(sxvals));
  %sumdiff=sum(abs(diff(sxvals(sxm))))
  sxvc=length(sxvals);
  sxfirst=sxvals(sxm(1));
  sxlast=sxvals(sxm(length(sxm)));
  lindiff=sxlast-sxfirst
  %if sumdiff~=abs(lindiff)
  %  fprintf('axis isn''t one-to-one\n');
  %end
  stp=lindiff/20;
  %stp=median(abs(diff(sxvals(sxm))));
  %stp=stp*(length(sxm)/10);
  stl=log(abs(stp));
  stl5=stl/log(5);
  stl10=stl/log(10);
  if abs(round(stl5)-stl5)<abs(round(stl10)-stl10)
    stp=sign(stp)*10^(round(stl10));
  else
    stp=sign(stp)*5^(round(stl5));
  end
  sxdisp=[(sxfirst-mod(sxfirst,stp)):stp:(sxlast-mod(sxlast,stp)+stp)]
  labelIndexAxis('x',sxvals,sxdisp,@num2str,sxformat);
  xlabel(sxlabel);
else
%spacing between x tick marks in minutes
start_hour_ticks=6;
st='HH:MM';
dfunc=@stripDateStr;
if elapsed_plot_time/3600 <= 0.15
  n_minutes=1;
elseif elapsed_plot_time/3600 <=.3  
  n_minutes=2;
elseif elapsed_plot_time/3600 <= .6
  n_minutes=5;
elseif elapsed_plot_time/3600 <=1.5
  n_minutes=10;
elseif elapsed_plot_time/3600 <=3
  n_minutes=20;
elseif elapsed_plot_time/3600 <=start_hour_ticks
  n_minutes=30;
elseif elapsed_plot_time/3600 <48
  n_minutes=60;
  st='HH';
  dfunc=@hourStr;
else
  n_minutes=60*24;
  st='DD';
  dfunc=@dayStr;
end
if 1
  nm=n_minutes/(60*24)*sign(last_time-first_time);
  if length(fig)==1 | fig(2)==2 | ( fig(4)>((fig(2)-1)*fig(3)))
    shot_times=(first_time-mod(first_time,nm)):nm: ...
        (last_time-mod(last_time,-nm));
  else
    shot_times=[];
  end
  try %Don't label if times are not distinct
   labelIndexAxis('x',times,shot_times,dfunc,st);
  catch
    %times-times(1)
    shot_times-times(1)
    for f=1:length(shot_times)
      feval(dfunc,shot_times(f),st)
    end
    %st
    fprintf('\n\n**************Warning times are not distinct--rti_fig line 249 **********\n\n');
    le=lasterror;
    fprintf('***** failed on message: %s\n',le.message);
    for n = 1:length(le.stack)
      fprintf('STACK %i %s:%s line %i\n',n,le.stack(n).file, ...
              le.stack(n).name, le.stack(n).line);
    end
  end
  
else

if nshots<50 %for small number of xpixels
             %elapsed_plot_time
    if elapsed_plot_time >3600/4
      date_format=15;
    else
      date_format=13;
    end;
    tick_delta=ceil(nshots/5);
    xtick_pixels=1:tick_delta:nshots;
    nticks=length(xtick_pixels);
    xticklabel(1:nticks,:)=datestr(times(xtick_pixels),date_format);	  
else  
    shot_dv=datevec(first_time:(last_time-first_time)/(length(times)-1):last_time);
    if elapsed_plot_time/3600 <=start_hour_ticks    
      shot_dv(:,5)=n_minutes*floor(shot_dv(:,5)/n_minutes);
      shot_dv(:,6)=0;
    elseif elapsed_plot_time/3600 <=48
      shot_dv(:,5:6)=0; %set seconds and minutes to zero
    else
      shot_dv(:,4:6)=0; %set hours minutes and seconds to zero
    end;  
    
    tempdn=abs(diff(sort(datenum(shot_dv))))>1e-6;
    pixels=1:length(tempdn);
    xtick_pixels=pixels(tempdn);
    
    [jnk,nxticks]=size(xtick_pixels);
    if nxticks >1  %no labels for periods of < 1 min     
      if xtick_pixels(1)==1  %don't allow xtick on first pixel
        xtick_pixels=xtick_pixels(:,2:nxticks);
        nxticks=nxticks-1;
      end;
      
      [jnk,nxticks]=size(xtick_pixels);
      for i=1:nxticks
        if elapsed_plot_time/3600 <10
          xticklabel(i,:)=sprintf('%2i:%02i', ...
                                  shot_dv(xtick_pixels(i)+1,4:5)');
        elseif elapsed_plot_time/3600 <48
          xticklabel(i,:)=sprintf('%2i',shot_dv(xtick_pixels(i)+1, ...
                                                4)');
          if (elapsed_plot_time/3600 >15) & (floor(i/3)*3 ~=i)
            xticklabel(i,:)=' ';  %blank all ticks not evenly div by 3
          end;  
        else
          xticklabel(i,:)=sprintf('%2i',shot_dv(xtick_pixels(i)+1, ...
                                                3)');
        end;
      end;  
    else
      xtick_pixels=[];
      xticklabel=' ';
    end
end % end of nshots is small number


  %suppress XTick times if more than two plots are requested
  if length(fig)==1 | fig(2)==2 | ( fig(4)>((fig(2)-1)*fig(3)))
    set(gca,'XTickMode','manual','XTickLabelMode','manual','XTick',xtick_pixels,'XTickLabel',xticklabel);
  else
    xticklabel=[]';
    set(gca,'XTickMode','manual','XTickLabelMode','manual','XTick',xtick_pixels,'XTickLabel',xticklabel);
  end;
end



  %suppress time xlabel on upper panels of multiple panel plots	
  if length(fig)==1 | (fig(4)>(fig(2)-1)*fig(3))
    if elapsed_plot_time/3600<48
      xlabel('Time (UT)');
    else
      xlabel('Day of month');
    end
  else
    xlabel(' ');
  end

end
  
  wax=gca;
  if length(fig)==1 | fig(4)==1 | fig(4)==fig(3)+1| fig(4)==fig(3)*2+1| ...
	fig(4)==fig(3)*3+1 
    if strcmp(type,'wn')
      ylabel('WaveNumber');
    else
      ylabel('Altitude (km)');
    end
  end
  

  grid

  title(title_str);
  
  if strcmp(type,'wn')
    fff=gca;
    
    hcpos=get(rtifig_a,'position');
    set(rtifig_a,'position',[hcpos(1) hcpos(2) hcpos(3)*.9 ...
                    hcpos(4)]);        
         
    axes(fff);
  end

  if 1% length(fig)==1 || (fig(2)*fig(3)==1)
  if ~strcmp(type,'cl')
    if grayscale==1
      colormap gray
    else
      colormap default
    end;	

    map=colormap;
    map(1,1:3)=0;
    if strcmp(type,'gg') 
      map(2,1:3)=.3;
    end
    %fprintf('will colormap\n');
    %pause
    colormap(map);
 end
 if masked_plot
    colormap gray;
    graymap=colormap;
    mask_index=3:2:63;
    map(mask_index,1:3)=graymap(mask_index,1:3);
    colormap(map);
 end
 end

  if ~isempty(cscale)
    A=cscale(1);
    B=cscale(2);
    oldgca=gca;
    hc21=colorbar;
    set(hc21,'YTickMode','manual','YTickLabelMode','manual',...
	     'XTickMode','manual','XTickLabelMode','manual',...
	     'XTick',[.5],'XTickLabel',units_str,'XLimMode','manual','YLimMode','manual');
 
    
    if strcmp(type,'li') || strcmp(type,'wn')
       power_of_ten=log(cscale(2)-cscale(1))/log(10);
       frac=ceil(power_of_ten)-power_of_ten;
       power_of_ten=ceil(power_of_ten);
       if frac >=log(5)/log(10);
         ytic_vals=(-100:100)/50;
       elseif frac >=log(2)/log(10);
         ytic_vals=(-100:100)/20;
       else	 
         ytic_vals=(-100:100)/10;
       end
       ytic_vals=ytic_vals'*10^power_of_ten;
       ytics=63*(ytic_vals-cscale(1))/(cscale(2)-cscale(1));
       yticklabel=num2str(ytic_vals);
       set(hc21,'YTickMode','manual','YTickLabelMode','manual','XTickMode','manual','YTick',ytics','YTickLabel',yticklabel,'XTick',[ .5]);
       if strcmp(type,'wn')
          hcpos=get(hc21,'position');
         set(hc21,'position',[hcpos(1)+4*hcpos(3) hcpos(2) hcpos(3) ...
                    hcpos(4)]);
       end
    elseif strcmp(type,'lg') || strcmp(type,'gg' ) 
      if ~exist('ytics','var')
        

        if originalScale(2)/originalScale(1) <1001
          ytics=[1e-14;1e-13;1e-12;1e-11;1e-10;1e-9;2e-9;5e-9;1e-8;2e-8;5e-8...
	         ;1e-7;2e-7;5e-7;1e-6;2e-6;5e-6;1e-5;2e-5;5e-5;1e-4...
		 ;2e-4;5e-4;1e-3;2e-3;5e-3;1e-2;2e-2...
		 ;5e-2;1e-1;2e-1;5e-1;1;2;5;10;20;50 ...
	         ;100; 200;500;1e3;2e3;5e3; 1e4];
	
	  offs=0;
	else
	  ytics=[1e-14;1e-13;1e-12;1e-11;1e-10;1e-9;1e-8;...
	       1e-7;1e-6;1e-5;1e-4;1e-3;1e-2;1e-1;1;10; ...
	       100;1e3; 1e4;1e5;1e6];
	
	  offs=0;
	end
	
	
      else
	offs=ytics(1);
      end
      yticklabel=cellstr(num2str(ytics,'%-10.0e'));
      yticklabel=strrep(yticklabel,'e-0','e-');%preceeding negative 0
      yticklabel=strrep(yticklabel,'e+','e');%preceeding +
      yticklabel=strrep(yticklabel,'e0','e');%preceeding 0
      yticklabel=strrep(yticklabel,'e0','');% is e0 -> 0's
      yticklabel=strrep(yticklabel,'e1','0');% is e1 -> 10's
      
      %yticklabel={'1e-14';'1e-13';'1e-12';'1e-11';'1e-10';'1e-9';'1e-8';...
      %	'1e-7';'1e-6';'1e-5';'1e-4';'1e-3';'1e-2';'1e-1';'1';sprintf(;'10';'50';'100'};
      ytics=A+B*log(ytics)/log(10);
      %fprintf('setting colorbar ticks for mode %s\n',type);
      l=get(hc21,'YLim');
      ytm=(ytics>l(1))&(ytics<l(2));
      ytics=ytics(ytm);
      yticklabel=yticklabel(ytm);
      set(hc21,'YTickMode','manual','YTickLabelMode','manual','XTickMode','manual','YTick',ytics','YTickLabel',yticklabel,'XTick',[ ...
	  .5]);
      %fprintf('set ticks\n');
      %get(hc21)
      %pause
   elseif strcmp(type,'cl')
       hc21=colorbar;
       yticklabel=[];
       ytick=round(dy/2):dy:64;
       for i=1:64
         cmap(i,1:3)=cscale(min(n_classes,ceil(i/dy)),:);
       end
       cmap(1:2,1:3)=[0 0 0;.3 .3 .3];    
   
       colormap(cmap);
       
       set(hc21,'YTickMode','manual','YTick',ytick); 
       
       yticklabel=units_str;
       set(hc21,'YTickLabelMode','manual','YTickLabel',yticklabel);
       
    else
      fprintf('Invalid image type--type = %s is unknown\n',type)
    end

    
    
    axes(oldgca)
    %   set(hc21,'XTickMode','manual','XTickLabelMode','manual',...
    %	      'XTick',[.5],'XTickLabel',units_str);
  end
 if strcmp(type,'wn')
 addRightAxes(wax,'WaveLength (\mum)',@wn2wl);
 end
 
 %fprintf('done rti_fig\n');
 
function addRightAxes(ax,label,xlfunc)
ca=gca;
axes(ax);
  set(gca,'YTickMode','manual','YLimMode','manual');
  yticc=get(gca,'Yticklabel');
  ytic=[];
  for i=[1:length(yticc)];
    ytic(i)=str2num(yticc{i});
  end
  yv=get(gca,'YTick');
  yl=get(gca,'YLim');
  ym=find(yv<=yl(2) & yv>=yl(1));
  ytic=ytic(ym);
  ytickvals=feval(xlfunc,ytic);
  nlabels=length(ytickvals);
  if 1
    ax=axis;
    %add mJ axis on right
    ax1=gca;
    hold on
    ax3=axes('Position',get(ax1,'Position'),'YAxisLocation','right'...
	     , 'XAxisLocation','top','Color','none','XTickMode','manual','xtick',[],'TickLength',[0,0]);
    set(ax3,'YTickMode','manual','YLimMode','manual','YTick',yv(ym),'YLim',yl,'YTickLabelMode','manual','YTickLabel',num2str(ytickvals,'%.1f'))
  else
    strs=num2str(ytickvals,'%.1f');
    xl=get(gca,'xlim');
    strs
    yvm=yv(ym);
    for r=1:nlabels
      h=text(xl(2),yvm(r),strs(r),'HorizontalAlignment','center',...
	     'verticalalignment','middle','margin',2);
      get(h)
    end
  end
  ylabel(label);
  axes(ca);
return
 

function wl=wn2wl(wn)
wn(:);
wl=10000.0./wn(:);
return

%dispfunc takes 2 parameters: the displayvalue and the parm given
function labelIndexAxis(ax,indexvals,displayvals,dispfunc,dispfuncparm)
set(gca,[ax 'TickMode'],'manual',[ax 'TickLabelMode'],'manual');
  xi=[1:length(indexvals)];
  xi=xi(isfinite(indexvals));
  useivals=indexvals(isfinite(indexvals));
  %diff(useivals)<=0
  imask=logical([1 ; shiftdim(diff(useivals)>0)]);
  xi=xi(imask);
  useivals=useivals(imask);
  xdi=interp1(useivals,xi,displayvals);
  displayvals=displayvals(isfinite(xdi));
  xdi=xdi(isfinite(xdi));
  if 1
    %length(indexvals)
    %xdi
    %displayvals
  oldfilt=logical(ones(size(xdi)));
  filt=oldfilt;
  while true
    %diff(xdi(oldfilt))
    filts=logical([1,diff(xdi(oldfilt))>(length(indexvals)/20)]);
    filt(:)=0;
    ofi=find(oldfilt);
    filt(ofi)=filts;
    %filt
    %oldfilt
    if sum(oldfilt~=filt)==0
      break;
    end
    for i=[2:(length(ofi)-1)]
      if ~filt(ofi(i-1)) && ~filt(ofi(i)) && ~filt(ofi(i+1))
        filt(ofi(i))=true;
      end
    end
    oldfilt=filt;
  end
  xdi=xdi(oldfilt);
  displayvals=displayvals(oldfilt);
  end
  xs={};
  for i=[1:length(displayvals)]
    xs={xs{:} feval(dispfunc,displayvals(i),dispfuncparm)};
  end
  set(gca,[ax 'Tick'],xdi);
  set(gca,[ax 'TickLabel'],xs);
return

function r=dayStr(a,b)
v=datevec(a);
dv=v(3);
if v(4)>=12
  dv=dv+1;
end
r=sprintf('%i',dv);
return

function r=hourStr(a,b)
v=mod(round(datenum(datevec(a))*24),24);
r=sprintf('%i',v);
return

function r=stripDateStr(a,b)
r=datestr(a,b);
if r(1)=='0'
  r=r(2:length(r));
end
return
