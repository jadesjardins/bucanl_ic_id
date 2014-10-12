function [val,ind]=findnear(vect,val)

[val,ind]=min(abs(vect-(val)));