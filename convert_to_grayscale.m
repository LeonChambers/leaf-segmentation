function [] = convert_to_grayscale(in_path, out_path)

in_image = imread(in_path);

% check if grey image in 24bit
mx1 = max(abs(in_image(:,:,1)-in_image(:,:,2)));
mx2 = max(abs(in_image(:,:,1)-in_image(:,:,3)));
mx = max(mx1(:)+mx2(:));
if(mx>0.5) % colored label image
    [out_image,~] = rgb2ind(in_image, 65536,'nodither');
else % grey image
    out_image = rgb2gray(in_image);
end

imwrite(out_image, out_path);

end
