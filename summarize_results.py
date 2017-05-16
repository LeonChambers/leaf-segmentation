#!/usr/bin/env python
import os.path
import math
import json
import argparse

models = ["blob", "annotation", "ris"]
experiments = ["cross", "combined"]
datasets = ["Ara2012", "Ara2013-Canon", "Tobacco"]

# Where the test set starts for each dataset
min_test_numbers = {
    "Ara2012": 81,
    "Ara2013-Canon": 111,
    "Tobacco": 42
}

def summarize_results(reports_paths):
    return {
        model:model_results(model, reports_paths) for model in models
    }

def model_results(model, reports_paths):
    return {
        experiment:experiment_results(model, experiment, reports_paths) for
        experiment in experiments
    }

def experiment_results(model, experiment, reports_paths):
    run_id = "{}-{}".format(model, experiment)
    return {
        "timing": timing_results(run_id, reports_paths),
        "performance": performance_results(run_id, reports_paths)
    }

def timing_results(run_id, reports_paths):
    train_total = 0
    test_total = 0
    count = 0
    for reports_path in reports_paths:
        timing_path = os.path.join(
            reports_path, run_id, "Leaf_segmentation", "timing.json"
        )
        if os.path.isfile(timing_path):
            with open(timing_path, "r") as f:
                res = json.load(f)
            train_total += res["train"]
            test_total += res["test"]
            count += 1
        else:
            print "No timing report found for {} in {}".format(
                run_id, reports_path
            )
    return {
        "train": train_total/count,
        "test": test_total/count
    }

def performance_results(run_id, reports_paths):
    return {
        dataset:dataset_performance_results(run_id, reports_paths, dataset) for
        dataset in datasets
    }

def dataset_performance_results(run_id, reports_paths, dataset):
    SBD_values = []
    FGBD_values = []
    AbsDIC_values = []
    DIC_values = []

    for reports_path in reports_paths:
        report_path = os.path.join(
            reports_path, run_id, "Leaf_segmentation",
            "Leaf_segmentation_{}_results.csv".format(dataset)
        )
        if os.path.isfile(report_path):
            with open(report_path, "r") as f:
                f.readline()
                f.readline()
                f.readline()
                while True:
                    line = f.readline().strip()
                    terms = line.split(", ")
                    number = int(terms[0])
                    if number == min_test_numbers[dataset]:
                        break
                while line:
                    int(terms[0])
                    SBD_values.append(float(terms[1]))
                    FGBD_values.append(float(terms[2]))
                    AbsDIC_values.append(int(terms[3]))
                    DIC_values.append(int(terms[4]))
                    line = f.readline().strip()
                    terms = line.split(", ")
        else:
            print "No report found for {} and {} in {}".format(
                dataset, run_id, reports_path
            )

    return {
        "SBD": calculate_stats(SBD_values),
        "FGBD": calculate_stats(FGBD_values),
        "AbsDIC": calculate_stats(AbsDIC_values),
        "DIC": calculate_stats(DIC_values)
    }

def calculate_stats(vals):
    mean = sum(vals)/float(len(vals))
    variance = sum([(x-mean)**2 for x in vals])/float(len(vals))
    std_dev = math.sqrt(variance)
    return {
        "mean": mean,
        "std_dev": std_dev
    }

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("reports_paths", nargs="+")
    args = parser.parse_args()
    print json.dumps(
        summarize_results(args.reports_paths), sort_keys=True, indent=4
    )
