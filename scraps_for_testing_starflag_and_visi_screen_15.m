% Scraps for testing starflags transition:

% John was using current "starflag" and "visi_screen_v12". 

% visi_screen_v12 incorporates better logical selection (regions,
% select_mode) but eliminates "special_fnt" since it crashed under certain
% modes and functionality existing in region and select_mode

% new "starflag_" has numerous structural changes compared to "starflag"
% It eliminates the multi-case statement
%  Loads all existing flags in starsun and starinfo by default 
%  Moves user-supplied tests into define_starflags_yyyymmdd
%  saving this "initial flagging state" to an auto-created file
%  Allows "clear" in visiscreen

% visi_screen_v12 and visi_screen_v14 numerous small changes for
% clarity and consistency.  For example:
%Replacing "screened" with "flagged_bad" and "screen" with "flag_bitmap"
% visi_screen_v14 and v15 are only cosmetically different 
% Functionally, v12, v14, and v15 should all be very similar

% Test starflag and visi_screen_v12  (John's configuration)
% Step through entirety
 
% Skipped ahead to test "starflag_" and "visi_screen_v15"

% 
% Testing starflag_ and visi_screen_v15
% 
% starflag_ outputs the initial flag state before manual interaction into:
% flags = 
%                          t: [22900x1 double]
%     before_or_after_flight: [22900x1 logical]
%                    bad_aod: [22900x1 logical]
%                      frost: []
%         unspecified_clouds: [22900x1 logical]
%                  low_cloud: []
%                     cirrus: []
%                      smoke: []
%                       dust: []
%                   hor_legs: []
%                     spiral: []
%                flag_struct: [1x1 struct]
%                   flagfile: '20160530_starflag_auto_created_20160707_1821.mat'
% 
% flag_struct contains:
% 	flag_names {cell array of strings identifying all flags} 
% 	flag_noted {cell array of strings identifying 'not_grayed' flags}
% 	flag_suspect {cell array of strings identifying 'suspect' flags}
% 	flag_event {cell array of strings identifying 'events'}
% 	flag_str = {cell array of strings from set_flag_yyyymmdd function}
% 	
% As we exit visi_screen_v15 we have:
% flags_matio:
%             flag_bitmap: [22900x1 uint32]  (replaces "screen")                                                                             
%                flagfile: [1x51    char]                                                                                   
%             flagged_bad: [22900x1 uint32]  (replaces "screened"                                                                             
%                   flags: [1x1     struct]  	

    sunfile = getfullname('*starsun*.mat','starsun','Select starsun file to flag.');
%     s = load(sunfile);
    s = matfile(sunfile);
    [flags, good, flagfile] = starflag_(s);
    

% Test starflag_ and visi_screen_v15

% testing import_flags
        in_flags = load(getfullname([datestr(time(1),'yyyymmdd'),'*_starflag_*.mat'],'flag_files'));
flags
in_flags_flags=in_flags.flags;
in_flags_flags_struct=in_flags.flags_struct;
