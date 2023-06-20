#include "bmp.h"

#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

static void readError(FILE* file, Bmp* bmp, const char* format, ...);
static bool readHeader(FILE* file, BmpHeader* header);
static bool initImage(Bmp* image, const BmpHeader* header);

Bmp* readBmp(const char* fileName) {

    FILE* file = fopen(fileName, "rb");
    Bmp* image = malloc(sizeof(Bmp));

    if(file == NULL || image == NULL) {
        readError(file, image, "Couldn't open \"%s\"\n", fileName);
        return NULL;
    }

    BmpHeader header;
    if(!readHeader(file, &header)) {
        readError(file, image, "Couldn't read header of \"%s\"\n", fileName);
        return NULL;
    }

    if(!initImage(image, &header)) {
        readError(file, image, "Couldn't load pixel map of \"%s\"\n", fileName);
        return NULL;
    }

    int imageByteWidth = image->width*3;
	unsigned char* bytes = image->bytes;
    const int paddingSize = abs(((imageByteWidth + 3) / 4) * 4) - imageByteWidth;

	if(image->height > 0) {
		bytes += imageByteWidth * (image->height - 1);
		imageByteWidth = -imageByteWidth;
	} else {
		image->height = -image->height;
    }

	if(fseek(file, header.arrayOffset, SEEK_SET) != 0) {
        readError(file, image, "Unable to find pixel array in \"%s\"\n", fileName);
        return NULL;
    }

    const size_t absImageByteWidth = abs(imageByteWidth);
	for(int i = 0; i < image->height; ++i, bytes += imageByteWidth) {

        if(fread(bytes, 1, absImageByteWidth, file) < absImageByteWidth) {
            readError(file, image, "Unable to read pixel array in \"%s\"\n", fileName);
            return NULL;
        }

        for(int i = 0; i < paddingSize; ++i) {
            getc(file);
        }
		
	}

    fclose(file);
    return image;

}

static void readError(FILE* file, Bmp* bmp, const char* format, ...) {

    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);

    free(bmp);
    if(file != NULL) {
        fclose(file);
    }

}

static bool readHeader(FILE* file, BmpHeader* header) {
    return
        fread(header, sizeof(BmpHeader), 1, file) > 0 &&
        header->type == 0x4D42 &&
        header->width > 0 &&
        header->height > 0 &&
        header->bpp == 24;
}

static bool initImage(Bmp* image, const BmpHeader* header) {

    image->width = header->width;
    image->height = header->height;
    image->bytes = malloc(image->width * image->height * 3);

    return 
        image->bytes != NULL &&
        image->width > 0 &&
        image->height > 0;

}

void writeBmp(const Bmp* image, const char* fileName) {

    FILE* file = fopen(fileName, "wb");
    if(file == NULL) {
        fprintf(stderr, "Could't create/open \"%s\" file\n", fileName);
        return;
    }

    const int imageByteSize = image->width*3;
    const int lineSize = ((imageByteSize + 3) / 4) * 4;
    const int paddingSize = lineSize - imageByteSize;

    const BmpHeader header = {

        .type = 0x4D42,
        .fileSize = sizeof(BmpHeader),
        .reserved1 = 0,
        .reserved2 = 0,
        .arrayOffset = sizeof(BmpHeader),

        .headerSize = 40,
        .width = image->width,
        .height = image->height,
        .colorPlanes = 1,
        .bpp = 24,
        .compression = 0,
        .imageSize = lineSize * image->height,
        .xPpm = 11811,
        .yPpm = 11811,
        .colorTableSize = 0,
        .importantColorCount = 0

    };

    if(fwrite(&header, sizeof(BmpHeader), 1, file) != 1) { 
        fprintf(stderr, "Couldn't write bmp header to \"%s\"\n", fileName);
        fclose(file);
        return;
    }

    unsigned char* bytes = image->bytes + imageByteSize*(image->height - 1);
    for(int i = image->height; i--; bytes -= imageByteSize){

        const int writtenBytes = fwrite(bytes, 1, imageByteSize, file);
		if(writtenBytes != imageByteSize) {
            fprintf(stderr, "Couldn't write pixel table to \"%s\"\n", fileName);
			break;
		}

        for(int i = 0; i < paddingSize; ++i) {
            fputc('\0', file);
        }

    }

    fclose(file);

}

void freeBmp(Bmp* img) {
    free(img->bytes);
    free(img);
}
