//
// Created by Grishka on 02.06.16.
//

#include "AudioInput.h"
#if defined(__ANDROID__)
#include "../os/android/AudioInputAndroid.h"
#elif defined(__APPLE__)
#include "../os/darwin/AudioInputAudioUnit.h"
#include "../os/darwin/AudioUnitIO.h"
#else
#error "Unsupported operating system"
#endif

CAudioInput *CAudioInput::Create(){
#if defined(__ANDROID__)
	return new CAudioInputAndroid();
#elif defined(__APPLE__)
	return new CAudioInputAudioUnit(CAudioUnitIO::Get());
#endif
}


CAudioInput::~CAudioInput(){
#if defined(__APPLE__)
	CAudioUnitIO::Release();
#endif
}

