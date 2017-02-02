//
// Created by Grishka on 02.06.16.
//

#ifndef LIBTGVOIP_AUDIOINPUTAUDIOUNIT_H
#define LIBTGVOIP_AUDIOINPUTAUDIOUNIT_H

#include <AudioUnit/AudioUnit.h>
#include "../../audio/AudioInput.h"

class CAudioUnitIO;

class CAudioInputAudioUnit : public CAudioInput{

public:
	CAudioInputAudioUnit(CAudioUnitIO* io);
	virtual ~CAudioInputAudioUnit();
	virtual void Configure(uint32_t sampleRate, uint32_t bitsPerSample, uint32_t channels);
	virtual void Start();
	virtual void Stop();
	void HandleBufferCallback(AudioBufferList* ioData);

private:
	unsigned char remainingData[10240];
	size_t remainingDataSize;
	bool isRecording;
	CAudioUnitIO* io;
};


#endif //LIBTGVOIP_AUDIOINPUTAUDIOUNIT_H
