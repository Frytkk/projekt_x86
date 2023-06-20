#include "bmp.h"
#include "sepia.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char* makeSepiaFileName(int fileId) {
    static char buff[20];
    sprintf(buff, "sepia%d.bmp", fileId);
    return buff;
}

void transformImage(const char* fileName, int fileId) {

    Bmp* img = readBmp(fileName);

    if(img != NULL) {
        sepiaBmp(img);
        writeBmp(img, makeSepiaFileName(fileId));
        freeBmp(img);
    }
    
}

int main(int argc, char* argv[]) {
    for(int i = 1; i < argc; ++i) {
        transformImage(argv[i], i);
    }
}
