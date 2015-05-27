% Dehong Hu

ke=[-1 -1 -1 -1 -1;-1 1 1 1 -1;-1 1 8 1 -1;-1 1 1 1 -1; -1 -1 -1 -1 -1];
% ke is a 5x5 matrix with a heavy weight (8) in the center
% ke =
%     -1    -1    -1    -1    -1
%     -1     1     1     1    -1
%     -1     1     8     1    -1
%     -1     1     1     1    -1
%     -1    -1    -1    -1    -1

k1=[1 1 1;1 2 1;1 1 1];
% k1 is a smaller 3x3 array with a 2 in the center and ones elsewhere.

imageYOI=[21:400];
'y-index into image
imageXOI=[141:400];
'x-index into image
traj=[0 0 0];
trajg=[0 0 0 0];
s=[length(imageXOI) length(imageYOI)];
firstFrame=1;
lastFrame=500;
segmentSeparationPoint=fix([0:10]*(lastFrame+1-firstFrame)/10)+firstFrame;
% provides sub-divisions (segments) into the image
for segment=1:10
    segment
    % simply displays the segment number for debugging purposes.
    frameOI=[segmentSeparationPoint(segment):(segmentSeparationPoint(segment+1)-1)];
    % Generates indices ito the image sub-divisions 
    
    intensities=readspe('0310-10.spe',frameOI);
    % Must be a function he wrote to read his ".spe" format files
    % No big deal, it reads just the chunk of the .spe file defined by the
    % indices in frameOI and returns the result in "intensities"
    clear cts;
    for i=1:length(frameOI)
        cts(:,:,i)=conv2(intensities([imageXOI(1)-2:imageXOI(end)+2],[imageYOI(1)-2:imageYOI(end)+2],i),ke,'same');
        % conv2 is a 2-D convolution of the segments of "intesities" with
        % the 5x5 weighting matrix "ke".  The 'same' string indicates that
        % the size of the returned convulution is the same size as
        % "intensities"
    end
    cts=cts(3:end-2,3:end-2,:);
    % This trims off the first and last two elements of the convulution
    % results presumably to neglect edge effects 
    
    for i=1:length(frameOI)
        temp=cts(:,:,i);
        % pick-off just one convolution frame at a time into "temp" to make
        % notation easier
        % 
        intensityThreshold=std(temp(:))*3;
        % define an intensity threshold based on the standard of deviation
        % of all the elements in the selected frame.
        
        binimg=(cts(:,:,i)>intensityThreshold)&(cts(:,:,i)<50*intensityThreshold);
        % This is a nice efficient notation using logical indexing.
        % It identifies all elements of the frame that exceed the intensity
        % threshold but are less than 50 times the threshold.
        da=binimg.*cts(:,:,i);
        % This retrieves the elements identified above.
        eld=conv2(binimg,k1,'same');
        % This computes a convolution of the elements identified above, but
        % with the smaller weighting matrix k1.
        smPoint=(imregionalmax(eld)&imregionalmax(da)&binimg);
        %two calls to the function imregionalmax, which probably means
        %"image regional maximum".  I couldn't find this function listed in any of
        %Matlabs supplied toolboxes, so it must be something he wrote.  At
        %any rate, it appears to generate boolean true/false results
        %identfying any local maxima.  He is ANDing two call of
        %imreginalmax (one for the double-convoluted results "eld", one for the
        %single convoluted results "da" that pass his thresholds tests  and also
        %ANDing again with "binimg".  It's not clear to me that the third
        %AND does anything since "binimg" and "da" represent the same
        %elements, but perhaps there is a subtle difference I don't see.
        ind=find(smPoint==1);
        %This finds all "true" valus from the triple AND test above.
        x=rem(ind-1,s(1))+1;
        y=rem((ind-x)/s(1),s(2))+1;
        % These statements are cute. He's finding the location of the region maxima from smPoint 
        % in terms of the original image dimensions using the "remainder"
        % function rem(X,Y) which computes the remainder of X/Y.
        % I think this is a pretty concise way to do it.  
        x=x+imageXOI(1)-1;
        y=y+imageYOI(1)-1;
        z=x*0+frameOI(i);
        % This is a slick method of pre-sizing a result.
        % The operaton x*0 does not just return zero, it returns an array
        % of zeros the same size as x.  The variable x is location of all
        % the regional max in this segment, not just of one regional max.
        [xf yf totalcts]=getsmgaussianc(x,y,intensities(:,:,i)');
        % No idea... Looks like Get_sm_gaussian_c
        % This might be a two-dimensional Gaussian smoother.  Maybe it
        % returns the centroids and maxima of fitted gaussian contours?  
        % That might be it.
        traj=[[traj(:,1);x] [traj(:,2);y] [traj(:,3);z]];
        % This is another slick re-sizing trick.  He's pretty good.  I am
        % learning some new tricks from him. :-)  
        % Basically, x,y,and z are all the same size and denote the
        % coordiante of each of the regional maxima.  He is using the
        % starting vector traj = [0,0,0] as a template to structure the
        % output.  Then at the end he strips off the first row of zeros.
        trajg=[[trajg(:,1);xf] [trajg(:,2);yf] [trajg(:,3);z] [trajg(:,4);totalcts]];
        % Same story but both location and total counts of the gaussian
        % results are returned.
    end
end


traj=traj(2:end,:);
trajg=trajg(2:end,:);
%The above two lines strip of the initial row of zeros that were used to
%define the templates for traj and trajg.
i=find(trajg(:,4)>200);
% this finds only those indices where the gaussian total counts exceed 200.
trajc=trajg(i,:);
% this creates a subset of trajg containing only those indices with total
% counts > 200.


save('traj10','trajc')
% this saves the final result of trajc into a file named "traj10" (for 10
% segments I guess.)

% Looks like he does nit save "traj" or use it in any way.