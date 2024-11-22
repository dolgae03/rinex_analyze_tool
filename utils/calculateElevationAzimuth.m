function [azimuth, elevation] = calculateElevationAzimuth(observerECEF, targetECEF)
    % INPUTS:
    % observerECEF - [x, y, z] in meters (Observer's ECEF coordinates)
    % targetECEF - [x, y, z] in meters (Target's ECEF coordinates)
    % observerLat - Observer's latitude in degrees
    % observerLon - Observer's longitude in degrees
    
    % Convert observer latitude and longitude to radians
    [lat, lon, alt] = wgsxyz2lla(observerECEF);
    enuVector = wgsxyz2enu(targetECEF, lat, lon, alt);

    e = enuVector(1); % East component
    n = enuVector(2); % North component
    u = enuVector(3); % Up component
    
    
    
    % Calculate elevation angle (in degrees)
    elevation = asind(u / sqrt(e^2 + n^2 + u^2));
    
    % Calculate azimuth angle (in degrees)
    azimuth = atan2d(e, n);
    if azimuth < 0
        azimuth = azimuth + 360; % Normalize to 0-360 degrees
    end
end
