clear all
close all

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
up.lat = movmean(up.lat, 45);
up.lon = movmean(up.lon, 45);

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
% plot the sections of the graph that are designated as turns

scatter(up.lat(900:8300), up.lon(900:8300), 3, 'filled');
hold on;
scatter(up.lat(5500:6000), up.lon(5500:6000), 3, [1 0 0]);
hold on;
scatter(up.lat(7000:7500), up.lon(7000:7500), 3, [1 0 0]);
hold on;
scatter(up.lat(6200:6700), up.lon(6200:6700), 3, [1 0 0]);
hold on;
scatter(up.lat(2500:2800), up.lon(2500:2800), 3, [1 0 0]);
hold on;
scatter(up.lat(3100:3300), up.lon(3100:3300), 3, [1 0 0]);
hold on;
scatter(up.lat(4500:5200), up.lon(4500:5200), 3, [1 0 0]);
hold on;
scatter(up.lat(3700:4200), up.lon(3700:4200), 3, [1 0 0]);

for n = 900:8300
    pt1 = n;
    pt2 = 40 + n;

    R = corrcoef(up.lat(pt1:pt2), up.lon(pt1:pt2));
    R_2 = R(1,2)^2;
    %figure;
    %scatter(up.lat(pt1:pt2), up.lon(pt1:pt2), 3, 'filled');
    r_values(n-899) = R_2;
    title(['R squared:', num2str(R_2)]);
end

% round r_values for binary determination

for n = 1:8300-900
    if r_values(n) > .8
        r_values(n) = 1;
    else
        r_values(n) = 0;
    end
end

% plot final r_values (binary)
x = [900:1:8300];
figure;
scatter(x, r_values, 3, 'filled');
ylim([-1,2]);

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

