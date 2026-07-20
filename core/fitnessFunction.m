function bee = fitnessFunction(bee,cfg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% FITNESS FUNCTION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin~=2
    error('fitnessFunction requires bee and cfg.');
end

%% Rule Information

quality = bee.Rule.Quality;
support = bee.Rule.Support;

%% Default Weights

wQuality = cfg.weightQuality;
wSupport = cfg.weightSupport;

%% Fitness

fitness = ...
    wQuality * quality + ...
    wSupport * support;

%% Save

bee.Rule.Fitness = fitness;

end