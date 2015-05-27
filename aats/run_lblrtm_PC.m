function run_lblrtm(mode)

% run_lblrtm Depending on the input parameter 'mode', two execution modes are available:
%
%            mode  1 - Batch execution of LBLRTM for multiple LBLRTM input files (TAPE5):
%                      Description of a single step:
%                       - Copies TAPE5 file (name convention: 'TAPE5xxx', where xxx is a string)
%                         from a specified directory to the directory of the LBLRTM binary code.
%                       - Execution of LBLRTM.
%                       - Copies output files TAPE6 back to a different directory
%                         The name of the output file will be renamed to the input file name except
%                         that the sub-string TAPE5 will be changed to TAPE6.
%                       - Then the next TAPE5 file is processed
%                  2 - Batch execution of read_lblrtm:
%                       - TAPE6 will be read and processed in read_lblrtm 
%                       - Output of read_lblrtm is saved to a Matlab *.mat file where a 'm' is added
%                         in front of the TAPE6 file name:
%                         gas  - vector of slant water vapor path [molec/cm^2] 
%                         tran - vector of water vapor transmittance
%                         info - informational text
%
%
%
%            Additional Information: Set the correct path information inside this function.
%                                    (also for LBLRTM execution!)
%
% Call: run_lblrtm(mode)
%
%
% Thomas Ingold, IAP, 01/2000
% Adapted for Tropo by Beat Schmid 4/2000
% Adapted to work for several gases Beat Schmid 1/2001
% Adapted for Tropo and LBLRTM 6.01 Beat Schmid 8/2002 

%path(path,'c:\beat\matlab')
pfad_matlab='c:\beat\matlab';
n_gas=7; %Number of Gases considered see LBLRTM description

switch mode
case 1
	% path defintion
	pfad_read='c:\beat\LBLRTM\TAPE5';
	pfad_lbl='c:\beat\LBLRTM\aer_lblrtm\lblrtm\src';
	pfad_save='c:\beat\LBLRTM\TAPE6';
	eval(['cd ',pfad_read])
	files=dir(fullfile(pfad_read,'TAPE5*'));

	for i=1:length(files)
	[dummy,name,ext,ver]=fileparts(files(i).name);
 	 	copyfile(fullfile(pfad_read,[name,ext,ver]), ...
	                 fullfile(pfad_lbl,'TAPE5'))
		disp(sprintf('Processing %s (No. %i of %i)',files(i).name,i,length(files)))
		disp('Begin LBLRTM ...')
		% LBLRTM execution 
		eval(['cd ',pfad_lbl])
        	! lblrtm_console
		disp('End LBLRTM')
		% new name TAPE6.....
		ii=findstr([name,ext,ver],'5');
      files(i).TAPE6=[name,ext,ver];
      files(i).TAPE6(ii(1))='6';
      copyfile(fullfile(pfad_lbl,'TAPE6'), ...
		fullfile(pfad_save,files(i).TAPE6))
	end
case 2
	% path defintion
	pfad_read='c:\beat\LBLRTM\TAPE6';
	pfad_save='c:\beat\LBLRTM\mTAPE6';
	eval(['cd ',pfad_read])
	files=dir(fullfile(pfad_read,'TAPE6*'));

	for i=1:length(files)
		disp(sprintf('Processing %s (No. %i of %i)',files(i).name,i,length(files)))
		[dummy,name,ext,ver]=fileparts(files(i).name);
		[gas,tran,info]=read_LBLRTM_tp6(pfad_read,[name,ext,ver],n_gas);
		file_new=['m',name,'.mat'];
		eval(['save ',fullfile(pfad_save,file_new),' gas tran info'])
	end
end
eval(['cd ',pfad_matlab])
