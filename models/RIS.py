import os
import re
import subprocess

from .base import LeafSegmentationModel

class Model(LeafSegmentationModel):
    def pre_train(self, data):
        # write data_ and label_ lists
        top_level_dir = os.path.dirname(os.path.dirname(__file__))
        images = data.images(self.run_id)
        data_list = [
            os.path.relpath(image[0], top_level_dir) for image in images
        ]
        with open("data_list.txt", "w+") as f:
            f.write("\n".join(data_list))
        label_list = [
            re.sub("_rgb.png$", "_label.png", path) for path in data_list
        ]
        with open("label_list.txt", "w+") as f:
            f.write("\n".join(label_list))

    def train(self, data):
        top_level_dir = os.path.dirname(os.path.dirname(__file__))
        experiment_folder = os.path.join(
            top_level_dir, "RIS", "plants_learning"
        )
        cmd = [
            "th", "experiment.lua",
            "-name", self.run_id, 
            "-data_dir", top_level_dir+"/",
            "-gpumode", "0",
            "-summary_after", "10"
        ]
        if self.dry:
            cmd.extend(["-it", "100"])
        if subprocess.call(cmd, cwd=experiment_folder):
            raise ValueError("Failed to train model")

    def post_train(self, data):
        os.remove("data_list.txt")
        os.remove("label_list.txt")

    def test(self, data):
        raise NotImplementedError()
