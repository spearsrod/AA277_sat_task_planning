function in_cont = check_in_cont(lat, lon, lat_check, lon_check)
if(lat >= lat_check(1) && lat <= lat_check(2))
    if(lon >= lon_check(1) && lon <= lon_check(2))
        in_cont = true;
        return
    end
end
in_cont = false;
end