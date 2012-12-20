//
//  GameConstant.h
//  PlantHD
//
//  Created by Kelvin Chan on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef PlantHD_GameConstant_h
#define PlantHD_GameConstant_h

// About tree
#define t_h (6.0f)      // Half-life of tree health
#define h_0 (5.0f)      // initial health amt of tree
#define h_dead (0.001f) // 

#define S_MAX (1.0f)    // Max. intensity of sunlight

#define t_s (20.f)      // length of season to shoot for...

#define F_opt (1.0f)    // optimal benefit of water and compose

// About water
#define w_0 (0.5f)      // initial vol of water
#define t_w (5.0f)      // Half-life of water
#define w_dead (0.001f) // water dies and deallocates

// About compost
#define c_0 (0.5f)      // initial vol of compose
#define t_c (10.0f)      // Half-life of compost
#define c_dead (0.001f) // compost dies and deallocates


#define lambda (1.0f)   // toxicity factor of too much compost or water

// Note: 
// Theoretical max: maturity ~ 1000
//                  health = 8.66

#define CHECKCORRECTNESSNOTIFICATIONNAME @"CheckCorrectnessNotification"


#endif
