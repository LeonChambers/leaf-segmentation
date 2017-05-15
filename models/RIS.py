import os
import re
import shutil
import subprocess

from .base import LeafSegmentationModel

def ModelBuilder(rnn_layers, rnn_channels):
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
                "-seq_length", "20",
                "-learning_rate", "0.0002",
                "-rnn_layers", str(self.rnn_layers),
                "-rnn_channels", str(self.rnn_channels),
            ]
            if self.dry:
                cmd.extend(["-it", "10"])
                cmd.extend(["-summary_after", "10"])
            else:
                cmd.extend(["-it", "50000"])
            if subprocess.call(cmd, cwd=experiment_folder):
                raise ValueError("Failed to train model")

        def post_train(self, data):
            # Remove temporary files
            os.remove("data_list.txt")
            os.remove("label_list.txt")

            # Move config to config folder
            top_level_dir = os.path.dirname(os.path.dirname(__file__))
            config_dir = os.path.join(top_level_dir, "config")
            if not os.path.isdir(config_dir):
                os.makedirs(config_dir)
            if os.path.isdir(os.path.join(config_dir, self.run_id)):
                shutil.rmtree(os.path.join(config_dir, self.run_id))
            shutil.move(
                os.path.join(
                    top_level_dir, "RIS", "plants_learning", self.run_id
                ),
                config_dir
            )

        def pre_test(self, data):
            # Write input_ and output_list lists
            top_level_dir = os.path.dirname(os.path.dirname(__file__))
            images = data.images(self.run_id)
            input_list = [
                os.path.relpath(image[0], top_level_dir) for image in images
            ]
            output_list = [
                os.path.relpath(image[1], top_level_dir) for image in images
            ]
            with open("input_list.txt", "w+") as f:
                f.write("\n".join(input_list))
            with open("output_list.txt", "w+") as f:
                f.write("\n".join(output_list))

            self.prepare_output(data)

        def test(self, data):
            top_level_dir = os.path.dirname(os.path.dirname(__file__))
            config_path = os.path.join(top_level_dir, "config", self.run_id)
            cmd = [
                "th", "RIS_test.lua",
                "-name", self.run_id,
                "-data_dir", top_level_dir+"/",
                "-config_dir", config_path+"/",
                "-rnn_channels", str(self.rnn_channels),
                "-rnn_layers", str(self.rnn_layers)
            ]
            if subprocess.call(cmd, cwd=os.path.dirname(__file__)):
                raise ValueError("Failed to test model")

        def post_test(self, data):
            # Remove temporary files
            os.remove("input_list.txt")
            os.remove("output_list.txt")

    Model.rnn_layers = rnn_layers
    Model.rnn_channels = rnn_channels

    return Model
