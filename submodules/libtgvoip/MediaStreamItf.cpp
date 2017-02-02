//
// Created by Grishka on 15.06.16.
//

#include "MediaStreamItf.h"


void CMediaStreamItf::SetCallback(size_t (*f)(unsigned char *, size_t, void*), void* param){
	callback=f;
	callbackParam=param;
}

size_t CMediaStreamItf::InvokeCallback(unsigned char *data, size_t length){
	return (*callback)(data, length, callbackParam);
}
