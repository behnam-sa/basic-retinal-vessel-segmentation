function V = ExtractVessels(I, Imask)

    % inhance image
    Ig = adapthisteq(im2gray(I) .* Imask);

    % generate filters
    sigma1 = 1;
    sigma2 = 2;
    sigmabw = 5;
    dirs = 24;
    f = cell([1, dirs]);
    ddeg = pi / dirs;
    for i = 1 : dirs
        P = tiltedPlane(i * ddeg, [25, 25]);
        Pp = tiltedPlane(i * ddeg + pi/2, [25, 25]);
        f{i} = (gaussmf(P, [sigma2, 0]) / sum(sum(gaussmf(P, [sigma2, 0]))) ...
            - gaussmf(P, [sigma1, 0]) / sum(sum(gaussmf(P, [sigma1, 0])))) ...
            .* gaussmf(Pp, [sigmabw, 0]);
        f{i} = f{i} - mean(mean(f{i}));
    end

    % apply filters and max
    W = cell(dirs);
    Wm = zeros(size(Ig));
    for i = 1:dirs
        W{i} = imfilter(Ig, f{i});
        Wm = max(W{i}, Wm);
    end
    
    % Otsu's thresholding and use first threshold
    oth = multithresh(Wm, 2);
    V = Wm > oth(1);
    
    % remove the outer circle
    exmask = imerode(Imask, strel('disk', 3));
    exmask = [zeros([size(exmask, 1), 2]), exmask(:,1:end-2)]; % shift mask to the right
    V = V .* exmask;
    
    % apply median filter
    %V = medfilt2(V, [3 3]);
end

% helper function
function P = tiltedPlane(degree, size)
    P = zeros(size);
    for i = 1:size(1)
        for j = 1:size(2)
            P(i, j) = (sin(degree) * (i - (size(1) + 1) / 2)) ...
                + (cos(degree) * (j - (size(2) + 1) / 2));
        end
    end
end
