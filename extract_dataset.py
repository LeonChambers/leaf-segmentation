#!/usr/bin/env python
import shutil
import matlab.engine
import zipfile

if __name__ == '__main__':
    print "Extracting zip file"
    zip_ref = zipfile.ZipFile('./Plant_Phenotyping_Datasets.zip', 'r')
    zip_ref.extractall('./dataset')
    zip_ref.close()

    print "Building Leaf Segmentation dataset"
    eng = matlab.engine.start_matlab()
    eng.extract_dataset('./dataset', nargout=0)

    print "Cleaning up"
    shutil.rmtree('./dataset')
