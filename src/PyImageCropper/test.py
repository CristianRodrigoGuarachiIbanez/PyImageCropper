from pyCropper import PyCropper
from zipfile import ZipFile
import sys
import os, shutil
import numpy as np
import matplotlib.pyplot as plt 
import h5py as h5

class FileManager:
    def __init__(self, fname) -> None:
        self._dirFiles = fname
        self._zipFiles = list()
        self._lImages = np.empty(0)
        self._rImages = np.empty(0)
    
    def _reset(self, dir_path, type, ext ):
        self._cropper = PyCropper(dir_path, type, ext)

    def _collectImages(self, dir, start, end, c, p):
        imgCropper = PyCropper(dir, b".png", 4)
        return imgCropper.crop_images(start, end, ord(c), ord(p)) 

    @staticmethod
    def _writer(path, group, dataset, data):
        with h5.File(path, "w") as container:
            g=container.create_group(group)
            g.create_dataset(dataset, data=data)

    @staticmethod
    def _append(arr1, arr2):
        return np.append(arr1, arr2, axis=0)
    
    def _zipfile(self, path, fname, start, end):
        self._reset(dir_path=path, type=b".zip", ext=4)
        _zipFiles = self._cropper.directories()
        for i in range(len(_zipFiles)):
            with ZipFile(_zipFiles[i].decode("utf-8"), "r") as archive:
                for filename in archive.namelist():
                    file = filename.split("/")
                    if file[0] == fname:
                        archive.extract(filename)
            path = os.getcwd() + "/" + fname
            if os.path.exists(path):
                lImgs = self._collectImages(path.encode("utf-8"), start, end, "l", "n")
                rImgs = self._collectImages(path.encode("utf-8"), [120, 386], [548, 900], "r", "n")
                shutil.rmtree(path)
                if self._lImages.size != 0:
                    self._lImages = self._append(self._lImages, lImgs)                    
                else:
                    self._lImages = lImgs[:]
                
                if self._rImages.size != 0:
                    self._rImages = self._append(self._rImages, rImgs)   
                else:
                    self._rImages = rImgs[:]
                
                print(self._lImages.shape)

            if i == 1:
                sys.exit()

    def _show_images(self, howMany):
       self._cropper.show_original_images(2)  

    def query(self, dir_path=b"../../../image_outputs/", type = b".png", ext =4):
        self._reset(dir_path, type, ext)
    
    def zipQuery(self, path, start=[120, 386], end=[548, 900]):
        self._zipfile(path, self._dirFiles, start, end)

    def directories(self):
        return self._cropper.directories()
    
    def left_images(self):
        return self._lImages
    
    def right_images(self):
        return self._rImages
    
    def write(self, path, group, dataset):

        if group == "left_images":
            self._writer(path, group, dataset, self._lImages)
        else:
            self._writer(path, group, dataset, self._rImages)


# l = 108 | L = 76
# r = 114 | R = 82
# n = 110
# j = 106 | J = 74



if __name__ == "__main__":
    fm = FileManager("image_outputs")
    #fm.query(b"/home/cristian/PycharmProjects/trial_manager/IMG/trials", b".zip", 4)
    #print(fm.directories())
    fm.zipQuery(b"/home/cristian/PycharmProjects/trial_manager/IMG/trials")

    left = fm.left_images()
    print("images -> ", left.shape)

    right = fm.right_images()
    print("images -> ", right.shape)