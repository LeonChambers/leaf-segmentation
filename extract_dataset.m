function extract_dataset(dataset_path)

addpath('./evaluation');

extractdataset(3, fullfile(dataset_path, 'Plant_Phenotyping_Datasets'), 'data');

end
