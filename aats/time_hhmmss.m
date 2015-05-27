function [hhmmss] = time_hhmmss(dechr)

secs = dechr/24 * 86400;
hr = fix(secs / 3600);
min = fix((secs - hr * 3600) / 60);
sec = fix(secs - hr * 3600 - min * 60);
hhmmss = hr*10000 + min*100 + sec;