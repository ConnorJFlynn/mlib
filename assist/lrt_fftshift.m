function [ shiftedIgram ] = lrt_fftshift( igram, zpdIndex )
%LRT_FFTSHIFT Summary of this function goes here
%   Detailed explanation goes here

    shiftedIgram = vertcat(igram(zpdIndex:end, :), igram(1:zpdIndex-1, :));
end

