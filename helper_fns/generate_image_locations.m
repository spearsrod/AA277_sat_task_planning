function im_geod = generate_image_locations(n, seed)
% p = inputParser;
% validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
% addRequired(p,'n',validScalarPosNum);
% addOptional(p,'seed',defaultHeight,validScalarPosNum);
if exist('seed', 'var')
    rng(seed);
end
% lat = (rand(n,1) - 0.5) * 180;
% lon = (rand(n,1) - 0.5) * 360;
% im_geod = [lat.'; lon.'; zeros(size(lat)).'];

im_geod = zeros(3, n);
Antarctica_lat = [-90, -80];
Antarctica_lon = [-180 180];
NA_lat = [20, 80];
NA_lon = [-130 -60];
SA_lat = [-55, 10];
SA_lon = [-80, -35];
Eurasica_lat = [-38 80];
Eurasica_lon = [-17 156];
indian_ocean_lat = [-38, -11];
indian_ocean_lon = [50 110];

for idx = 1:n
    while(true)
        cur_lat = (rand(1) - 0.5) * 180;
        cur_lon = (rand(1) - 0.5) * 360;
        in_cont = check_in_cont(cur_lat, cur_lon, Antarctica_lat, Antarctica_lon);
        if(in_cont)
            im_geod(:,idx) = [cur_lat; cur_lon; 0];
            break;
        end
        in_cont = check_in_cont(cur_lat, cur_lon, NA_lat, NA_lon);
        if(in_cont)
            im_geod(:,idx) = [cur_lat; cur_lon; 0];
            break;
        end
        in_cont = check_in_cont(cur_lat, cur_lon, SA_lat, SA_lon);
        if(in_cont)
            im_geod(:,idx) = [cur_lat; cur_lon; 0];
            break;
        end
        in_cont = check_in_cont(cur_lat, cur_lon, Eurasica_lat, Eurasica_lon);
        if(in_cont)
            in_sea = check_in_cont(cur_lat, cur_lon, indian_ocean_lat, indian_ocean_lon);
            if(not(in_sea))
                im_geod(:,idx) = [cur_lat; cur_lon; 0];
                break;
            end
        end
    end
end
end