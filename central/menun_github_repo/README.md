menuN - Improved menu for Matlab
===============

A powerful but simple to use graphical user interface menu in Matlab. Creates an automatically sized gui menu at the center of the screen with the supplied figure title and waits for user input. 
7 different types of menu styles are available: Push-button *, Radio-button *, Popup-menu/list *, Check box ^, List box ^, Slider and Text box. The styles marked by * represent exlusive selection, i.e. only one option can be selected. The syles marked by ^ represent multiple selection, i.e. none to all options can be selected. The slider style creates a slider which returns a numeric value in given range. The text box style returns the written text or numeric input that the user specifies in the edit/text box field. 
A default selection/value/text is also possible to specify when applicable. 

In addition to the different menu styles, multiple groups of options can be presented in the same menu to quickly create a small application specific user interface. This feature can also display subtitles for each option group. 

The syntax and usage of menuN is similar to the Matlab function menu. However, some additional formats of the inputs and output have been added to make use of the additional features.   

Syntax:

	choice = menuN(mtitle, options)
  
	mtitle	- [string] - Title and message at the top of the menu window
			- [cell of length 2] - {'Title','Message'} - Supply different title and message, leave meassage empty for no message
	options	- [various] - Menu options
	
Style specific input options with examples:

	Push-buttons: [cellstring array]
		options	= {'Choice 1','Choice 2','Choice 3'}; 
		Note, this is similar to the syntax for menu.
	Radio-buttons: [string starting with 'r|']
		options	= 'r|Choice 1|¤Choice 2|Choice 3'; 
		Note, option marked with ¤ is set as default selection.
	Popup-menu: [string starting with 'p|']
		options	= 'p|Choice 1|¤Choice 2|Choice 3';
	Check-boxes: [string starting with 'x|']
		options	= 'x|Choice 1|¤Choice 2|¤Choice 3'; 
		Note, options marked with ¤ are set ticked/checked as default.
	List-box: [string starting with 'l|']
		options	= 'l|Choice 1|¤Choice 2|¤Choice 3'; 
	Slider: [double array of length 2 or 3]
		options = [startValue,endValue,defaultValue]; 
		Note, defaultValue is optional, if not supplied the slider is placed in the middle.
	Text-box: [string starting with 't|']
		options = 't|My default text'; OR  	
		options = 't|My default text|with multiple|lines'; OR
		options = 't|1:1:25'; - [string starting with 't|']
		Note, obvious numeric input (see third example) will be converted to numeric value(s).  
		
Multiple option groups:

	options	- cell of size = [N, 2]
	
	options{:, 1}	- Any of the above styles except for the push-button.
	options{:, 2}	- Subtitle placed above the options specified on the same row. 
					Note, leave empty or blank '' if no subtitle should be displayed. 
	Example:
		options	=	{'p|popup1|popup2', 'Popup subtitle'; ...
               'x|check1|check2', 'Checkbox subtitle'; ...
               [0, 1, 0.5], 'Slider subtitle'};

Output:

	choice - [double, string, cell] - selected option index, value(s) or text
	
Note, if no option is selected, the window is closed, or the cancel button is clicked choice is NaN.
If multiple option groups are supplied, choice is a cell array of size [N, 1] with the correspondigly selected option/value/string on each row.
	
Examples:

	Standard menu like call with push-buttons:
		choice = menuN('Select color',{'Red','Green','Blue'});
	
	Multiple selection using check-boxes:
		choices = menuN({'Licence','I have read and agrees|with the following documents:'},'x|Licence.txt|Agreement2016.txt|Readme.txt');
		
	A numeric value in a given range using a slider:
		value = menuN({'Parameter select','Choose value for parameter A'},[0,25,9]);
	
	Message of the day using text/edit-box:
		string = menuN('Message of the day',['t|' datestr(today) ':||']);
		
	Numeric value(s) using text/edit-box:
		value = menuN('Loss parameter','t|4.6*10^-3');
		
	Multitle option groups:
		choiceCellArray = menuN({'Menu','Plotting toolbox'},{'r|¤Linear|Nearest','Interpolation method for|data plot';'x|Smooth|Plot|Save','Operations'});
	
	
Advanced mode: 

	choice = menuN(mtitle, options, Opt)
	Opt - option structure which can be used to override default fontsizes, OK/Cancel button labels and gui sizes etc.
	Check the code for full list of options. 
	
See also:
	
	menu, inputdlg
