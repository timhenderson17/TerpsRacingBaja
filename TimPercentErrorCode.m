clear all
close all

% create the ideal turn samples (classs1 is straight line class 2 is a
% quarter circle

xaxis = [1:1:500];
class1 = zeros(1,500);
class2 = zeros(1,500);
for x = 1:500
    class2(1,x) = 500 - ((250000 - x^2)^(1/2));
end

%% determine slopes for ideal turns
for i = 1:499
    slopeclass1(i) = (class1(i + 1) - class1(i));
    slopeclass2(i) = (class2(i + 1) - class2(i));
end

std_dev_1 = std2(slopeclass1);
std_dev_2 = std2(slopeclass2);

%% read in raw data

data = dlmread('Data_2_8070L_M.csv', ',', 1,0);

rd.intms = data(:,1);
rd.utcms = data(:,2);
rd.PitchSens = data(:,3);
rd.XaccelSens = data(:,4);
rd.YaccelSens = data(:,5);
rd.ZaccelSens = data(:,6);
rd.Battery = data(:,7); 
rd.accelX = data(:,8);
rd.accelY = data(:,9);
rd.accelZ = data(:,10);
rd.roll = data(:,11);
rd.pitch = data(:,12); 
rd.yaw = data(:,13);
rd.Wrpm = data(:,14);
rd.Erpm = data(:,15);
rd.lat = data(:,16);
rd.lon = data(:,17);
rd.spd = data(:,18);
rd.dist = data(:,19);
rd.alt = data(:,20);
rd.GPSSats = data(:,21);
rd.GPSQual = data(:,22);
rd.GPSDOP = data(:,23);

%% up scale data

for i=[1:size(data(:,1))]
    onerun.lat(i) = rd.lat(i);
    onerun.lon(i) = rd.lon(i);
    onerun.ptcsens(i) = rd.PitchSens(i);
    onerun.XaccelSens(i) = rd.XaccelSens(i);
    onerun.YaccelSens(i) = rd.YaccelSens(i);
    onerun.ZaccelSens(i) = rd.ZaccelSens(i);
    onerun.accelX(i) = rd.accelX(i);
    onerun.accelY(i) = rd.accelY(i);
    onerun.accelZ(i) = rd.accelZ(i);
    onerun.pitch(i) = rd.pitch(i);
    onerun.time(i) = rd.intms(i);
end
scl.lat = onerun.lat(onerun.lat~=0);
scl.lon = -onerun.lon(onerun.lat~=0);
scl.ptcsen = onerun.ptcsens(onerun.lat~=0);
scl.XaccelSens = onerun.XaccelSens(onerun.lat~=0);
scl.YaccelSens = onerun.YaccelSens(onerun.lat~=0);
scl.ZaccelSens = onerun.ZaccelSens(onerun.lat~=0);
scl.accelX = onerun.accelX(onerun.lat~=0);
scl.accelY = onerun.accelY(onerun.lat~=0);
scl.accelZ = onerun.accelZ(onerun.lat~=0);
scl.pitch = onerun.pitch(onerun.lat~=0);
scl.time = onerun.time(onerun.lat~=0);

figure;
scatter(scl.lat, scl.lon, 3, 'filled');

x = 1:1:size(scl.lon');
v1 = scl.lat';
xq = (1:0.1:10000);
up.lat = (interpn(x,v1,xq,'cubic'))';
v1 = scl.lon';
up.lon = (interpn(x,v1,xq,'cubic'))';
v1 = scl.XaccelSens';
up.XaccelSens = (interpn(x,v1,xq,'cubic'))';
v1 = scl.YaccelSens';
up.YaccelSens = (interpn(x,v1,xq,'cubic'))';
v1 = scl.ZaccelSens';
up.ZaccelSens = (interpn(x,v1,xq,'cubic'))';
v1 = scl.accelX';
up.accelX = (interpn(x,v1,xq,'cubic'))';
v1 = scl.accelY';
up.accelY = (interpn(x,v1,xq,'cubic'))';
v1 = scl.accelZ';
up.accelZ = (interpn(x,v1,xq,'cubic'))';
v1 = scl.pitch';
up.pitch = (interpn(x,v1,xq,'cubic'))';
v1 = scl.ptcsen';
up.ptcsen = (interpn(x,v1,xq,'cubic'))';

figure;
scatter(scl.lat, scl.lon, 3, 'filled');

%% make binary decision

% moving average filter
up.lat = movmean(up.lat, 35);
up.lon = movmean(up.lon, 35);

% find the corellation coefficient for each section of the track in groups
% of 40
for n = 23:104
    pt1 = 40 * n + 1;
    pt2 = 40 * (n + 1);

    R = corrcoef(up.lat(pt1:pt2), up.lon(pt1:pt2));
    R_2 = R(1,2)^2;
    %figure;
    %scatter(up.lat(pt1:pt2), up.lon(pt1:pt2), 3, 'filled');
    r_values(n+1-23) = R_2;
    title(['R squared:', num2str(R_2)]);
end

% round r_values for binary determination

for n = 1:(104-23)
    if r_values(n+1) > .9
        r_values(n+1) = 1;
    else
        r_values(n+1) = 0;
    end
end

% plot final r_values (binary)
x = [1:1:(104-22)];
figure;
scatter(x, r_values, 3, 'filled');
ylim([-1,2]);

% plot track
figure;
%scatter(up.lat(1900 + 40*130:1900 + 40*142), up.lon(1900 + 40*130:1900 + 40*142), 3, 'filled');
scatter(up.lat, up.lon, 3, 'filled');

% attempt to make decision babsed off of slopes
%{
j = 1;
for i = pt1:pt2
    slope_of_section(j) = (scl.lat(i + 1) - scl.lat(i)) / (scl.lon(i + 1) - scl.lon(i));
    j = j + 1;
end
%}

% attempt to normalize by rotating points
%{
if (scl.lon(pt2) - scl.lon(pt1)) ~= 0
    overall_slope = (scl.lat(pt2) - scl.lat(pt1)) / (scl.lon(pt2) - scl.lon(pt1))
else
    if (scl.lat(pt2) - scl.lat(pt1)) >= 0
        overall_slope = 500; % effectively infinity
    else
        overall_slope = -500; % effectively neg. infinity
    end
end




figure;
scatter(scl.lat(pt1:pt2), scl.lon(pt1:pt2), 3, 'filled');
% Create rotation matrix
theta = atand(overall_slope)
R = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
% Rotate points
for i = pt1:pt2
    point = [scl.lat(i) scl.lon(i)]';
    rot_point = R*point;
    scl.lat(i) = rot_point(1,1);
    scl.lon(i) = rot_point(2,1);
end
        
figure;
scatter(scl.lat(pt1:pt2), scl.lon(pt1:pt2), 3, 'filled');
%}

