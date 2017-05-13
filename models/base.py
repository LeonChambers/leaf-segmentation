import matlab.engine
import os.path
import glob
import json
import time
import shlex
import shutil
import subprocess

eng = matlab.engine.start_matlab()
top_level_dir = os.path.dirname(os.path.dirname(__file__))

class LeafSegmentationModel(object):
    def __init__(self, run_id, dry=False):
        self.run_id = run_id
        self.dry = dry
        self.results_path = os.path.join(
            top_level_dir, "results", self.run_id, "Leaf_segmentation"
        )
        self.reports_path = os.path.join(
            top_level_dir, "reports", self.run_id, "Leaf_segmentation"
        )
        self.config_path = os.path.join(
            top_level_dir, "config", self.run_id, "Leaf_segmentation"
        )

    def pre_train(self, data):
        pass

    def train(self, data):
        raise NotImplementedError()

    def post_train(self, data):
        pass

    def run_train(self, data):
        self.pre_train(data)
        start_time = time.time()
        self.train(data)
        end_time = time.time()
        self.post_train(data)
        elapsed_time = end_time - start_time
        return elapsed_time

    def pre_test(self, data):
        # Delete any old results
        if os.path.isdir(self.results_path):
            shutil.rmtree(self.results_path)

        self.prepare_output(data)

    def test(self, data):
        raise NotImplementedError()

    def post_test(self, data):
        pass

    def run_test(self, data):
        self.pre_test(data)
        print "Starting test run"
        start_time = time.time()
        self.test(data)
        end_time = time.time()
        self.post_test(data)
        elapsed_time = end_time - start_time
        return elapsed_time

    def evaluate(self):
        eng.my_eval(self.run_id, nargout=0)

    def write_timing_report(self, new_timings):
        report_filepath = os.path.join(self.reports_path, "timing.json")
        with open(report_filepath, "r") as f:
            timings = json.load(f)
        timings.update(new_timings)
        with open(report_filepath, "w+") as f:
            json.dump(timings, f, indent=4)

    def prepare_output(self, data):
        """
        Make all folders that we will write results to for the dataset given by
        `data` exist
        """
        for (_, output_filename) in data.images(self.run_id):
            folder = os.path.dirname(output_filename)
            if not os.path.isdir(folder):
                os.makedirs(folder)
