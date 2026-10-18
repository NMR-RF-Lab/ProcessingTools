% A2S converts a singular structure with array fields to a multidimensional
% structure of singular fields. Each field value must be the same size
% array.

function S = A2S(A)
fnames = fieldnames(A);
np = numel(A.(fnames{1}));

% Create structure
S = struct();
for f = fnames'
    for n = 1:np
        if any(ischar(A.(f{:})))
            S(n).(f{:}) = A.(f{:}){n};
        else
            S(n).(f{:}) = A.(f{:})(n);
        end
    end
end
end