//
//  AKOscillatorAudioUnit.h
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKOscillatorAudioUnit_h
#define AKOscillatorAudioUnit_h

#import "AKAudioUnit.h"

@interface AKOscillatorAudioUnit : AKAudioUnit
@property (nonatomic) float frequency;
@property (nonatomic) float amplitude;
@property (nonatomic) float detuningOffset;
@property (nonatomic) float detuningMultiplier;

- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;

@end

#endif /* AKOscillatorAudioUnit_h */
