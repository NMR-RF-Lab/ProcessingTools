%ZEROFILL performs zero interpolation filling on the given MR image data
%
%   IMG = zerofillIMG(img,dim)
%
%   Inputs
%           img: 2D/3D/4D image data
%           dim: (Optional) number of dimensions to interpolate. Defaults to 2.
%
%   Outputs
%           IMG: zero filled image data
%
% Jacob Degitz, Texas A&M University
% Created 07/25/2025

function IMG = zerofillIMG(img, dim)

arguments
    img {mustBeNumeric,mustBeFloat}
    dim (1,1) {mustBeNumeric,mustBeInteger,mustBeLessThan(dim,4)} = 2
end

% Pad size array
sz = size(img);
if length(sz) < 3
    sz(3) = 1;
end
if length(sz) < 4
    sz(4) = 1;
end

% Preallocate data
kSpace = zeros(size(img), 'like', img);

% Convert to kspace
for j = 1:sz(4)
    if dim == 3
        kSpace(:,:,:,j) = ifftshift(ifftn(ifftshift(img(:,:,:,j))));
    else
        for i = 1:sz(3)
            kSpace(:,:,i,j) = ifftshift(ifftn(ifftshift(img(:,:,i,j))));
        end
    end
end

psize = [sz(1)/2, sz(2)/2, 0, 0]; % pad size
if dim == 3
    psize(3) = sz(3)/2;
end

kSpace = padarray(kSpace, psize, 0, 'both');

% Convert back to image data
IMG = zeros(size(kSpace), 'like', kSpace);
for j = 1:sz(4)
    if dim == 3
        IMG(:,:,:,j) = fftshift(fftn(fftshift(kSpace(:,:,:,j))));
    else
        for i = 1:sz(3)
            IMG(:,:,i,j) = fftshift(fftn(fftshift(kSpace(:,:,i,j))));
        end
    end
end