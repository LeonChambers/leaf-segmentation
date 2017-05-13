function extractdataset(datasetId, datasetPath, newPath)
%EXTRACTDATASET extracts files for a specific vision task from the
% plant phenotyping dataset. The complete dataset can be obtained
% at http://www.plant-phenotyping.org/datasets. Further details on
% the datasets are provided in [1] and [2].
%
% [1] M. Minervini, A. Fischbach, H. Scharr, S. A. Tsaftaris, "Finely-grained
%     annotated datasets for image-based plant phenotyping," Pattern Recognition
%     Letters, 2015.
% [2] H. Scharr, M. Minervini, A. Fischbach, S. A. Tsaftaris, "Annotated Image
%     Datasets of Rosette Plants," Forschungszentrum Juelich GmbH, Germany,
%     Tech. Rep. FZJ-2014-03837, Jul. 2014.
%
% Input:
%   datasetId - Integer denoting the ID of the vision task of interest.
%               Valid values are the follwing:
%               1: Plant detection and localization
%               2: Plant segmentation
%               3: Leaf segmentation
%               4: Leaf detection
%               5: Leaf counting
%               6: Leaf tracking
%               7: Boundary estimation
%               8: Classification and regression
% datasetPath - Path to folder containing the Plant Phenotyping Datasets.
%     newPath - Path to folder where the folders and files of the selected
%               dataset will be copied.
%
% Example usage:
%    extractdataset(2, '.', 'workspace')
%
% Author:  Massimo Minervini
% Contact: massimo.minervini@imtlucca.it
% Version: 1.0
% Date:    06/01/2016
%
% Copyright (C) 2016 Pattern Recognition and Image Analysis (PRIAn) Unit,
% IMT Institute for Advanced Studies, Lucca, Italy.
% All rights reserved.

assert(ismember(datasetId,1:8),'Invalid dataset ID.')
assert(isdir(fullfile(datasetPath,'Plant')) || isdir(fullfile(datasetPath,'Stacks')) || isdir(fullfile(datasetPath,'Tray')), ...
    ['Path "' datasetPath '" does not contain the dataset.'])

newDir = {'Plant_detection_localization';
    'Plant_segmentation';
    'Leaf_segmentation';
    'Leaf_detection';
    'Leaf_counting';
    'Leaf_tracking';
    'Boundary_estimation';
    'Classification_regression'};
if ~isdir(fullfile(newPath,newDir{datasetId}))
    mkdir(fullfile(newPath,newDir{datasetId}))
else
    warning(['Directory "' newDir{datasetId} '" already exists. Files will be overwritten.'])
end

status = [];
switch datasetId
    case 1
        status(1) = copyfile(fullfile(datasetPath,'Tray','Ara2012','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(2) = copyfile(fullfile(datasetPath,'Tray','Ara2012','*_bbox.csv'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(3) = copyfile(fullfile(datasetPath,'Tray','Ara2013-Canon','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(4) = copyfile(fullfile(datasetPath,'Tray','Ara2013-Canon','*_bbox.csv'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(5) = copyfile(fullfile(datasetPath,'Tray','Ara2013-RPi','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2013-RPi'));
        status(6) = copyfile(fullfile(datasetPath,'Tray','Ara2013-RPi','*_bbox.csv'),fullfile(newPath,newDir{datasetId},'Ara2013-RPi'));
    case 2
        status(1) = copyfile(fullfile(datasetPath,'Tray','Ara2012','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(2) = copyfile(fullfile(datasetPath,'Tray','Ara2012','*_fg.png'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(3) = copyfile(fullfile(datasetPath,'Tray','Ara2013-Canon','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(4) = copyfile(fullfile(datasetPath,'Tray','Ara2013-Canon','*_fg.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
    case 3
        status(1) = copyfile(fullfile(datasetPath,'Plant','Ara2012','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(2) = copyfile(fullfile(datasetPath,'Plant','Ara2012','*_label.png'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(3) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(4) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','*_label.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(5) = copyfile(fullfile(datasetPath,'Plant','Tobacco','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Tobacco'));
        status(6) = copyfile(fullfile(datasetPath,'Plant','Tobacco','*_label.png'),fullfile(newPath,newDir{datasetId},'Tobacco'));
    case 4
        status(1) = copyfile(fullfile(datasetPath,'Plant','Ara2012','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(2) = copyfile(fullfile(datasetPath,'Plant','Ara2012','*_bbox.csv'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(3) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(4) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','*_bbox.csv'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(5) = copyfile(fullfile(datasetPath,'Plant','Tobacco','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Tobacco'));
        status(6) = copyfile(fullfile(datasetPath,'Plant','Tobacco','*_bbox.csv'),fullfile(newPath,newDir{datasetId},'Tobacco'));
    case 5
        status(1) = copyfile(fullfile(datasetPath,'Plant','Ara2012','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(2) = copyfile(fullfile(datasetPath,'Plant','Ara2012','*_centers.png'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(3) = copyfile(fullfile(datasetPath,'Plant','Ara2012','Leaf_counts.csv'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(4) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(5) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','*_centers.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(6) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','Leaf_counts.csv'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(7) = copyfile(fullfile(datasetPath,'Plant','Tobacco','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Tobacco'));
        status(8) = copyfile(fullfile(datasetPath,'Plant','Tobacco','*_centers.png'),fullfile(newPath,newDir{datasetId},'Tobacco'));
        status(9) = copyfile(fullfile(datasetPath,'Plant','Tobacco','Leaf_counts.csv'),fullfile(newPath,newDir{datasetId},'Tobacco'));
    case 6
        status(1) = copyfile(fullfile(datasetPath,'Stacks','Ara2012','stack_*'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(2) = copyfile(fullfile(datasetPath,'Stacks','Ara2013-Canon','stack_*'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
    case 7
        status(1) = copyfile(fullfile(datasetPath,'Plant','Ara2012','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(2) = copyfile(fullfile(datasetPath,'Plant','Ara2012','*_boundaries.png'),fullfile(newPath,newDir{datasetId},'Ara2012'));
        status(3) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(4) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','*_boundaries.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(5) = copyfile(fullfile(datasetPath,'Plant','Tobacco','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Tobacco'));
        status(6) = copyfile(fullfile(datasetPath,'Plant','Tobacco','*_boundaries.png'),fullfile(newPath,newDir{datasetId},'Tobacco'));
    case 8
        status(1) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(2) = copyfile(fullfile(datasetPath,'Plant','Ara2013-Canon','Metadata.csv'),fullfile(newPath,newDir{datasetId},'Ara2013-Canon'));
        status(3) = copyfile(fullfile(datasetPath,'Plant','Tobacco','*_rgb.png'),fullfile(newPath,newDir{datasetId},'Tobacco'));
        status(4) = copyfile(fullfile(datasetPath,'Plant','Tobacco','Metadata.csv'),fullfile(newPath,newDir{datasetId},'Tobacco'));
    otherwise
        error('Unknown dataset ID.')
end
if sum(status) == length(status)
    fprintf('Done!\n')
else
    fprintf('Something went wrong: error(s) have occurred while copying the files.\n')
end

end