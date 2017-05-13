import os.path
import json

top_level_dir = os.path.dirname(os.path.dirname(__file__))

class Dataset(object):
    def images(self, run_id):
        raise NotImplementedError()

class SimpleDataset(Dataset):
    def __init__(self, folder_name, file_prefix, num_images):
        self.folder_name = folder_name
        self.file_prefix = file_prefix
        self.num_images = num_images
        self.name = folder_name
        self.data_dir = os.path.join(
            top_level_dir, "data", "Leaf_segmentation", self.folder_name
        )

        counts_path = os.path.join(self.data_dir, "leaf_counts.json")
        with open(counts_path, "r") as f:
            self.leaf_counts = json.load(f)

    def images(self, output_folder):
        results_dir = os.path.join(
            top_level_dir, "results", output_folder, "Leaf_segmentation",
            self.folder_name
        )
        return [
            (
                # Input file name
                os.path.join(
                    self.data_dir,
                    "{}_plant{:03d}_rgb.png".format(self.file_prefix, i)
                ),
                # Output file name
                os.path.join(
                    results_dir,
                    "{}_plant{:03d}_label.png".format(self.file_prefix, i)
                )
            ) for i in range(1, self.num_images+1)
        ]

class SubsetDataset(Dataset):
    """
    A dataset consists of a subset of the images from another source
    dataset
    """
    def __init__(self, source, start, end):
        self.folder_name = source.folder_name
        self.name = source.name + "_{}-{}".format(start, end)
        self.leaf_counts = source.leaf_counts
        self.source = source
        self.start = start
        self.end = end

    def images(self, output_folder):
        return self.source.images(output_folder)[self.start:self.end]

class CombinedDataset(Dataset):
    def __init__(self, name, *datasets):
        self.name = name
        self.datasets = datasets

        leaf_counts = {}
        for dataset in datasets:
            leaf_counts.update(dataset.leaf_counts)
        self.leaf_counts = leaf_counts

    def images(self, output_folder):
        return [
            i for dataset in self.datasets
            for i in dataset.images(output_folder)
        ]
