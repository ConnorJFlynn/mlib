% Markitup roadmap   

% So far, so good.  But need to keep in mind option of viewing QC plots
% before deciding whether to roll data in, retain the prospect of removing
% flags/events, and re-initialize QC back to some earlier state.

% Maybe include labels for the QC flags as tick labels so they'll zoom
% appropriately.

button = nflags;
if nflags==1
    color(1,:)= [0,1,0];
    color(2,:) =[1,0,0];
else
    figure
    color = get_colors([1:nflags]);
    close(gcf)
    color(end+1,:) = [0,0,0];
end
syms = ['o','x','+','*','s','d','v','^','<','>','p','h'];





% OK, what are we trying to do?  
   % For the primary field being assessed we'll have two sets of figure windows.
   % One set has two figures with linked x-axes
   %     The first shows all originally supplied data with color coding.
   %     The second is a QA color image (generated from "condition")
   
   % Second set has N-figures with linked x-axes
   %     The first shows only non-bad values of primary with yellow, blue, cyan,
   %     green, and maybe bright green for indet, noted, noted&indet, not
   %     (noted or indet), re-good
   %     Arbitrary number of other aux plots from this or other DS
   
   % One showing only non-bad values.
   % Another showing all originally supplied data values with 
   % color coding as follows
   % for each flag: bad, suspect, notable
   % first plot all non-missing as green dots or solid circles
   % next plot all non-missing and non-bad as yellow dots or solid circles
   % next plot all bad as red or gray dots or solid circles
   % lastly plot all notables as blue circles.
   % And another showing the QC color image with black for missing, red for
   % bad, yellow for suspect, cyan for notable but suspect, blue for suspect
   % and not bad or suspect, and green for not bad, suspect, or notable,
   % and maybe bright green for mentor-reassigned good.
   
   % Incoming QC info is rolled up into bad (and cast to missing), indet,
   % notable, re-assigned good.  
   % Then this is potentially augmented with QC from other fields (rolled
   % into these same categories), QC from DQRs, and mentor-defined flags
   % and marks. 
   % Each mentor defined flag needs assessments of bad, indet, notable
   % Possibly will support re-good which will clear incoming indet states

   % The user may also specify an arbitrary number of auxiliary plots, each
   % containing one or more traces from any loaded datastream.
   % Zooming into these plots and then selecting defined flags will permit
   % mentor assessment.  
   % Possible approach: If zooming into the primary assessed field, then
   % the QC is assigned to that field only, but if zooming into an aux
   % window then QC is applied for all fields. 
   % How to do the selecting?  
   %  1. Define flag mode ([toggle], set, clear)
   %  2. Define selection mode ([inside], outside, before, during, after, above, between, below)
   %  3. Select the desired flag. (With flag mode of toggle, two clicks on
   %  flag will act like undo.)
   
   % Operationally, the user will supply QA for a given field until
   % satisfied.  Then they can export the QA for the primary field and if
   % desired any others in the datastream as mark files.
   % At any point, the user may opt to change to another field from any DS, existng or new.
   % They will be prompted to output the current QA.
   
   % Current primary displays are preserved and will be regenerated if the
   % user deletes them. Aux displays are not preserved and may be deleted
   % or added at will.
   
   % Data from datastreams are copied into figure-specific structures so
   % can be deleted to free space.  Similarly, the displayed x-limits of
   % the current figure can be used to trim the datastreams and figure data
   % sets. 
   
   %main operational menus:
   % SETUP:
   %   0. Select datastream(s)
    % This is identified by a unique path different than existing 
    % When selecting, if multiple files are selected load them.  If a
    % single file is selected prompt whether to load all files in dir.
   %   1. Identify primary field
    % If the returned field is different than the current field then 
    % prompt to save existing QA, generate/define new initial QA, and 
    % regenerate primary and secondary figures
   %   2. New aux figure
    % Opens a new figure window and brings up field selector menu to select
    % field to be plotted. Clean up figure list.
   %   3. Add plot to selected aux figure.
    % Not sure about this option. Might instead just have button for
    % selecting field.  
   %   4. Define flag: label and assessment
   %   5. Define mark
   %   6. Import DQR (used for iniital time range and assessment, but applied to
   %   current primary field irrespective if listed)
   %   7. Export QA to marks (select from list of flags/marks or all)
   %   8. Export as DQR (by QA states "Bad", "Suspect","Noted/transparent")   
   %   9. Save configuration (datastreams, primary fields, aux plots,
   %   flags, marks)
   %   10. Review {field name}
   % Assess:
   %  1. Setup figs and menus
   %  2. Select timeframe: years, mmm, doys, hs, ii, or dynamic
   %  3. Flag mode: TOGGLE/set/clear
   %  4. Selection mode: INSIDE, outside, before, during, after, above, between, below
   %  5. Mentor BAD
   %  6. Mentor Suspect
   %  7. Mentor Noted
   %  8. Mentor deemed GOOD (overrides BAD and Suspect flags)
      
   % any element that has a "bad" flag will be colored red or black.
   % any element that has no
   % For primary figure, allow 1 primary field color data values initially
   % as grey dots, then overlay with ~bad as yellow, then ~bad | 