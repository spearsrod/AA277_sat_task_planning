function im_geod = generate_image_locations(n, seed)
% p = inputParser;
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
% addRequired(p,'n',validScalarPosNum);
% addOptional(p,'seed',defaultHeight,validScalarPosNum);
if exist('seed', 'var')
    rng(seed);
end
lat = (rand(n,1) - 0.5) * 180;
lon = (rand(n,1) - 0.5) * 360;
im_geod = [lat.'; lon.'; zeros(size(lat)).'];
end