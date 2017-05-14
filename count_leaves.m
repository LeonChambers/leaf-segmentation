function res = num_leaves(filepath)

addpath('./evaluation');

res = max(max(max(CondenseLabels(imread(filepath)))));

end
