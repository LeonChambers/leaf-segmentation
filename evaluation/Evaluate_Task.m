%   Author: Hanno Scharr, Institute of Bio- and Geosciences II,
%   Forschungszentrum Jülich
%   Contact: h.scharr@fz-juelich.de
%   Date: 10.02.2016 (Version 0.2)
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

function Evaluate_Task(taskId, datasetPath, resultsPath, evaluationPath, evalMultipleExperiments)
%Evaluate_Task evaluates results of a specific vision task from the
% plant phenotyping dataset. It us assumed that the has been copied to
% task-specific folders using EXTRACTDATASET.
% The complete dataset can be obtained at 
% http://www.plant-phenotyping.org/datasets. 
% Further details on the datasets are provided in [1] and [2].
%
% [1] M. Minervini, A. Fischbach, H. Scharr, S. A. Tsaftaris, "Finely-grained
%     annotated datasets for image-based plant phenotyping," Pattern Recognition
%     Letters, 2015.
% [2] H. Scharr, M. Minervini, A. Fischbach, S. A. Tsaftaris, "Annotated Image
%     Datasets of Rosette Plants," Forschungszentrum Juelich GmbH, Germany,
%     Tech. Rep. FZJ-2014-03837, Jul. 2014.
%
% Input:
%   taskId - Integer denoting the ID of the vision task of interest.
%               Valid values are the follwing:
%               1: Plant detection and localization
%               2: Plant segmentation
%               3: Leaf segmentation
%               4: Leaf detection
%               5: Leaf counting
%               6: Leaf tracking
%               7: Boundary estimation
%               8: Classification and regression
% datasetPath - Path to folder containing the Plant Phenotyping Dataset
%               subfolders created by EXTRACTDATASET
% resultsPath - Path to folder where the folders and files of the results of
%               the respective, selected task can be found
% evaluationPath - Path to folder where the evaluation files are created by 
%               Evaluate_Task. This is the only place where this routine
%               writes files. Other folders remain unaltered.
% evalMultipleExperiments - evaluate a single or multiple experiments
%               0: resultsPath contains results of only 1 experiment run
%               1: (default) evaluate multiple experiments in separate
%               subfolders
%
% Example usage:
%    Evaluate_Task(3, '.', 'myresults', 'evaluation')
%
% Author:  Hanno Scharr
% Contact: H.Scharr@fz-juelich.de
% Version: 0.1
% Date:    06/01/2016
%
% Copyright (C) 2016 Forschungszentrum Juelich GmbH, 52428 Juelich, Germany
% All rights reserved.

if nargin < 5
    evalMultipleExperiments = 1;
end

assert(ismember(taskId,1:8),'Invalid dataset ID.')

subDir = {'Plant_detection_localization';
    'Plant_segmentation';
    'Leaf_segmentation';
    'Leaf_detection';
    'Leaf_counting';
    'Leaf_tracking';
    'Boundary_estimation';
    'Classification_regression'};

gtPath = fullfile(datasetPath, subDir{taskId});
assert(isdir(gtPath), ...
    ['Path "' datasetPath '" does not contain the "' subDir{taskId} '" subfolder. Please use "extractdataset" to copy it there.'])

outPath = fullfile(evaluationPath,subDir{taskId});
if ~isdir(fullfile(evaluationPath,subDir{taskId}))
    mkdir(fullfile(evaluationPath,subDir{taskId}))
else
    warning(['Directory "' outPath '" already exists. Files will be overwritten.'])
end

status = 0;
Task.TaskID = taskId;
Task.gtpath = gtPath;
Task.evalMultipleExperiments = evalMultipleExperiments;
Task.prefix = 'Experiment';

switch taskId
    case 1
        Task.Name = 'Plant_detection_localization';
        Task.Foldernames = {'Ara2012', 'Ara2013-Canon', 'Ara2013-RPi'}; % Foldernames of valid experiments
        Task.ScoreType = 'one_table_per_image'; % needed to switch through the different evaluation types
        Task.ResultFilePattern = '*_bbox.csv'; % users file pattern for result tables
        Task.GTFilePattern = '*_bbox.csv'; % provided file pattern for ground truth tables
        Task.inTableSkipBefore = 0; % number of preceeding numbers in result table
        Task.inTableNumData = 8; % number of coordinates describing bbox (8 for a rectangle) in result table
        Task.inTableSkipAfter = 0; % number of entries after bbox-data in result table
        Task.inTableDelimiter = ','; % delimiter used in result table
        Task.gtTableSkipBefore = 0; % number of preceeding numbers in ground truth table
        Task.gtTableNumData = 8; % number of coordinates describing bbox (8 for a rectangle) in ground truth table
        Task.gtTableSkipAfter = 0; % number of entries after bbox-data in ground truth table
        Task.gtTableDelimiter = ','; % delimiter used in ground truth table
        Task.Measures = {@SymmetricBestPolyDice, @SymmetricBestPolyOverlap, @DiffNumPolygons, @AbsDiffNumPolygons}; % functions called to calculate scores
        Task.MeasureNames = {'SBD', 'Overlap', 'DiC', '|DiC|'}; % names of the measures
        Task.MeasuresFormat = {', %f', ', %f', ', %d', ', %d'}; % format of the scores in CSV files
        Task.LatexStatsFormat = {'%.1f', '%.1f'}; % format for mean and stddev in Latex files
        Task.LatexUnits = {'[\\%%]', '[\\%%]', '', ''}; % format for mean and stddev in Latex files
        Task.LatexUnitsFactor = {100, 100, 1, 1}; % factor coming with units
        
        % create score tables for all experiments where result label images are available
        EvaluateResultImagesVsGT(Task, resultsPath, outPath);

        % create overall score table, also including experiments where no
        % result tables are available
        CreateOverallFile(Task,resultsPath,outPath);
    case 2
        Task.Name = 'PlantSegmentation';
        Task.Foldernames = {'Ara2012', 'Ara2013-Canon'}; % Foldernames of valid experiments
        Task.ScoreType = 'one_label_image_per_image'; % needed to switch through the different evaluation types
        Task.ResultFilePattern = '*_fg.png'; % users file pattern for label images
        Task.GTFilePattern = '*_fg.png'; % provided file pattern for ground truth label images
        Task.Measures = {@FGBGDice, @modifiedhausdorffdistance}; % functions called to calculate scores
        Task.MeasureNames = {'FGBGDice', 'MHD'}; % names of the measures
        Task.MeasuresFormat = {', %f', ', %f'}; % format of the scores in CSV files
        Task.LatexStatsFormat = {'%.1f', '%.1f'}; % format for mean and stddev in Latex files
        Task.LatexUnits = {'[\\%%]', ''}; % format for mean and stddev in Latex files
        Task.LatexUnitsFactor = {100, 1}; % factor coming with units
        
        % create score tables for all experiments where result label images are available
        EvaluateResultImagesVsGT(Task, resultsPath, outPath);

        % create overall score table, also including experiments where no
        % result images are available
        CreateOverallFile(Task,resultsPath,outPath);

    case 3
        Task.Name = 'LeafSegmentation';
        Task.Foldernames = {'Ara2012', 'Ara2013-Canon', 'Tobacco'};    % Foldernames of valid experiments
        Task.ScoreType = 'one_label_image_per_image'; % needed to switch through the different evaluation types
        Task.ResultFilePattern = '*_label.png'; % users file pattern for label images
        Task.GTFilePattern = '*_label.png'; % provided file pattern for ground truth label images
        Task.Measures = {@SymmetricBestDice, @FGBGDice, @AbsDiffFGLabels, @DiffFGLabels}; % functions called to calculate scores
        Task.MeasureNames = {'SymmetricBestDice', 'FGBGDice', 'AbsDiffFGLabels', 'DiffFGLabels'}; % names of the measures
        Task.MeasuresFormat = {', %f', ', %f', ', %d', ', %d'}; % format of the scores in CSV files
        Task.LatexStatsFormat = {'%.1f', '%.1f'}; % format for mean and stddev in Latex files
        Task.LatexUnits = {'[\\%%]', '[\\%%]', '', ''}; % format for mean and stddev in Latex files
        Task.LatexUnitsFactor = {100, 100, 1, 1}; % factor coming with units
 
        % create score tables for all experiments where result label images are available
        EvaluateResultImagesVsGT(Task, resultsPath, outPath);
 
        % create overall score table, also including experiments where no
        % result images are available
        CreateOverallFile(Task,resultsPath,outPath);

    case 4
        Task.Name = 'LeafDetection';
        Task.Foldernames = {'Ara2012', 'Ara2013-Canon', 'Tobacco'}; % Foldernames of valid experiments
        Task.ScoreType = 'one_table_per_image'; % needed to switch through the different evaluation types
        Task.ResultFilePattern = '*_bbox.csv'; % users file pattern for result tables
        Task.GTFilePattern = '*_bbox.csv'; % provided file pattern for ground truth tables
        Task.inTableSkipBefore = 1; % number of preceeding numbers in result table
        Task.inTableNumData = 8; % number of coordinates describing bbox (8 for a rectangle) in result table
        Task.inTableSkipAfter = 0; % number of entries after bbox-data in result table
        Task.inTableDelimiter = ','; % delimiter used in result table
        Task.gtTableSkipBefore = 1; % number of preceeding numbers in ground truth table
        Task.gtTableNumData = 8; % number of coordinates describing bbox (8 for a rectangle) in ground truth table
        Task.gtTableSkipAfter = 0; % number of entries after bbox-data in ground truth table
        Task.gtTableDelimiter = ','; % delimiter used in ground truth table
        Task.Measures = {@SymmetricBestPolyDice, @SymmetricBestPolyOverlap, @DiffNumPolygons, @AbsDiffNumPolygons}; % functions called to calculate scores
        Task.MeasureNames = {'SBD', 'Overlap', 'DiC', '|DiC|'}; % names of the measures
        Task.MeasuresFormat = {', %f', ', %f', ', %d', ', %d'}; % format of the scores in CSV files
        Task.LatexStatsFormat = {'%.1f', '%.1f'}; % format for mean and stddev in Latex files
        Task.LatexUnits = {'[\\%%]', '[\\%%]', '', ''}; % format for mean and stddev in Latex files
        Task.LatexUnitsFactor = {100, 100, 1, 1}; % factor coming with units
        
        % create score tables for all experiments where result label images are available
        EvaluateResultImagesVsGT(Task, resultsPath, outPath);

        % create overall score table, also including experiments where no
        % result tables are available
        CreateOverallFile(Task,resultsPath,outPath);
    case 5
        
        Task.Name = 'LeafCounting';
        Task.Foldernames = {'Ara2012', 'Ara2013-Canon', 'Tobacco'}; % Foldernames of valid experiments
        Task.ScoreType = 'one_table_per_directory'; % needed to switch through the different evaluation types
        Task.ResultFilePattern = '*_counts.csv'; % users file pattern for table
        Task.GTFilePattern = '*_counts.csv'; % provided file pattern for ground truth table
        Task.inTableColumnOfImageNumber = 0; % column, where image number is given in summarizing table, usually 1 or 0
        Task.inTableColumnOfImageName = 1; % column, where image name is given in summarizing table, usually 1 or 0
        Task.inTableSkipBefore = 0; % number of preceeding numbers in result table
        Task.inTableNumData = 1; % number of coordinates describing bbox (8 for a rectangle) in result table
        Task.inTableSkipAfter = 0; % number of entries after bbox-data in result table
        Task.inTableDelimiter = ','; % delimiter used in result table
        Task.gtTableColumnOfImageNumber = 0; % column, where image number is given in summarizing table, usually 1 or 0
        Task.gtTableColumnOfImageName = 1; % column, where image name is given in summarizing table, usually 1 or 0
        Task.gtTableSkipBefore = 0; % number of preceeding numbers in ground truth table
        Task.gtTableNumData = 1; % number of coordinates describing bbox (8 for a rectangle) in ground truth table
        Task.gtTableSkipAfter = 0; % number of entries after bbox-data in ground truth table
        Task.gtTableDelimiter = ','; % delimiter used in ground truth table
        Task.Measures = {@SumOfDifferences, @SumOfAbsDifferences}; % functions called to calculate scores
        Task.MeasureNames = {'DiC', '|DiC|'}; % names of the measures
        Task.MeasuresFormat = {', %d', ', %d'}; % format of the scores in CSV files
        Task.LatexStatsFormat = {'%.1f', '%.1f'}; % format for mean and stddev in Latex files
        Task.LatexUnits = { '', ''}; % format for mean and stddev in Latex files
        Task.LatexUnitsFactor = {1, 1}; % factor coming with units
        
        % create score tables for all experiments where result label images are available
        EvaluateResultImagesVsGT(Task, resultsPath, outPath);

        % create overall score table, also including experiments where no
        % result tables are available
        CreateOverallFile(Task,resultsPath,outPath);
    case 6
        warning(['Sorry, evaluation for "' subDir{taskId} '" not implemented in this version of "Evaluate_Task". Please check "http://www.plant-phenotyping.org/datasets" for updates.'])
        status = -1;
    case 7
        warning(['Sorry, evaluation for "' subDir{taskId} '" not implemented in this version of "Evaluate_Task". Please check "http://www.plant-phenotyping.org/datasets" for updates.'])
        status = -1;
    case 8
        warning(['Sorry, evaluation for "' subDir{taskId} '" not implemented in this version of "Evaluate_Task". Please check "http://www.plant-phenotyping.org/datasets" for updates.'])
        status = -1;
    otherwise
        error('Unknown dataset ID.')
end
if status >= 0
    fprintf('Done!\n')
else
    fprintf('Something went wrong: error(s) have occurred while evaluating results.\n')
end

end