from lib.PyImgCropper cimport *
from libcpp.cast cimport reinterpret_cast
from numpy import ndarray, dstack, asarray, float32, uint8, int32, ascontiguousarray
from numpy cimport ndarray, uint8_t, int32_t
from cython cimport boundscheck, wraparound

cdef class PyCropper:
    cdef:
        vector[string] _filenames
        vector[Mat] _images
        CROPPER * _cropper
    
    def __cinit__(self, const char * file, const char * type, int ext):
        self._cropper = new CROPPER(file, type, ext )
        self._filenames = self._cropper.getFilenames()

    @boundscheck(False)
    @wraparound(False)   
    cdef list[str] _getFilenames(self):
        cdef:
            size_t size
            int i
        output = []
        size = self._filenames.size()
        for i in range(size):
            output.append(self._filenames[i])
        return output

    @boundscheck(False)
    @wraparound(False)
    cdef void _cropAllImages(self, vector[Mat]&imgs, Range start, Range end, char c, char p):
        self._cropper.cropAllImages(imgs, start, end, c, p)
    
    @boundscheck(False)
    @wraparound(False)
    cdef void _py_crop_images(self, ndarray[int32_t, ndim=1] start, ndarray[int32_t, ndim=1] end, char c, char p):


        cdef ndarray[int32_t, ndim=1, mode = 'c'] _start_buff = ascontiguousarray(start, dtype=int32)
        cdef int * start_buff = <int*> _start_buff.data

        cdef ndarray[int32_t, ndim=1, mode = 'c'] _end_buff = ascontiguousarray(end, dtype=int32)
        cdef int * end_buff = <int*> _end_buff.data

        if (c ==  108 or c == 76 or c == 114 or c == 82):
            self._cropAllImages(self._images, Range(start_buff[0], start_buff[1]), Range(end_buff[0], end_buff[1]), c, p)
        else:
            raise Exception("  c = {} and p = {} values are not available. 'l' or 'L' and 'r' and 'R' as c values are admited")
        
        
    @boundscheck(False)
    @wraparound(False)
    cdef ndarray[uint8_t, ndim=4] _crop_images(self, ndarray[int32_t, ndim=1] start, ndarray[int32_t, ndim=1] end, char c, char p):
        
        cdef:
            int i

        output = []

        self._py_crop_images(start, end, c, p)

        assert self._images.size() > 0, "the size of images is NULL"

        for i in range(self._images.size()):
            output.append(self.Mat2np(self._images[i]))
        
        return asarray(output, dtype=uint8)


    @boundscheck(False)
    @wraparound(False)
    cdef inline object Mat2np(self, Mat m):
        # Create buffer to transfer data from m.data
        cdef Py_buffer buf_info

        # Define the size / len of data
        cdef size_t len = m.rows*m.cols*m.elemSize() # m.channels()*sizeof(CV_8UC3)

        # Fill buffer
        PyBuffer_FillInfo(&buf_info, NULL, m.data, len, 1, PyBUF_FULL_RO)

        # Get Pyobject from buffer data
        Pydata  = PyMemoryView_FromBuffer(&buf_info)

        # Create ndarray with data
        # the dimension of the output array is 2 if the image is grayscale
        if m.channels() >1 :
            shape_array = (m.rows, m.cols, m.channels())
        else:
            shape_array = (m.rows, m.cols)

        if m.depth() == CV_32F :
            ary = ndarray(shape=shape_array, buffer=Pydata, order='c', dtype=float32)
        else :
            #8-bit image
            ary = ndarray(shape=shape_array, buffer=Pydata, order='c', dtype=uint8)

        if m.channels() == 3:
            # BGR -> RGB
            ary = dstack((ary[...,2], ary[...,1], ary[...,0]))

        # Convert to numpy array
        pyarr = asarray(ary)
        return pyarr


    def crop_images(self, start, end, c, p):   
        return self._crop_images(asarray(start, dtype=int32), asarray(end, dtype=int32), c, p)

    def show_original_images(self, howMany):
        return self._cropper.showImagePixels(howMany)

    def directories(self):
        return self._getFilenames()