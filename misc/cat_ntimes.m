function this = cat_ntimes(this,that,this_time, that_time);
% this = cat_ntimes(this,that);
% Concatenates n-level time-series structures along the time
% coordinate dimension.


flds = fieldnames(that);
if ~exist('this_time', 'var')&&~exist('that_time', 'var')&&isfield(this,'time')&&isfield(that,'time')
   this_time = this.time;
   that_time = that.time;
end

if size(this_time,1)==1
   [the_times,ii] = unique([this_time, that_time]);
else
   [the_times,ii] = unique([this_time; that_time]);
end

if isfield(this,'fname')
    if ~isfield(this,'file_num')
        this.file_num = ones(size(this_time));
        fname = this.fname;
        this = rmfield(this,'fname');
        this.fname(1) = {fname};
        this.start_time = this_time(1);
        this.end_time = this_time(end);
    end
    this.fname(length(this.fname)+1) = {that.fname};
    that.file_num = ones(size(that_time)).*length(this.fname);
    this.start_time(end+1) = that_time(1);
    this.end_time(end+1) = that_time(end);
end
flds = fieldnames(that); % Now with 'file_num' included
for f = length(flds):-1:1
    if isstruct(this.(flds{f}))
        this.(flds{f}) = cat_ntimes(this.(flds{f}), that.(flds{f}), this_time, that_time); 
    else
               catdim = find(size(this.(flds{f}))==length(this_time)&size(that.(flds{f}))==length(that_time));               
            if catdim ==1
                [this_data,NSHIFTS] = shiftdim(this.(flds{f}),catdim-1);
                [that_data,NSHIFTS] = shiftdim(that.(flds{f}),catdim-1);
                this_data = [this_data; that_data];
                this.(flds{f}) = this_data(ii,:);
                this.(flds{f}) = shiftdim(this.(flds{f}),NSHIFTS);
            elseif catdim > 1
                [this_data,NSHIFTS] = shiftdim(this.(flds{f}),catdim-1);
                [that_data,NSHIFTS] = shiftdim(that.(flds{f}),catdim-1);
                this_data = [this_data; that_data];
                this.(flds{f}) = this_data(ii,:);
                this.(flds{f}) = shiftdim(this.(flds{f}),NSHIFTS);
            else
                % Not a time-series field.  Test to see if same in both
                % files.  If not, then concat 
            end
    end
end
return