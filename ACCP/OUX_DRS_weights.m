function W = OUX_DRS_weights
% WW is 27x56
% This 1:27 rows map to the weight index.
%4pltf x (12 rev + std + mean)
% This matrix of mean weights was copied from cell 4,BE:56,BH tab NLP-DRS

ww_means = [...
4.28	4.28	4.28	4.28
4.27	4.27	4.27	4.27
4.18	4.18	4.18	4.18
4.38	4.38	4.37	4.37
4.45	4.44	4.41	4.41
4.62	4.62	4.62	4.62
3.78	4.11	3.73	3.73
3.8	3.8	3.68	3.68
4.37	4.37	4.33	4.33
5	5	5	5
4.64	4.64	4.64	4.64
4.64	4.64	4.64	4.64
4.52	4.52	4.52	4.52
3.73	3.73	3.69	3.64
3.77	3.77	3.77	3.77
3.83	3.83	3.83	3.83
3.77	3.77	3.68	3.68
3.63	3.63	3.54	3.54
3.68	3.68	3.68	3.68
4.03	4.03	3.95	3.95
4.03	4.03	3.95	3.95
3.92	3.92	3.75	3.75
3.38	3.38	3.38	3.38
3.44	3.44	3.44	3.44
3.77	3.77	3.68	3.68
4.04	4.46	4.29	4.29
3.14	3.31	3.14	3.14];
gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73];
W = NaN([73,4]);
W(gv,:) = ww_means(map_ACCP_gv_to_wi(gv),:);

return