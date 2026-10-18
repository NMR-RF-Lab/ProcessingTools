function F = lgtransform(f, varargin)
%LGTRANSFORM applies a lorentzian-to-gaussian transformation.
%
%   F = lgtransform(f, t, Tl, Tg)
%
%   Inputs
%           f: 1D spectral data in frequency domain
%           t: *optional* 1D time series; default = array from 0 to 1 with length equal to f
%          Tl: lorentzian parameter, ideally equal to T2*; default = 0.01
%          Tg: gaussian parameter; default = 0.1
%
%   Outputs
%           F: transformed spectral data
%
% Jacob Degitz, Texas A&M University
% Created 6/5/2025

p = inputParser;
validateVec = @(x) isnumeric(x) && ismatrix(x) && size(x,1)==1;
validatePar = @(x) isnumeric(x) && isscalar(x) && x~=0;
addRequired(p, 'f',  validateVec);
addParameter(p, 't', linspace(0,1,length(f)), validateVec)
addParameter(p, 'Tl', 0.01, @(x) isnumeric(x) && isscalar(x) && x~=0 && x<1);
addParameter(p, 'Tg', 0.1, @(x) isnumeric(x) && isscalar(x) && x~=0 && x>=0.1);
parse(p, f, varargin{:});

% Remove from parser
t = p.Results.t;
Tl = p.Results.Tl;
Tg = p.Results.Tg;

% Zero pad data
n = length(f);
if mod(n,2)==1
    n = n+1;
end
t = linspace(min(t), max(t), length(f)+n);
f = padarray(f, [0 n/2], 0, 'both');

% Apply transformation
filt = exp(t./Tl).*exp(-t.^2./Tg^2);
fid = ifft(ifftshift(f)).*filt;
F = fftshift(fft(fid));

% Trim off padding
F = F(n/2+1:end-n/2);
