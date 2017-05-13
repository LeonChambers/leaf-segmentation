function my_eval(run_id)

addpath('./evaluation');

datasetPath = 'data';
resultsPath = ['results/' run_id];
reportsPath = ['reports/' run_id];
subDir = 'Leaf_segmentation';

gtPath = fullfile(datasetPath, subDir);
assert(isdir(gtPath), ...
    ['Path "' datasetPath '" does not contain the "' subDir '" subfolder.  Please use "extractdataset" to copy it there.']);

outPath = fullfile(reportsPath,subDir);
if ~isdir(fullfile(reportsPath,subDir))
    mkdir(fullfile(reportsPath,subDir))
else
    warning(['Directory "' outPath '" already exists. Files will be overwritten.'])
end

status = 0;
Task.TaskID = 3;
Task.gtpath = gtPath;
Task.evalMultipleExperiments = 1;
Task.prefix = 'Experiment';
Task.Name = 'LeafSegmentation';
% Foldernames of valid experiments
Task.Foldernames = {'Ara2012', 'Ara2013-Canon', 'Tobacco'};
% needed to switch through the different evaluation types
Task.ScoreType = 'one_label_image_per_image';
% users file pattern for label images
Task.ResultFilePattern = '*_label.png';
% provided file pattern for ground truth label images
Task.GTFilePattern = '*_label.png';
% functions called to calculate scores
Task.Measures = {@SymmetricBestDice, @FGBGDice, @AbsDiffFGLabels, @DiffFGLabels};
% names of the measures
Task.MeasureNames = {'SymmetricBestDice', 'FGBGDice', 'AbsDiffFGLabels', 'DiffFGLabels'};
% format of the scores in CSV files
Task.MeasuresFormat = {', %f', ', %f', ', %d', ', %d'};
% format for mean and stddev in Latex files
Task.LatexStatsFormat = {'%.1f', '%.1f'};
% format for mean and stddev in Latex files
Task.LatexUnits = {'[\\%%]', '[\\%%]', '', ''};
% factor coming with units
Task.LatexUnitsFactor = {100, 100, 1, 1};

% create score tables for all experiments where result label images are available
EvaluateResultImagesVsGT(Task, resultsPath, outPath);

end
