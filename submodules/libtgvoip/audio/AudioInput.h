//
// Created by Grishka on 02.06.16.
//

#ifndef LIBTGVOIP_AUDIOINPUT_H
#define LIBTGVOIP_AUDIOINPUT_H

#include <stdint.h>
#include "../MediaStreamItf.h"

class CAudioInput : public CMediaStreamItf{
public:
	virtual ~CAudioInput();

	virtual void Configure(uint32_t sampleRate, uint32_t bitsPerSample, uint32_t channels)=0;
	static CAudioInput* Create();
};


#endif //LIBTGVOIP_AUDIOINPUT_H
