from openCVModuls cimport *
from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "../../../imageCropper/cropper.h" namespace "ImageCropper":
    cdef cppclass CROPPER:
        # private:
            Mat bImage;
            vector[Mat] images;
            vector[string] dirs;
            void loadImages();
            Mat cropImage(Mat&image, Range start, Range end);
            void onMouse(int event, int x, int y, int flags, void*param);
            
        # public:
            CROPPER(const char * file, const char * type, int size) except +
            void showImagePixels(int howManyImgs);
            vector[Mat] getImgArr()
            Mat getImage()
            vector[string] getFilenames()
            void cropAllImages(vector[Mat]&imgs, Range start, Range end, char c, char p);