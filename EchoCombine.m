function [TFS, N_std] = EchoCombine(img, tfs, msk, TE, method)
% ECHOCOMBINE - Combine unwrapped phase from each echo into a single field
% map. Requires SEPIA package
%
% totalField = EchoCombine(mag, tfs, msk, TE)
%
% Inputs
%         img: raw complex data
%         tfs: unwrapped phase data
%         msk: binary mask
%          TE: echo time(s)
%      method: combination method
%
% Outputs
%         TFS: total field
%       N_std: noise standard deviation

% Extract magnitude & phase
mag = abs(img); ph = angle(img);

% Echo Combination
switch method
    case 'NonLinearFit' % C:\SEPIA\SEPIA_v1.1.0\wrapper\WrapperEchoCombine\Wrapper_EchoCombine_MEDInonlinearfit.m
        if numel(TE)>3 && ((TE(2)-TE(1))-(TE(3)-TE(2))>1e-5)
            % Estimate the frequency offset in each of the voxel using a complex
            % fitting (uneven echo spacing)
            [iFreq_raw, N_std] = Fit_ppm_complex_TE(mag.*exp(-1i*ph),TE);
        else
            % Estimate the frequency offset in each of the voxel using a complex
            % fitting (even echo spacing)
            [iFreq_raw, N_std] = Fit_ppm_complex(mag.*exp(-1i*ph));
        end

        % Use the centre of mass as reference phase
        TFS = tfs-round(mean(tfs(msk == 1))/(2*pi))*2*pi;

        % convert rad to radHz
        TFS = TFS / dt;

    case 'OptimumWeights' % C:\SEPIA\SEPIA_v1.1.0\wrapper\WrapperEchoCombine\Wrapper_EchoCombine_OptimumWeight.m
        if length(TE) > 1 % Multiecho
            %%%%%%%%%%%%%%%%%%%%%%%% Step 2: Compute weights %%%%%%%%%%%%%%%%%%%%%%%%
            % Robinson et al. 2017 NMR Biomed Appendix A2
            [weight, N_std]= compute_optimum_weighting_combining_phase_difference(mag, TE);
            clear mag % release memory

            % standard deviation of field map from weighted avearging
            N_std = sqrt(sum(weight.^2 .* N_std.^2,4)); % sqrt(Weighted variance) = SD

            % Correct for NaN & infinity points
            N_std(isnan(N_std))	= 0;
            N_std(isinf(N_std))	= 0;

            %%%%%%%% not sure what this part is yet%
            N_std = N_std./norm(N_std(msk~=0)); %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%% Step 3: Weighted average %%%%%%%%%%%%%%%%%%%%%%%%
            % 20210803: use for-loop to reduce memory
            TFS = zeros(dims(1:3), 'like', tfs);
            for k = 1:dims(4)
                % Weighted average of unwrapped phase shift
                TFS = TFS + weight(:,:,:,k).*((tfs(:,:,:,k+1) - tfs(:,:,:,1))/(TE(k+1)-TE(1)));
            end

            % Correct for NaN & infinity points
            TFS(isnan(TFS)) = 0;
            TFS(isinf(TFS)) = 0;

        else % Single Echo
            % Calculate noise standard deviation
            N_std = 1./mag;

            % Correct for NaN & infinity points
            N_std(isnan(N_std))	= 0;
            N_std(isinf(N_std))	= 0;

            %%%%%%%% not sure what this part is yet%
            N_std = N_std./norm(N_std(msk~=0)); %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Use the centre of mass as reference phase
            TFS = tfs-round(mean(tfs(msk == 1))/(2*pi))*2*pi;
            TFS	= TFS/(TE(1));
        end
end

% Apply masks
N_std = N_std.*msk;
TFS = TFS.*msk;
end