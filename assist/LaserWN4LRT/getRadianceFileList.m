function fileList = getRadianceFileList(directory)

  directoryContentStruct = dir(directory);
  directoryContent = {directoryContentStruct.name};
  
  regex = '\d{8}_\d{6}_ch\D{1}_SCENE.coad.mrad.coad.merged.truncated.mat';
  fileList = cell(0);

  for i = 1: length(directoryContent);
    file = directoryContent(i);
    file = file{1};
    if regexp(file, regex) == 1
        fileList(length(fileList)+1) = {sprintf('%s%s', directory, file)};
    end
  end
end