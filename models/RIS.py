import re
from .base import LeafSegmentationModel

class Model(LeafSegmentationModel):
    def train(self, data):
        # write data_ and label_ lists
        images = data.images(self.run_id)
        data_list = [
            image[0] for image in images
        ]
        label_list = [
            re.sub("_rgb.png$", "_label.png", path) for path in data_list
        ]

        # Call the RIS code
        raise NotImplementedError()

    def test(self, data):
        raise NotImplementedError()
