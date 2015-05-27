// estimate_noise_floor.h  API for estimate_noise_floor.h

#if !defined(ESTIMATE_NOISE_FLOOR_H__F341724A_20FE_4567_A43E_78E8CF20959D__INCLUDED_)
#define ESTIMATE_NOISE_FLOOR_H__F341724A_20FE_4567_A43E_78E8CF20959D__INCLUDED_

#ifdef	__cplusplus

extern "C"	{

#endif // ifdef	__cplusplus



void estimate_noise_floor(float * raw_power, int firstgate, int lastgate, int window_size,
                          int * min_gate, float * mean_noise, float * std_noise);


#ifdef	__cplusplus

}

#endif // ifdef	__cplusplus
#endif // if !defined(ESTIMATE_NOISE_FLOOR_H__F341724A_20FE_4567_A43E_78E8CF20959D__INCLUDED_)