function im_geod = generate_image_locations(n)
lat = (rand(n,1) - 0.5) * 180;
lon = (rand(n,1) - 0.5) * 360;
im_geod = [lat.'; lon.'; zeros(size(lat)).'];
end