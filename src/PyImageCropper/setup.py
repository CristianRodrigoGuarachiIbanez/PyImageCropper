from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize
import numpy
import sys
import os
import glob


lib_folder = os.path.join("/usr", 'lib', "x86_64-linux-gnu")
filesys = os.path.join("/usr", "include", "c++")

cvlibs = list()
for file in glob.glob(os.path.join(lib_folder, 'libopencv_*')):
    cvlibs.append(file.split('.')[0])

fslibs = list()
for f in glob.glob(os.path.join(lib_folder, 'libstdc++*')):
    fslibs.append(f.split(".")[0])

print( cvlibs, fslibs)
cvlibs = ['-L{}'.format(lib_folder)] + ['opencv_{}'.format(lib.split(os.path.sep)[-1].split('libopencv_')[-1]) for lib in cvlibs] + ['{}fs'.format(lib.split(os.path.sep)[-1].split('lib')[-1])for lib in fslibs]

print("LIBS",cvlibs, fslibs)
print("FOLDER:", lib_folder, filesys)
setup(
    cmdclass={'build_ext': build_ext},
    ext_modules=cythonize(Extension("pyCropper",
                                    sources=["PyImgCropper.pyx", "../../cropper.cpp", "../../../directoryWalker/dirWalker.cpp"],
                                    language="c++",
                                    include_dirs=[numpy.get_include(),
                                                  os.path.join("/usr", 'include', 'opencv'), filesys,
                                                 ],
                                    library_dirs=[lib_folder, ],
                                    libraries=cvlibs,
                                    )
                          )
)