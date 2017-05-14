import os
import re
from .base import LeafSegmentationModel

class Model(LeafSegmentationModel):
    def pre_train(self, data):
        # write data_ and label_ lists
        images = data.images(self.run_id)
        data_list = [
            image[0] for image in images
        ]
        with open("data_list.txt", "w+") as f:
            f.write("\n".join(data_list))
        label_list = [
            re.sub("_rgb.png$", "_label.png", path) for path in data_list
        ]
        with open("label_list.txt", "w+") as f:
            f.write("\n".join(label_list))

    def train(self, data):
        cmd = [
            "th", "../RIS/plants_learning/experiment.lua", "-name",
            self.run_id, "-height", 200, "-width", 200, "-data_dir", "."
        ]
        if self.dry:
            cmd.extend(["-it", "100"])

    def post_train(self, data):
        os.remove("data_list.txt")
        os.remove("label_list.txt")

    def test(self, data):
        raise NotImplementedError()
