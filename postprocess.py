#!/usr/bin/env python
""" Converts a grayscale result image to a color image for prettier display """
import cv2
import numpy as np
import argparse

def process_image(input_path, output_path):
    image = cv2.imread(input_path)
    if image is None:
        raise ValueError(
            "No image found at {}".format(input_path)
        )
    height, width, channels = image.shape
    for i in range(height):
        for j in range(width):
            old_val = image[i, j]
            if old_val[0]:
                image[i, j] = (16*old_val[0], 175, 175)
    image = cv2.cvtColor(image, cv2.COLOR_HSV2RGB)
    cv2.imwrite(output_path, image)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("input_path")
    parser.add_argument("output_path")
    args = parser.parse_args()
    process_image(args.input_path, args.output_path)
