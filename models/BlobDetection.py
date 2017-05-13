import os.path
import cv2
import time
import json
import numpy as np
from scipy.misc import imread, imsave
from scipy.spatial import distance
import shutil
from imutils import contours
import opentuner
from opentuner.search.objective import MaximizeAccuracy
from opentuner.measurement.inputmanager import FixedInputManager
from matplotlib import pyplot as plt

from .base import LeafSegmentationModel

class ModelTuner(opentuner.MeasurementInterface):
    def __init__(self, *args, **kwargs):
        kwargs["objective"] = MaximizeAccuracy()
        kwargs["input_manager"] = FixedInputManager()
        super(ModelTuner, self).__init__(*args, **kwargs)
        self.model = Model(self.run_id)

    def manipulator(self):
        manipulator = opentuner.ConfigurationManipulator()
        manipulator.add_parameter(
            opentuner.FloatParameter("minCircularity", 0, 1)
        )
        manipulator.add_parameter(
            opentuner.FloatParameter("circularityRange", 0, 1)
        )
        manipulator.add_parameter(
            opentuner.FloatParameter("minConvexity", 0, 1)
        )
        manipulator.add_parameter(
            opentuner.FloatParameter("convexityRange", 0, 1)
        )
        manipulator.add_parameter(
            opentuner.FloatParameter("minInertiaRatio", 0, 1)
        )
        manipulator.add_parameter(
            opentuner.FloatParameter("inertiaRatioRange", 0, 1)
        )
        manipulator.add_parameter(
            opentuner.IntegerParameter("minArea", 1, 10000)
        )
        manipulator.add_parameter(
            opentuner.IntegerParameter("areaRange", 1, 10000)
        )
        return manipulator

    def run(self, desired_result, input, limit):
        cfg = desired_result.configuration.data

        try:
            self.model.load_config(cfg)
        except ValueError as e:
            return opentuner.Result(
                state='ERROR', time=float('inf')
            )

        if os.path.isdir(self.model.results_path):
            shutil.rmtree(self.model.results_path)
        self.model.prepare_output(self.data)

        start_time = time.time()
        leaf_counts = self.model.test(self.data)
        end_time = time.time()
        test_time = end_time - start_time

        # Compute the average absolute difference in leaf counts vs GT
        abs_diffs = [
            abs(leaf_counts[x] - self.data.leaf_counts[x]) for x in 
            leaf_counts.keys()
        ]
        avg_abs_diff = sum(abs_diffs)/float(len(abs_diffs))

        return opentuner.Result(
            time=test_time,
            accuracy=-avg_abs_diff
        )

    def save_final_config(self, configuration):
        print "Writing optimal parameters to disk"
        config_filepath = os.path.join(self.model.config_path, "config.json")
        if not os.path.isdir(self.model.config_path):
            os.makedirs(self.model.config_path)
        self.manipulator().save_to_file(configuration.data, config_filepath)

class Model(LeafSegmentationModel):
    def __init__(self, run_id, dry=False):
        super(Model, self).__init__(run_id, dry=dry)

        # Set up the detector with parameters
        self.params = cv2.SimpleBlobDetector_Params()

        # Filter by size
        self.params.filterByArea = True
        # min and max will be set by opentuner

        # Filter by color
        self.params.filterByColor = True
        self.params.blobColor = 255

        # Filter by circularity
        self.params.filterByCircularity = True
        # min and max will be set by opentuner

        # Filter by convexity
        self.params.filterByConvexity = True
        # min and max will be set by opentuner

        # Filter by inertia
        self.params.filterByInertia = True
        # min and max will be set by opentuner

    def load_config(self, cfg):
        self.params.minCircularity = cfg["minCircularity"]
        self.params.maxCircularity = \
            cfg["minCircularity"] + cfg["circularityRange"]
        self.params.minConvexity = cfg["minConvexity"]
        self.params.maxConvexity = \
            cfg["minConvexity"] + cfg["convexityRange"]
        self.params.minInertiaRatio = cfg["minInertiaRatio"]
        self.params.maxInertiaRatio = \
                cfg["minInertiaRatio"] + cfg["inertiaRatioRange"]
        self.params.minArea = cfg["minArea"]
        self.params.maxArea = cfg["minArea"] + cfg["areaRange"]
        self.detector = cv2.SimpleBlobDetector(self.params)

    def process_image(self, image):
        # Detect blobs.
        keypoints = self.detector.detect(image)

        output_image = np.zeros(image.shape)

        for i, keypoint in enumerate(keypoints):
            center = (int(keypoint.pt[0]), int(keypoint.pt[1]))
            cv2.circle(
                output_image, center, int(keypoint.size/2), (i, i, i), -1
            )

        return output_image, len(keypoints)

    def train(self, data):
        ModelTuner.run_id = self.run_id + "-train"
        ModelTuner.data = data
        tuner = ModelTuner()
        args = ["--no-dups"]
        if self.dry:
            args.append("--stop-after=10")
        tuner.main(opentuner.default_argparser().parse_args(args))

        # Copy the final config into the results folder for this model
        curr_config_path = os.path.join(
            tuner.model.config_path, "config.json"
        )
        desired_config_path = os.path.join(self.config_path, "config.json")
        if not os.path.isdir(self.config_path):
            os.makedirs(self.config_path)
        shutil.move(curr_config_path, desired_config_path)

        shutil.rmtree(tuner.model.results_path)
        shutil.rmtree(tuner.model.config_path)
        os.rmdir(os.path.dirname(tuner.model.config_path))
        os.rmdir(os.path.dirname(tuner.model.results_path))

    def pre_test(self, data):
        super(Model, self).pre_test(data)

        # Load the optimized parameters from disk
        optimized_config_path = os.path.join(
            self.config_path, "config.json"
        )
        with open(optimized_config_path, "r") as f:
            config = json.load(f)
        self.load_config(config)

    def test(self, data):
        leaf_counts = {}
        for (input_filename, output_filename) in data.images(self.run_id):
            input_image = imread(input_filename)
            output_image, num_keypoints = self.process_image(input_image)
            with open(output_filename, "wb+") as f:
                imsave(f, output_image)
            leaf_counts[os.path.basename(output_filename)] = num_keypoints
        return leaf_counts
