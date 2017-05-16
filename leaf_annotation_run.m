function [] = leaf_annotation_run(in_image_path, label_image_path, out_image_path, beta)

addpath('./LeafAnnotationTool');
addpath('./LeafAnnotationTool/graphAnalysisToolbox-1.0');

image = imread(in_image_path);
cform = makecform('srgb2lab');
lab = double(applycform(image, cform));

label_image = rgb2gray(imread(label_image_path));
seeds = find(label_image);

labels = 1:length(seeds);

if length(seeds) >= 1
    [masks, ~] = random_walker(lab, seeds, labels, double(beta));

    masks = masks .* (max(image, [], 3) ~= 0);

    imwrite(uint8(masks), out_image_path);
else
    imwrite(label_image, out_image_path);
end

end
