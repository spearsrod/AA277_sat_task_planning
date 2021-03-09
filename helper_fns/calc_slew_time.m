function slew_time = calc_slew_time(z_start, z_end, slew_rate)
proj = dot(z_start, z_end)/(norm(z_start)*norm(z_end));
slew_angle = rad2deg(acos(proj));
slew_time = slew_angle / slew_rate;
end