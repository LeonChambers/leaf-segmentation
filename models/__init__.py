from .dataset import SimpleDataset, CombinedDataset, SubsetDataset
from .BlobDetection import Model as BlobDetectionModel
from .RIS import ModelBuilder as RISModelBuilder

model_dict = {
    "blob": BlobDetectionModel,
    "ris_1_15": RISModelBuilder(1, 15),
    "ris_2_15": RISModelBuilder(2, 15),
    "ris_1_30": RISModelBuilder(1, 30),
    "ris_2_30": RISModelBuilder(2, 30)
}

available_models = model_dict.keys()

def get_model(model_name, run_id, **kwargs):
    return model_dict[model_name](run_id, **kwargs)

Ara2012 = SimpleDataset("Ara2012_preprocessed", "ara2012", 120)
Ara2013 = SimpleDataset("Ara2013-Canon_preprocessed", "ara2013", 165)
Tobacco = SimpleDataset("Tobacco_preprocessed", "tobacco", 62)

Ara2012_train = SubsetDataset(Ara2012, 0, 80)
Ara2012_test = SubsetDataset(Ara2012, 80, 120)

Ara2013_train = SubsetDataset(Ara2012, 0, 110)
Ara2013_test = SubsetDataset(Ara2013, 110, 165)

Tobacco_train = SubsetDataset(Tobacco, 0, 41)
Tobacco_test = SubsetDataset(Tobacco, 41, 62)

Combined_train = CombinedDataset(
    "Combined_train", Ara2012_train, Ara2013_train, Tobacco_train
)
Combined_test = CombinedDataset(
    "Combined_test", Ara2012_test, Ara2013_test, Tobacco_test
)

Cross_train = Ara2012_train
Cross_test = CombinedDataset(
    "Cross_test", Ara2012_test, Ara2013_test, Tobacco_test
)

experiments = {
    "cross": (Cross_train, Cross_test),
    "combined": (Combined_train, Combined_test),
    "ara2012": (Ara2012_train, Ara2012_test),
    "ara2013": (Ara2013_train, Ara2013_test),
    "tobacco": (Tobacco_train, Tobacco_test),
}
