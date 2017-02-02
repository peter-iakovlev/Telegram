//
// Created by Grishka on 15.06.16.
//

#ifndef LIBTGVOIP_MEDIASTREAMINPUT_H
#define LIBTGVOIP_MEDIASTREAMINPUT_H

#include <string.h>

class CMediaStreamItf{
public:
	virtual void Start()=0;
	virtual void Stop()=0;
	void SetCallback(size_t (*f)(unsigned char*, size_t, void*), void* param);

//protected:
	size_t InvokeCallback(unsigned char* data, size_t length);

private:
	size_t (*callback)(unsigned char*, size_t, void*);
	void* callbackParam;
};


#endif //LIBTGVOIP_MEDIASTREAMINPUT_H
