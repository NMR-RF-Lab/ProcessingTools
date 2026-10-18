% SDEAL deals out values to fields of a structure array
% S = sDeal(S,fields,values,dim,I)
%
% Inputs:
%   - S: structure
%   - F: field(s)
%   - V: values
%   - d: dimension to operate along. Currently only allows for 2D structures
%   - I: (optional) index for non-operating dimension
function S = sDeal(S,F,V,d,I)

% Parse inputs
p = inputParser;

addRequired(p, 'S', @(x) isstruct(x))
addRequired(p, 'F', @(x) isstring(x))
addRequired(p, 'V', @(x) iscell(x))
addRequired(p, 'd', @(x) (isnumeric(x) && isscalar(x) && round(x)==x && x>0))
addOptional(p, 'I', 1, @(x) (isnumeric(x) && isscalar(x) && round(x)==x && x>0))

parse(p,S,F,V,d,I);

% Extract from parser
S = p.Results.S;
F = p.Results.F;
V = p.Results.V;
d = p.Results.d;
I = p.Results.I;

switch d % sub-for loops for efficiency
    case 1
        for f = 1:numel(F)
            for i = 1:numel(V{f})
                S(i,I).(F(f)) = V{f}(i);
            end
        end
    case 2
        for f = 1:numel(F)
            for i = 1:numel(V{f})
                S(I,i).(F(f)) = V{f}(i);
            end
        end
    otherwise
        error('Function can only handle 2D structures! Please add more functionality.')
end
end