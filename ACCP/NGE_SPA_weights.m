function W = NGE_SPA_weights
% WW is 27x56
% This 1:27 rows map to the weight index.
%4pltf x (12 rev + std + mean)
% This matrix of mean weights was copied from cell 4,BE:56,BH tab NLP-DRS

ww_means = [...
3.6	3.64	3.6	3.6
3.59	3.63	3.59	3.59
3.59	3.63	3.59	3.59
3.57	3.61	3.56	3.56
4.79	4.79	4.79	4.79
4.38	4.38	4.38	4.38
3.65	3.65	3.65	3.65
3.63	3.63	3.63	3.63
4.18	4.18	4.18	4.18
4.88	4.88	4.88	4.88
4.28	4.28	4.28	4.28
4.46	4.46	4.46	4.46
4.33	4.41	4.37	4.37
4.92	4.92	4.92	4.91
4.25	4.25	4.21	4.21
3.4	3.4	3.4	3.57
3.28	3.28	3.28	3.28
3.28	3.28	3.28	3.28
4.67	4.67	4.67	4.67
4.39	4.48	4.39	4.39
4.49	4.49	4.33	4.33
4.28	4.32	4.19	4.19
4.67	4.67	4.67	4.67
4.67	4.67	4.67	4.67
4	4	3.88	3.88
4.92	4.92	4.92	4.92
4.92	4.92	4.92	4.92];
gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73];
W = NaN([73,4]);
W(gv,:) = ww_means(map_ACCP_gv_to_wi(gv),:);

return