function [new_gen,mating] = mate(old_gen)
%MATE   Randomly reorders (mates) OLD_GEN.
%	[NEW_GEN,MATING] = MATE(OLD_GEN) performs random reordering
%       on OLD_GEN.  NEW_GEN is the new reordering.  Individual in 
%       row 1 is to be mated with individual in row 2, etc.  MATING
%       is the reordering vector (ie: new_gen=old_gen(mating,:)).
%
%	Copyright (c) 1993 by the MathWorks, Inc.
%	Andrew Potvin 1-10-93.

[junk,mating] = sort(rand(size(old_gen,1),1));
new_gen = old_gen(mating,:);

% end mate
