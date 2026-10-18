function [kspace, img, B1] = AFI(kspace_full, Tp, nro, npe, n)
%% Parameters

y = 360*42.57*10^6; % gyromagnetic ratio, degrees/sec/T
t_null = Tp/6; % tnull, sec
a = pi/t_null; % scaling factor

fun = @(t) sin(a.*t)./(a.*t); % integral equation to find Tp effective

Tp_eff = integral(fun, -Tp/2, Tp/2);

%% Split Image
kspace = zeros(nro, npe, 2);
kspace(:,:,1) = kspace_full(1:nro,:); % first image
kspace(:,:,2) = kspace_full(nro+1:nro*2,:); % second image

%% Filter
img = zeros(nro, npe, 2);

for i = 1:2
    [kspace(:,:,i), img(:,:,i)] = filt_DC_cs(kspace(:,:,i), nro, npe, 0.2);
end

% img = img.*m;

%% B1 Mapping

% Initialize arrays
r = zeros(nro, npe);
B1 = zeros(nro, npe);

% Calculate B1 map
for i = 1:nro
    for j = 1:npe
        % Calculate r ratio
        r(i,j) = abs(img(i,j,2))./abs(img(i,j,1));

        % Fix imaginary measurements
        if r(i,j) > 1
            r(i,j) = 0.99999;
        end

        % Calculate B1 map
        B1(i,j) = (1/(y*Tp_eff))*acosd((r(i,j).*n - 1)/(n - r(i,j)));
    end
end