// compute_running_mean.h  API for compute_running_mean.h

#if !defined(COMPUTE_RUNNING_MEAN_H__F341724A_20FE_4567_A43E_78E8CF20959D__INCLUDED_)
#define COMPUTE_RUNNING_MEAN_H__F341724A_20FE_4567_A43E_78E8CF20959D__INCLUDED_

#ifdef	__cplusplus

extern "C"	{

#endif // ifdef	__cplusplus

float *compute_running_mean(float * data,int n,int half_window_size,int * min_index);




#ifdef	__cplusplus

}

#endif // ifdef	__cplusplus
#endif // if !defined(COMPUTE_RUNNING_MEAN_H__F341724A_20FE_4567_A43E_78E8CF20959D__INCLUDED_)