function this = cat_timeseries(this,that);
% this = cat_timeseries(this,that);
% Accepts two time-series structures with identical fields and returns a single
% structure combining the unique records shared by either. Computationally it
% is more efficient if the structure with the larger number of records is the first
% argument but this is not required. 

% generate the collection of unique times shared by "this" or "that" 
if size(this.time,1)==1
   [the_times,ii] = unique([this.time, that.time]);
else
   [the_times,ii] = unique([this.time; that.time]);
end

flds = fieldnames(that);
init_time1 = this.time;
init_time2 = that.time;
% Try to be a little careful to preserve non-time field "fname" by
% converting them to time-dimensioned fields
if isfield(this,'fname')
    if ~isfield(this,'file_num')
        this.file_num = ones(size(this.time));
        fname = this.fname;
        this = rmfield(this,'fname');
        this.fname(1) = {fname};
        this.start_time = this.time(1);
        this.end_time = this.time(end);
    end
    this.fname(length(this.fname)+1) = {that.fname};
    that.file_num = ones(size(that.time)).*length(this.fname);
    this.start_time(end+1) = that.time(1);
    this.end_time(end+1) = that.time(end);

end
% Now step through the fields one at a time, concantenating to full length
% and then picking out the unique indices "ii" to save in "this".
flds = fieldnames(that); % Now with 'file_num' included
for f = length(flds):-1:1
               catdim = find(size(this.(flds{f}))==length(init_time1)&size(that.(flds{f}))==length(init_time2));               
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
return