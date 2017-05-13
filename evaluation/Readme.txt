Evaluation Suite for Plant Phenotyping Datasets
The matlab files provided here allow calculating benchmark scores for challenges posed with the plant phenotyping datasets described in
M. Minervini, A. Fischbach, H.Scharr, and S.A. Tsaftaris. Finely-grained annotated datasets for image-based plant phenotyping. Pattern Recognition Letters, pages 1-10, 2015, doi:10.1016/j.patrec.2015.10.013 
and available from http://www.plant-phenotyping.org/datasets. After downloading the dataset file, please run extractdataset.m to distribute the data needed for each task in a separate folder, respectively. We refer to this data as Ground Truth data or GT. The evaluation routines expect the data to be organized in the form extractdataset.m organize it. You may, however, delete folders of tasks you are not interested in, without harming the other tasks.

How to organize your result files
There are two options
1. Process multiple experiment runs at once: Store your algorithmic results of a certain task in a folder, with subfolders indicating experiment runs, and each of these subfolders the containing subsubfolders organized in the same way as the GT folder for this task. For example I store my results in a folder ‘myResults’ somewhere on my computer. This Folder has two subfolders ‘Results01’ and ‘Results02’ where I stored results from two different parameter settings of an experiment run. In the subfolders ‘Results01’ and ‘Results02’ then the folder structure is repeated in the same way as GT.
SomePath\myResults\Results01
SomePath\myResults\Results01\Ara2012
SomePath\myResults\Results01\Ara2013-Canon
SomePath\myResults\Results02
SomePath\myResults\Results02\Ara2012
SomePath\myResults\Results02\Ara2013-Canon
Having result data organized in this way routine ‘Evaluate_Task.m’ can be called in order to produce comma separated value (CVS) files and LaTeX files reporting the results in a standardized way:
      Evaluate_Task(1, datasetPath, resultsPath, evaluationPath);
2. Process a single experiment run, only: Store your algorithmic results of a certain task in a folder, with subfolders organized in the same way as the GT folder for this task. For example I store my results in a folder ‘myResults’ somewhere on my computer and the folder structure is repeated in the same way as GT.
SomePath\myResults\
SomePath\myResults\ Ara2012
SomePath\myResults\ Ara2013-Canon
Having result data organized in this way routine ‘Evaluate_Task.m’ can be called in order to produce comma separated value (CVS) files and LaTeX files reporting the results in a standardized way:
      Evaluate_Task(1, datasetPath, resultsPath, evaluationPath, 0);
The fifth input argument ‘0’ tells the evaluation routine that only a single experiments needs to be evaluated.

Remarks on Version 0.2
In this version evaluations for five tasks, namely 
* ‘Plant_detection_localization’, 
* 'Plant_segmentation', 
* 'Leaf_segmentation', 
* ‘Leaf_detection’, and
* ‘Leaf_counting’
i.e. tasks 1 to 5, are provided. Other evaluations will follow.

