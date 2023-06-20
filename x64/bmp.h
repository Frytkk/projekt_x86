#pragma once

#if defined(__BYTE_ORDER__)
#  if __BYTE_ORDER__ != __ORDER_LITTLE_ENDIAN__
#    error Unsupported endianness
#  endif
#elif !defined(_WIN32)
#  error Undetermined endianness
#endif

#include <stddef.h>
#include <stdint.h>

#pragma pack (2)

typedef struct BmpHeader {

    uint16_t type;
    uint32_t fileSize;
    uint16_t reserved1;
    uint16_t reserved2;
    uint32_t arrayOffset;

    uint32_t headerSize;
    int32_t width;
    int32_t height;
    uint16_t colorPlanes;
    uint16_t bpp;
    uint32_t compression;
    uint32_t imageSize;
    int32_t xPpm;
    int32_t yPpm;
    uint32_t colorTableSize;
    uint32_t importantColorCount;

} BmpHeader;

#pragma pack ()

typedef struct Bmp {

    int32_t width;
    int32_t height;
    uint8_t* bytes;

} Bmp;

Bmp* readBmp(const char* fileName);
void writeBmp(const Bmp* img, const char* fileName);
void freeBmp(Bmp* img);
