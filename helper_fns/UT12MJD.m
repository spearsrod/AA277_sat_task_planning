function mjd = UT12MJD(MM, DD, YYYY)
    % Follow the algorithm for converting ut1 to mean julian date as
    % outlined in A.1.1 of Montenbruck (page 321)
    if(MM <= 2)
        y = YYYY - 1;
        m = MM + 12;
    else
        y = YYYY;
        m = MM;
    end
    
    B = floor(y/400 - y/100 + y/4);
    mjd = 365 * y - 679004 + B + floor(30.6001*(m + 1)) + DD; 
end