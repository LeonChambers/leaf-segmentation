#!/usr/bin/env python2
import os.path
import json
import argparse

from models import available_models, get_model, experiments

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--model", choices=available_models, required=True)
    parser.add_argument("--skip-train", action='store_true')
    parser.add_argument("--dry", action='store_true')
    parser.add_argument(
        "-e", "--experiment", choices=experiments.keys(), required=True
    )
    args = parser.parse_args()

    run_id = args.model + "-" + args.experiment
    if args.dry:
        run_id += '-dry'

    model = get_model(args.model, run_id, dry=args.dry)

    training_dataset, testing_dataset = experiments[args.experiment]

    results = {}

    if args.skip_train:
        print "Skipping training step"
    else:
        print "Training on dataset {}".format(training_dataset.name)
        train_time = model.run_train(training_dataset)
        print "Trained model in {} seconds".format(train_time)
    print "Testing on dataset {}".format(testing_dataset.name)
    test_time = model.run_test(testing_dataset)
    print "Ran test in {} seconds".format(test_time)
    model.evaluate()

    timings = {}
    if not args.skip_train:
        timings["train"] = train_time
    timings["test"] = test_time

    print "Writing timing report to disk"
    model.update_timing_report(timings)
