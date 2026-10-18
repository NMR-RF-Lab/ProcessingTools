function F = zerofill(f)
%ZEROFILL performs zero interpolation filling on the given spectral data, lengthening the dataset by a factor of 2.
%
%   F = zerofill(f)
%
%   Inputs
%           f: 1D spectral data in frequency domain
%
%   Outputs
%           F: zero filled spectral data
%
% Jacob Degitz, Texas A&M University
% Created 6/5/2025

arguments
    f (1,:) {mustBeNumeric,mustBeFloat}
end

fid = ifft(ifftshift(f));

% Shift end around, to remove zero-fill artifact
n = length(fid);
fid = circshift(fid, ceil(n/40));

% Ensure fid is going left to right
if sum(real(fid(1:round(n/10)))) < sum(real(fid(end-round(n/10)+1:end)))
    flipFLAG = true;
    fid = flip(fid);
else
    flipFLAG = false;
end

% Pad array
if size(fid,2) > size(fid,1)
    fid = padarray(fid.',n,'post').';
else
    fid = padarray(fid,n,'post');
end

% Flip back, if applicable
if flipFLAG
    fid = flip(fid);
end

fid = circshift(fid, -ceil(n/40));
F = fftshift(fft(fid));