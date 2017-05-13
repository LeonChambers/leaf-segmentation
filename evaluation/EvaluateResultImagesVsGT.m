%   Author: Hanno Scharr, Institute of Bio- and Geosciences II,
%   Forschungszentrum Jülich
%   Contact: h.scharr@fz-juelich.de
%   Date: 10.02.2016 (Version 2)
%
% Copyright 2016, Forschungszentrum Jülich GmbH, 52425 Jülich, Germany
% 
%                          All Rights Reserved
% 
% All commercial use of this software, whether direct or indirect, is
% strictly prohibited including, without limitation, incorporation into in
% a commercial product, use in a commercial service, or production of other
% artifacts for commercial purposes.     
%
% Permission to use, copy, modify, and distribute this software and its
% documentation worldwide for research purposes solely is hereby granted 
% without fee, provided that the above copyright notice appears in all 
% copies and that both that copyright notice and this permission notice 
% appear in supporting documentation, and that the name of the author and 
% Forschungszentrum Jülich GmbH not be used in advertising or publicity 
% pertaining to distribution of the software without specific, written 
% prior permission of the author available under above contact.
% The author preserves the rights to request the deletion or cancel of 
% non-authorized advertising and /or publicity activities.
%
% For intentions of commercial use please contact 
%
% Forschungszentrum Jülich GmbH
% To the attention of Hans-Werner Klein
% Department Technology-Transfer
% Wilhelm-Johnen-Straße
% 52428 Jülich
% Germany
%
%
% THE AUTHOR AND FORSCHUNGSZENTRUM JÜLICH GmbH DISCLAIM ALL WARRANTIES WITH 
% REGARD TO THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF 
% MERCHANTABILITY AND FITNESS FOR ANY PARTICULAR PURPOSE.  IN NO EVENT 
% SHALL THE AUTHOR OR FORSCHUNGSZENTRUM JÜLICH GmbH BE LIABLE FOR ANY SPECIAL,  
% INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING 
% FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, 
% NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH
% THE USE OR PERFORMANCE OF THIS SOFTWARE.  
%
% In case of arising software bugs neither the author nor Forschungszentrum 
% Jülich GmbH are obliged for bug fixes and other kinds of support.

function EvaluateResultImagesVsGT(Task, inpath, outpath, username)
% Implements labelbased evaluation
%
% inFolder: folder, where results can be found.   
% gtFolder: folder containing testing ground truth images.
% Foldernames: names of folders where ground truth data can be found in
% ResultFilePattern: file pattern for user supplied result files
% GTFilePattern: file pattern for ground truth files
% saveFolder: folder where csv-tables will be stored. Defaults to inFolder
% username: name used as csv-table base name, defaults to folder name
%
% Name convention of files to evaluate: 
%   - in the file path or file name a string 'Ara2012', 'Ara2013-Canon', or
%     'Tobacco' needs to be present at least once, indicating from which 
%     experiment data has been processed.
%   - the last number in the file name indicates the plant number
%   - results are assumed to be in PNG format with ending '.png'
% Please make sure, no other png-files than result files are in the inFolder.
%
% Name convention of ground truth label images
%   - for each experiment images are in a subfolder 'Ara2012', 'Ara2013-Canon',
%     or 'Tobacco'
%   - images are then named *plant%03d_label.png such that plant number 7 in
%     experiment 'Ara2012' has the file name 'Ara2012/ara2012_plant007_label.png'.
%
% Results are written in separate CSV (comma separated value) files names e.g.
% 'username_Ara2012_results.csv'. Please see the respective function 
% 'writeResultTable' for the exact format. 

    if nargin<3
        outpath = inpath;
    end
    if nargin<4
        username = [];
    end
    
    % check if fromFolder exists, return if not
    if ~isdir(inpath)
      errorMessage = sprintf('Error: The following folder does not exist:\n%s', inpath);
      uiwait(warndlg(errorMessage));
      return;
    end

    % recursively loop all subfolders
    filePattern = fullfile(inpath, '*');
    allFiles = dir(filePattern);
    for k = 1:length(allFiles)
      if allFiles(k).isdir;
         dirName = allFiles(k).name; 
         if( dirName(1) ~= '.')
            fullDirName = fullfile(inpath, dirName);
            if Task.evalMultipleExperiments>0
                % multiple experiments
                if isempty(username) 
                    % no username (or experiment name) given so far: dirName is username (or experiment name)
                    EvaluateResultImagesVsGT(Task, fullDirName,outpath,dirName);
                else
                    % username (or experiment name) available, use it
                    EvaluateResultImagesVsGT(Task, fullDirName,outpath,username);
                end
            else 
                % single experiment, all subfolders belong to the same experiment
                % no matter if first run or not. Use predefined prefix for
                % result file names.
                EvaluateResultImagesVsGT(Task, fullDirName,outpath,Task.prefix);
            end
         end
      end
    end

    % write to console what is going on
    fprintf(1, 'Processing %s ...\n', inpath);

    [theInFiles, imageNumber, experimentNumber] = getExperimentAndResultFileNumbers(inpath,Task.Foldernames,Task.ResultFilePattern);

    % calculate scores, also for missing result images: loop through
    % experiments and gt images
    for e = 1:length(Task.Foldernames) % loop experiments

      % check if current experiment shall be processed  
      idx = find(experimentNumber == e,1);
      if ~isempty(idx) 
        resultName = Task.Foldernames{e};
        % switch through different measure types
        if strcmp(Task.ScoreType,'one_label_image_per_image')
            [imageNumberGT,scores] = getLabelbasedScores(e,Task,inpath,theInFiles, imageNumber, experimentNumber);  
        elseif strcmp(Task.ScoreType,'one_table_per_image')
            [imageNumberGT,scores] = getTablebasedScores(e,Task,inpath,theInFiles, imageNumber, experimentNumber);  
        elseif strcmp(Task.ScoreType,'one_table_per_directory')
            [imageNumberGT,scores] = getSummarizedTablebasedScores(e,Task,inpath,theInFiles, imageNumber, experimentNumber);  
        else
            error('Error: Unknown score type! Aborting!');
        end
        writeResultTable(Task,resultName,outpath,username,imageNumberGT,scores);         
      end
    end  
return


% get list of files with their experiment numbers and image numbers for the
% given folder.
function [theInFiles, imageNumber, experimentNumber] = getExperimentAndResultFileNumbers(inFolder, Foldernames, ResultFilePattern)
% all output variables have the same length being the number of image result files in
% inFolder

    % process all per image result files (e.g. label images) from inFolder
    filePattern = fullfile(inFolder, ResultFilePattern);
    theInFiles = dir(filePattern);

    % initialize
    N = length(theInFiles); % number of files to check
    imageNumber = zeros(N,1);
    experimentNumber = zeros(N,1);

    % loop result files, get experiment number and image number 
    for k = 1:N

      % get FileName
      baseFileName = theInFiles(k).name; 
      inFileName = fullfile(inFolder, baseFileName);

      % check in which folder we need to look up the ground truth. May be
      % indicated in path or file name, therefore parse inFileName
      fileError = 1;
      for e=1:length(Foldernames)
          if(~isempty(strfind(lower(inFileName),lower(Foldernames{e}))))
              experimentNumber(k)  = e;
              fileError = 0;
              continue
          end
      end
      if(fileError==1)
          errorMessage = sprintf('Error: Cannot determine folder name for ground truth from:\n %s\n. Aborting!\n\n', inFileName);
          uiwait(warndlg(errorMessage));
          return;
      end

      % parse for last number in file name to determine which result file to
      % compare to
      nums = textscan(baseFileName,'%*[^0123456789]%d');
      if ~isempty(nums{end})
        imageNumber(k) = nums{end}(end);
      end

    end
return


