function rule = generateRule(lowerBound, upperBound, classID, dataset)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% Function : generateRule
% Purpose  : Build classification rule from interval representation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Validation

if nargin ~= 4
    error('generateRule requires 4 input arguments.');
end

nFeature = dataset.nFeatures;

if length(lowerBound) ~= nFeature
    error('LowerBound dimension mismatch.');
end

if length(upperBound) ~= nFeature
    error('UpperBound dimension mismatch.');
end

%% Ensure interval consistency

lowerBound = min(lowerBound,upperBound);
upperBound = max(lowerBound,upperBound);

%% Active Feature Detection

activeFeature = upperBound > lowerBound;

ruleLength = nnz(activeFeature);

%% Build Rule

rule = struct();

rule.LowerBound = lowerBound;
rule.UpperBound = upperBound;

rule.ActiveFeature = activeFeature;

rule.Length = ruleLength;

rule.Class = classID;

%% Evaluation Placeholder

rule.CoverageMask = [];

rule.CoveredIndex = [];

rule.Coverage = 0;

rule.Quality = 0;

rule.Fitness = 0;

end