function bee = createBee(id)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% Function    : createBee
% Description : Create one Bee object with initialized rule structure
%
% Input
%   id : Bee identification number
%
% Output
%   bee : Bee structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Validation
if nargin~=1
    error('createBee requires one input argument.');
end

%% Rule Structure
rule = struct( ...
    'LowerBound', [], ...
    'UpperBound', [], ...
    'ActiveFeature', [], ...
    'Length', 0, ...
    'Class', [], ...
    'CoverageMask', [], ...
    'CoveredIndex', [], ...
    'Coverage', 0, ...
    'Quality', 0, ...
    'Confidence', 0, ...
    'Support', 0, ...
    'Fitness', 0);

%% Bee Structure
bee = struct();

bee.ID = id;

bee.Rule = rule;

%% Adaptive Components (Future D-B4M)

bee.Diversity = 0;

bee.Entropy = 0;

bee.LocalSearch = false;

bee.NeighborhoodRadius = 0;

bee.MutationRate = 0;

%% Bee State

bee.Rank = 0;

bee.Trial = 0;

bee.Age = 0;

bee.EliteFlag = false;

bee.Active = true;

end