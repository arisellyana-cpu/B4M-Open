function bee = evaluateRule(bee,dataset)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bee for Mining Open Version (B4M-Open)
%
% Function    : evaluateRule
% Description : Evaluate one classification rule
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Validation

if nargin~=2
    error('evaluateRule requires bee and dataset.');
end

X = dataset.X;
Y = dataset.Y;

nSample = dataset.nSamples;
nFeature = dataset.nFeatures;

rule = bee.Rule;

lower = rule.LowerBound;
upper = rule.UpperBound;

%% Coverage Mask

mask = true(nSample,1);

for j = 1:nFeature

    if rule.ActiveFeature(j)

        mask = mask & ...
              X(:,j)>=lower(j) & ...
              X(:,j)<=upper(j);

    end

end

%% Covered Samples

coveredIndex = find(mask);

coverage = numel(coveredIndex);

%% Support

support = coverage / nSample;

%% True Positive

tp = sum(Y(mask)==rule.Class);

%% False Positive

fp = coverage - tp;

%% Quality

if coverage==0

    quality = 0;
    confidence = 0;

else

    quality = tp / coverage;

    confidence = quality;

end

%% Save Rule

bee.Rule.CoverageMask = mask;

bee.Rule.CoveredIndex = coveredIndex;

bee.Rule.Coverage = coverage;

bee.Rule.Support = support;

bee.Rule.Quality = quality;

bee.Rule.Confidence = confidence;

end