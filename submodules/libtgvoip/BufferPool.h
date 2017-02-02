//
// Created by Grishka on 10.09.16.
//

#ifndef LIBTGVOIP_BUFFERPOOL_H
#define LIBTGVOIP_BUFFERPOOL_H

#include <stdint.h>
#include "threading.h"

class CBufferPool{
public:
	CBufferPool(unsigned int size, unsigned int count);
	~CBufferPool();
	unsigned char* Get();
	void Reuse(unsigned char* buffer);

private:
	uint64_t usedBuffers;
	int bufferCount;
	unsigned char* buffers[64];
	tgvoip_mutex_t mutex;
};


#endif //LIBTGVOIP_BUFFERPOOL_H
