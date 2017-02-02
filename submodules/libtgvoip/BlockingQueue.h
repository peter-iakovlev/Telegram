//
// Created by Grishka on 01.06.16.
//

#ifndef LIBTGVOIP_BLOCKINGQUEUE_H
#define LIBTGVOIP_BLOCKINGQUEUE_H

#include <stdlib.h>
#include <list>
#include "threading.h"

using namespace std;

class CBlockingQueue{
public:
	CBlockingQueue(size_t capacity);
	~CBlockingQueue();
	void Put(void* thing);
	void* GetBlocking();
	void* Get();
	unsigned int Size();
	void PrepareDealloc();

private:
	void* GetInternal();
	list<void*> queue;
	size_t capacity;
	tgvoip_lock_t lock;
	tgvoip_mutex_t mutex;
};


#endif //LIBTGVOIP_BLOCKINGQUEUE_H
