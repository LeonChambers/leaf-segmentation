#!/usr/bin/env python
import matlab.engine
import os.path
import re
import cv2
import glob
import json
import numpy as np
import argparse

eng = matlab.engine.start_matlab()
scaledWidth = 200
scaledHeight = 200

def get_images(dataset):
    top_level_dir = os.path.dirname(__file__)
    in_folder = os.path.join(
        top_level_dir, "data", "Leaf_segmentation", dataset
    )
    out_folder = in_folder + "_preprocessed"
    if not os.path.isdir(out_folder):
        os.mkdir(out_folder)
    res = []
    for in_rgb_path in glob.glob(os.path.join(in_folder, "*_rgb.png")):
        in_labels_path = re.sub("_rgb.png$", "_label.png", in_rgb_path)
        out_rgb_path = os.path.join(
            out_folder, os.path.basename(in_rgb_path)
        )
        out_labels_path = os.path.join(
            out_folder, os.path.basename(in_labels_path)
        )
        res.append((in_rgb_path, in_labels_path, out_rgb_path, out_labels_path))
    return res

def preprocess_dataset(dataset):
    images = get_images(dataset)
    for (in_rgb_path, in_labels_path, out_rgb_path, out_labels_path) in images:
        # Load the plant image and ground truth labels
        in_rgb = cv2.imread(in_rgb_path)
        in_labels = cv2.imread(in_labels_path)

        # Mask in_rgb with the ground truth labels
        in_labels_grayscale = cv2.cvtColor(in_labels, cv2.COLOR_BGR2GRAY)
        _, mask = cv2.threshold(in_labels_grayscale, 0, 255, cv2.THRESH_BINARY)
        in_rgb_masked = cv2.bitwise_and(in_rgb, in_rgb, mask=mask)

        # Scale both images to be 200x200
        out_rgb = cv2.resize(in_rgb_masked, (scaledWidth, scaledHeight))
        out_labels = cv2.resize(
            in_labels, (scaledWidth, scaledHeight),
            interpolation=cv2.INTER_NEAREST
        )

        # Write the images
        if not cv2.imwrite(out_rgb_path, out_rgb):
            raise RuntimeError("Failed to write image {}".format(out_path))
        if not cv2.imwrite(out_labels_path, out_labels):
            raise RuntimeError(
                "Failed to write labels {}".format(out_labels_path)
            )

        # Convert the labels image to grayscale
        eng.convert_to_grayscale(out_labels_path, out_labels_path, nargout=0)

    leaf_counts = {
        os.path.basename(info[3]): int(eng.count_leaves(info[3])) for info in images
    }
    counts_in_path = os.path.join(
        os.path.dirname(in_labels_path), "leaf_counts.json"
    )
    counts_out_path = os.path.join(
        os.path.dirname(out_labels_path), "leaf_counts.json"
    )
    with open(counts_in_path, "w+") as f:
        json.dump(leaf_counts, f)
    with open(counts_out_path, "w+") as f:
        json.dump(leaf_counts, f)

if __name__ == '__main__':
    for dataset in ["Ara2012", "Ara2013-Canon", "Tobacco"]:
        print "Preprocessing dataset \"{}\"".format(dataset)
        preprocess_dataset(dataset)
