function [kspace, img, B1] = DA_B1map(file_sfa, file_lfa)

%% Load data

% Obtain file names
if nargin == 0
    fprintf('\nSelect the file with the smaller flip angle.\n\n')
    file_sfa = uigetdir();
    fprintf('\nSelect the file with the larger flip angle.\n\n')
    file_lfa = uigetdir();

    % Isolate file name from path
    [~, fname_sfa, ~] = fileparts(file_sfa);
    [~, fname_lfa, ~] = fileparts(file_lfa);
else
    fname_sfa = file_sfa;
    fname_lfa = file_lfa;
end

% Load data
[kspace_sfa, ~, ~, params_sfa, ~] = loadfidfancy('fid', fname_sfa, 'zip', true);
[kspace_lfa, ~, ~, params_lfa, ~] = loadfidfancy('fid', fname_lfa, 'zip', true);

% Reorganize
kspace(:,:,1) = kspace_sfa; kspace(:,:,2) = kspace_lfa; 
img(:,:,1) = fftshift(ifft2(fftshift(kspace(:,:,1)))); img(:,:,2) = fftshift(ifft2(fftshift(kspace(:,:,2))));

%% Parameters

y = 360*42.5774*10^6; % gyromagnetic ratio, degrees/sec/T
Tp = params_sfa.tped*(10^-6); % RF pulse duration
t_null = Tp/6; % tnull, sec
a = pi/t_null; % scaling factor

fun = @(t) sin(a.*t)./(a.*t); % integral equation to find Tp effective

Tp_eff = integral(fun, -Tp/2, Tp/2); % effective pulse duration

%% Plot Images
dims = size(img);
pnames = [strcat(num2str(params_sfa.fliplist), " degrees"), strcat(num2str(params_lfa.fliplist), " degrees")];

cmax = max(max(max(abs(img))));

for k = 1:dims(3)
    figure; imagesc(abs(img(:,:,k))); pbaspect([1 dims(1)/dims(2) 1]); axis off; colormap(gray); title(pnames(k)); clim([0 cmax]); 
end

%% Dual Angle B1 Mapping

% Initialize arrays
r = zeros(dims(1), dims(2));
B1 = zeros(dims(1), dims(2));

% Calculate r & B1 map

for i = 1:dims(1)
    for j = 1:dims(2)
        % Calculate r ratio
        r(i,j) = img(i,j,1)./img(i,j,2);

        % Fix imaginary measurements
        if r(i,j) < 0.5
            r(i,j) = 0.5/0.99999;
        end

        % Calculate B1 map
        B1(i,j) = (1/(y*Tp_eff))*acosd(1/(2.*r(i,j)));
    end
end
figure; imagesc(abs(B1)); axis image; axis off; title(strcat('B1 map, n = ', num2str(params_lfa.fliplist), '/', num2str(params_sfa.fliplist))); c=colorbar; c.Label.String = 'Magnetic Flux (\muT)';