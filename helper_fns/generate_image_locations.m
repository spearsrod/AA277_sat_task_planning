function [lat, lon] = generate_image_locations(n)
lat = (rand(n,1) - 0.5) * 180;
lon = (rand(n,1) - 0.5) * 360;
end