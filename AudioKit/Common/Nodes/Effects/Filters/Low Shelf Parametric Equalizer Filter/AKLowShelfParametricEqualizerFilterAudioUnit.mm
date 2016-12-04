//
//  AKLowShelfParametricEqualizerFilterAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKLowShelfParametricEqualizerFilterAudioUnit.h"
#import "AKLowShelfParametricEqualizerFilterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKLowShelfParametricEqualizerFilterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKLowShelfParametricEqualizerFilterDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setCornerFrequency:(float)cornerFrequency {
    _kernel.setCornerFrequency(cornerFrequency);
}
- (void)setGain:(float)gain {
    _kernel.setGain(gain);
}
- (void)setQ:(float)q {
    _kernel.setQ(q);
}

- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (BOOL)isPlaying {
    return _kernel.started;
}

- (BOOL)isSetUp {
    return _kernel.resetted;
}

- (void)createParameters {

    // Initialize a default format for the busses.
    self.defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:AKSettings.sampleRate
                                                                        channels:AKSettings.numberOfChannels];

    // Create a DSP kernel to handle the signal processing.
    _kernel.init(self.defaultFormat.channelCount, self.defaultFormat.sampleRate);

    // Create a parameter object for the cornerFrequency.
    AUParameter *cornerFrequencyAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"cornerFrequency"
                                              name:@"Corner Frequency (Hz)"
                                           address:cornerFrequencyAddress
                                               min:12.0
                                               max:20000.0
                                              unit:kAudioUnitParameterUnit_Hertz
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the gain.
    AUParameter *gainAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"gain"
                                              name:@"Gain"
                                           address:gainAddress
                                               min:0.0
                                               max:10.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];
    // Create a parameter object for the q.
    AUParameter *qAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"q"
                                              name:@"Q"
                                           address:qAddress
                                               min:0.0
                                               max:2.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];


    // Initialize the parameter values.
    cornerFrequencyAUParameter.value = 1000;
    gainAUParameter.value = 1.0;
    qAUParameter.value = 0.707;

    self.rampTime = AKSettings.rampTime;

    _kernel.setParameter(cornerFrequencyAddress, cornerFrequencyAUParameter.value);
    _kernel.setParameter(gainAddress,            gainAUParameter.value);
    _kernel.setParameter(qAddress,               qAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        cornerFrequencyAUParameter,
        gainAUParameter,
        qAUParameter
    ]];

    // Make a local pointer to the kernel to avoid capturing self.
    __block AKLowShelfParametricEqualizerFilterDSPKernel *equalizerKernel = &_kernel;

    // implementorValueObserver is called when a parameter changes value.
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        equalizerKernel->setParameter(param.address, value);
    };

    // implementorValueProvider is called when the value needs to be refreshed.
    _parameterTree.implementorValueProvider = ^(AUParameter *param) {
        return equalizerKernel->getParameter(param.address);
    };

    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;

        switch (param.address) {
            case cornerFrequencyAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case gainAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            case qAddress:
                return [NSString stringWithFormat:@"%.3f", value];

            default:
                return @"?";
        }
    };

    _inputBus.init(self.defaultFormat, 8);
    self.inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                busType:AUAudioUnitBusTypeInput
                                                                 busses:@[_inputBus.bus]];
}

AUAudioUnitOverrides(LowShelfParametricEqualizerFilter);

@end


