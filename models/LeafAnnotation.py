import re
import os.path
import json
import glob
import shutil
import matlab.engine

from .base import LeafSegmentationModel, eng
from .BlobDetection import Model as BlobDetectionModel

class Model(LeafSegmentationModel):
    def __init__(self, run_id, dry=False, beta=None):
        super(Model, self).__init__(run_id, dry=dry)
        self.beta = beta

    def train(self, data):
        best_beta = None
        best_score = 0

        blob_detector = self.make_blob_detector(self.run_id+'_train_pre')
        blob_detector.prepare_output(data)
        blob_detector.test(data)

        for beta in range(5, 101, 5):
            print "Testing beta value of {}".format(beta)
            model = Model(self.run_id+'_train', dry=self.dry, beta=beta)
            model.prepare_output(data)
            model.test(data)
            model.evaluate()

            results = {}
            reports_glob = os.path.join(
                model.reports_path, "Leaf_segmentation_*.csv"
            )
            for report_path in glob.glob(reports_glob):
                with open(report_path, "r") as f:
                    first = f.readline()
                    dataset_name = first.strip()[20:].lower()
                    f.readline()
                    f.readline()
                    line = f.readline().strip()
                    dataset_results = {}
                    while line:
                        terms = line.split(", ")
                        dataset_results[int(terms[0])] = float(terms[1])
                        line = f.readline().strip()
                results[dataset_name] = dataset_results

            count = 0
            total = 0
            for in_path, _ in data.images(self.run_id):
                terms = os.path.split(in_path)[-1].split("_")
                dataset_name = terms[0]
                number = int(terms[1][5:])
                total += results[dataset_name][number]
                count += 1

            score = total/count
            print score

            if score > best_score:
                best_score = score
                best_beta = beta

            shutil.rmtree(model.results_path)
            os.rmdir(os.path.dirname(model.results_path))
            shutil.rmtree(model.reports_path)
            os.rmdir(os.path.dirname(model.reports_path))

            if self.dry:
                break

        shutil.rmtree(blob_detector.results_path)
        os.rmdir(os.path.dirname(blob_detector.results_path))

        print "Chose beta value of {}".format(best_beta)

        if not os.path.isdir(self.config_path):
            os.makedirs(self.config_path)

        with open(os.path.join(self.config_path, "config.json"), "w+") as f:
            json.dump({"beta": best_beta}, f)

    def pre_test(self, data):
        super(Model, self).pre_test(data)
        with open(os.path.join(self.config_path, "config.json"), "r") as f:
            config = json.load(f)
        self.beta = config["beta"]
        self.blob_detector = self.make_blob_detector(self.run_id+'_pre')
        self.blob_detector.prepare_output(data)
        self.blob_detector.test(data)

    def test(self, data):
        for in_path, out_path in data.images(self.run_id):
            label_path = re.sub("/Leaf", "_pre/Leaf", out_path)
            eng.leaf_annotation_run(
                in_path, label_path, out_path, self.beta, nargout=0
            )

    def post_test(self, data):
        super(Model, self).post_test(data)
        shutil.rmtree(self.blob_detector.results_path)
        os.rmdir(os.path.dirname(self.blob_detector.results_path))

    def make_blob_detector(self, run_id):
        model = BlobDetectionModel(run_id)
        config_path = model.config_path
        config_path = re.sub("_pre", "", config_path)
        config_path = re.sub("annotation", "blob", config_path)
        config_path = re.sub("_train", "", config_path)
        config_path = re.sub("-dry", "", config_path)
        with open(os.path.join(config_path, "config.json")) as f:
            config = json.load(f)
        model.load_config(config)
        return model
