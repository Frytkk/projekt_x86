#include "sepia.h"
#include <stdint.h>

void sepiaBmp(Bmp* image) {
    sepia(image->bytes, image->width, image->height);
}
