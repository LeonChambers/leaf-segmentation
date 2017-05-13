function res = num_leaves(filepath)

addpath('./evaluation');

res = max(max(max(CondenseLabels(rgb2ind(imread(filepath), 65536, 'nodither')))));

end
