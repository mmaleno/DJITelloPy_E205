%% Kevin Shoyer and Max Maleno
% 4/11/2020
% This script is used for post processing from the Tello Drone Control data
%% Experiment 1: just messing around with it
 filename = '/Users/kevinshoyer/Desktop/DJITelloPy_E205/CallibrationDataLogs/Tello_Log_2020_04_11_13_31_39.csv';
%% Experiment 2: (somewhat botched)
filename = '/Users/kevinshoyer/Desktop/DJITelloPy_E205/CallibrationDataLogs/Tello_Log_2020_04_11_15_04_08.csv';
% Experiment 2: to test coordinate systems and get more intuition on velocity reading
% 
% Start on desk
% Clamp against wall and rotate, keeping against wall
% Do one full roll
% Do one full yaw
% Do one full pitch
% With drone flat, walk forward at walking speed

%% Experiment 3: testing accelerometer and roll/pitch/yaw coordinate system
filename = '/Users/kevinshoyer/Desktop/DJITelloPy_E205/CallibrationDataLogs/Tello_Log_2020_04_11_15_19_18.csv';
% sit for 10 seconds
%pitch upwards and look at cieling
% sit for 10
% roll to the right and look forwards.


%% experiment 4: roll pitch and yaw testing

%roll right 360 degrees
%pitch up 360 degrees
%yaw left 360 degrees
filename = '/Users/kevinshoyer/Desktop/DJITelloPy_E205.nosync/CallibrationDataLogs/.Tello_Log_2020_04_11_15_53_46.csv.icloud';
%% experiement 5: looking at velocities

% Hold and move forward at walking speed
% Hold and move right at walking speed
% Tilt vehicle around and stay in one location
% Tilt vehicle 45 degrees forward and walk forward at walking speed
%filename = '/Users/kevinshoyer/Desktop/DJITelloPy_E205/CallibrationDataLogs/Tello_Log_2020_04_11_17_46_08.csv';

%% experiment 6: flying and velocities
% 1) fly up
% 2) fly forward (should be purely forward velocity)
% 3) fly right (purely right)
% 4) take same path back, but face towards direction of travel at all times
% (should be forward velocity, if velocity is local)
% 5) land on ground (to see what this does for height)

% this was about 9ft by 10ft path (2.7 meters by 3 meters)
filename = '/Users/kevinshoyer/Desktop/DJITelloPy_E205.nosync/CallibrationDataLogs/Tello_Log_2020_04_11_18_15_22.csv';

%% Experiment 7: moved around the room for a longer time to look at the drift while integrating velocity
filename = '/Users/kevinshoyer/Desktop/DJITelloPy_E205/CallibrationDataLogs/Tello_Log_2020_04_12_18_41_43.csv';

%% Experiment 8: Used to allign april tag time and imu time
filename = '/Users/kevinshoyer/Desktop/DJITelloPy_E205.nosync/AprilTag/apriltag-master/python/logs/Tello_Log_2020_04_23_16_40_30.csv';

%% Experiment 9: testing the measurement model

filename = '/Users/kevinshoyer/Desktop/DJITelloPy_E205.nosync/AprilTag/apriltag-master/python/logs/Tello_Log_2020_04_23_17_40_10.csv';

% start at origin. move up to level with the tag. Move left about 2 meters.
% Move back to x,y origin. move towards tag. Look around, but stay 1m from
% tag

%% Import data from text file.

delimiter = ',';

formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

% Close the text file.
fclose(fileID);

% Allocate imported array to column variable names and convert to propper
% SI units and local coordinate system. 

%coordinate system:
    % x positive forward
    % y positive right
    % z positive down
    % roll, pitch, yaw follow right hand rotations about x,y,z respectively
    
time = dataArray{:, 1};%seconds
pitch = dataArray{:, 2}.*pi/180;%radians
roll = dataArray{:, 3}.*pi/180;%radians
yaw = dataArray{:, 4}.*pi/180;%radians
v_x = dataArray{:, 5}./10;%m/s
v_y = dataArray{:, 6}./10;%m/s
v_z = dataArray{:, 7}./10;%m/s
temp_low = dataArray{:, 8};
temp_high = dataArray{:, 9};
dist_tof = dataArray{:, 10};
height = -dataArray{:, 11}./100;%m
battery = dataArray{:, 12};
barometer = dataArray{:, 13};
flight_time = dataArray{:, 14};
a_x = dataArray{:, 15}.*(-1/1000*9.8);%m/s^2
a_y = dataArray{:, 16}.*(-1/1000*9.8);%m/s^2
a_z = dataArray{:, 17}.*(-1/1000*9.8);%m/s^2

%clearvars filename delimiter formatSpec fileID dataArray ans;

%% import apriltag measurment data
filename = '/Users/kevinshoyer/Desktop/DJITelloPy_E205.nosync/AprilTag/apriltag-master/python/logs/Tello_Log_2020_04_23_17_40_10_april.csv';
delimiter = ',';
formatSpec = '%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);
% Allocate imported array to column variable names
frameNum = dataArray{:, 1};
timeCam = dataArray{:, 2};
tagDetected = dataArray{:, 3};
y_tag = dataArray{:, 4}; % in our local coordinate system
z_tag = dataArray{:, 5};
x_tag = dataArray{:, 6};
clearvars filename delimiter formatSpec fileID dataArray ans;

t_diff = 23.72-21.1;

timeCamA = timeCam+t_diff;

%% plot pitch and tagdetected to see how times line up

figure(15)
plot(timeCam,tagDetected)
hold on
plot(time, pitch)

%from video, it appears that the camera looses site of the apriltag right
%when the pitch motion begins

t_lost_cam = 21.1; %camera time that apriltag is lost
t_lost_imu = 23.72; %imu pitch begins at 23.65 to 23.72 seconds

t_diff = 23.72-21.1;

timeCamA = timeCam+t_diff

% plot the newly alligned data

figure(16)
plot(timeCamA,tagDetected)
hold on
plot(time, pitch)

% this looks correct, but we may want to create a better procedure with
% many measurements to allign them more propperly


%% Plot the accelerations

figure(1)
title('Accelerations')
plot(time,a_x)
hold on
plot(time,a_y)
hold on
plot(time,a_z)
xlabel('Time (s)')
ylabel('acceleration')
legend('x acceleration','y acceleration','z acceleration')

%% Plot velocities

figure(2)
title('Velocities')
plot(time,v_x)
hold on
plot(time,v_y)
hold on
plot(time,v_z)
xlabel('Time (s)')
ylabel('velocity')
legend('x velocity','y velocity','z velocity')

%% Plotting the height

figure(3)
title('Height')
plot(time,height)
xlabel('time')
ylabel('height')

%% Plotting roll pitch yaw:

figure(4)
title('Roll,Pitch,Yaw')
plot(time,roll)
hold on
plot(time,pitch)
hold on
plot(time,yaw)
xlabel('Time (s)')
ylabel('angle (some units)')
legend('Roll','Pitch','Yaw')




%% numerically integrate velocity values to propegate state
delta_t = time(2:end) - time(1:end-1)



x_pos = [];
y_pos = [];
z_pos = [];
x = 0;
y = 0;
z = 0;
for i = 1:length(delta_t)
    dt = delta_t(i)
    x = x + v_x(i).*dt;
    y = y + v_y(i).*dt;
    z = y + v_z(i).*dt;
    x_pos = [x_pos,x];
    y_pos = [y_pos,y];
    z_pos = [z_pos,z];
    
end

figure(5)
plot(x_pos,y_pos)
title('x,y path from velocity integration')
xlabel('x position (m)')
ylabel('y Position (m)')


%% Resample because it takes forever with this many data points

N = 1 %sample one every N samples

time = time(1:N:end);
pitch = pitch(1:N:end);
roll = roll(1:N:end);
yaw = yaw(1:N:end);
a_x = a_x(1:N:end);
a_y = a_y(1:N:end);
a_z = a_z(1:N:end);


%% transform accelerations

% first transform coordinate system of accelerations
% desired local coordinate system: 
% x positive forward
% y positive right
% z positive down
% with this coordinate system:
    %Velocities match up as expected (this is the coordinate system for
    %velocity outputs
    
    %This is also roll pitch and yaw outputs
    % roll: right hand rotation about +x
    % pitch: right hand rotation about +y
    % yaw: right handed about +z


a_l = [a_x,a_y,a_z]';

% Find direct cosine matrix using rotation angles and project acceleration
% onto global frame
a_g = [];
for i=1:length(roll)
    a = a_l(:,i);
    dcm_i = angle2dcm( yaw(i), pitch(i), roll(i));
    a_gi = dcm_i*a;
    a_gi(3) = a_gi(3)-9.81; %correct for gravity in z direction
    a_g = [a_g,a_gi];
    
end

%plot the global accelerations

figure(6)
title('Global accelerations')
xlabel('Time')
ylabel('acceleration (mg)')
plot(time,a_g(1,:))
hold on
plot(time,a_g(2,:))
hold on
plot(time,a_g(3,:))
legend('x acceleration', 'y acceleration', 'z acceleration')

%% Callibrate accelerometers using stationary data. This gets rid of offsets due to misallignment of accelerometer

% callibration procedure will occur when the vehicle is on a flat surface

[times_of_flight,heights_for_times] = find(height(20:end) ~= 0); % finds indices and values for hieghts not equal to zero
takeoff = times_of_flight(1)-20; % index for when the drone takes off. Callibration procedures will end

% calculate offsets during callibration procedure
ax_bias = mean(a_g(1,20:takeoff));
ay_bias = mean(a_g(2,20:takeoff));
az_bias = mean(a_g(3,20:takeoff));

% delete these offsets from data

a_g(1,:)= a_g(1,:) - ax_bias;
a_g(2,:)= a_g(2,:) - ay_bias;
a_g(3,:)= a_g(3,:) - az_bias;


%% Plot the new callibrated accelerations

figure(7)
title('Callibrated Global accelerations')
xlabel('Time')
ylabel('acceleration (mg)')
plot(time,a_g(1,:))
hold on
plot(time,a_g(2,:))
hold on
plot(time,a_g(3,:))
legend('x acceleration', 'y acceleration', 'z acceleration')

%% if desired, smooth the data using MATLABs built in moving average filter

a_g(1,:)= smooth(a_g(1,:));
a_g(2,:)= smooth(a_g(2,:));
a_g(3,:)= smooth(a_g(3,:));

%% numerically integrate accelleration values to propegate state

delta_t = time(2:end) - time(1:end-1);

x_pos_a = [];
y_pos_a = [];
z_pos_a = [];

%velocities propegated from acceleration
v_xa = [];
v_ya = [];
v_za = [];
x = 0;
y = 0;
z = 0;
v_xai = 0;
v_yai = 0;
v_zai = 0;


for i = 10:length(delta_t)
 
    if height(i) == 0 % using the assumption that if z = 0, it is still on the ground and not moving 
        a_gx = 0;
        a_gy = 0;
        a_gz = 0;   
        v_xai = 0;
        v_xai = 0;
        v_xai = 0;
%   %This conditional statement uses the fact that if the roll or pitch is
%   zero, it can not be accelerating in that direction
%     elseif roll(i) == 0 || yaw(i) == 0
%         if roll(i) == 0
%             a_gy == 0
%         end
%         if pitch(i) == 0
%             a_gx = 0;
%         end
    else
        a_gx = a_g(1,i)
        a_gy = a_g(2,i)
        a_gz = a_g(3,i)
    end
    
    dt = delta_t(i);
   
    x = x + v_xai.*dt;
    y = y + v_yai.*dt;
    z = z + v_zai.*dt; 

    v_xai = v_xai+a_gx*dt;
    v_yai = v_yai+a_gy*dt;
    v_zai = v_zai+a_gz*dt;
    
    x_pos_a = [x_pos_a,x];
    y_pos_a = [y_pos_a,y];
    z_pos_a = [z_pos_a,z];
    
    v_xa = [v_xa,v_xai];
    v_ya = [v_ya,v_yai];
    v_za = [v_za,v_zai];
    
end

figure(6)
plot(x_pos_a,y_pos_a)
title('Position of vehicle from integrated global accelerations')
xlabel('x position (meters)')



figure(7)
plot(time(11:end),v_xa)
hold on
plot(time(11:end),v_ya)
hold on
plot(time(11:end),v_za)
legend('x velocity','y velocity','z velocity')
title('Velocities integrated from global accelerations')


%% Motion model only using the roll pitch and yaw
% this model uses the assumption that the quadcopter motors have the thrust
% vector straight down in the local frame. In order to maintain propper
% altitude, the portion of the thrust vector in the z global direction must
% be equal and opposite of the force of gravity

thrust_vector_local = [0;0;1]; %has to be in local z direction

a_g = [];
for i=1:length(roll)
    dcm_i = angle2dcm( yaw(i), pitch(i), roll(i));
    a_gi = dcm_i*thrust_vector_local;
    a_gi = a_gi./a_gi(3)*9.81; % normalize the vector by the z direction value and scale by gravity
    a_gi(3) = a_gi(3)-9.81; %now subtract out gravity from z
    a_g = [a_g,a_gi];
    
end


delta_t = time(2:end) - time(1:end-1);

x_pos_a = [];
y_pos_a = [];
z_pos_a = [];

%velocities propegated from acceleration
v_xa = [];
v_ya = [];
v_za = [];
x = 0;
y = 0;
z = 0;
v_xai = 0;
v_yai = 0;
v_zai = 0;


for i = 10:length(delta_t)
 
    if height(i) == 0 % using the assumption that if z = 0, it is still on the ground and not moving 
        a_gx = 0;
        a_gy = 0;
        a_gz = 0;   
        v_xai = 0;
        v_xai = 0;
        v_xai = 0;
%   %This conditional statement uses the fact that if the roll or pitch is
%   zero, it can not be accelerating in that direction
%     elseif roll(i) == 0 || yaw(i) == 0
%         if roll(i) == 0
%             a_gy == 0
%         end
%         if pitch(i) == 0
%             a_gx = 0;
%         end
    else
        a_gx = a_g(1,i)
        a_gy = a_g(2,i)
        a_gz = a_g(3,i)
    end
    
    dt = delta_t(i);
   
    x = x + v_xai.*dt;
    y = y + v_yai.*dt;
    z = z + v_zai.*dt; 

    v_xai = v_xai+a_gx*dt;
    v_yai = v_yai+a_gy*dt;
    v_zai = v_zai+a_gz*dt;
    
    x_pos_a = [x_pos_a,x];
    y_pos_a = [y_pos_a,y];
    z_pos_a = [z_pos_a,z];
    
    v_xa = [v_xa,v_xai];
    v_ya = [v_ya,v_yai];
    v_za = [v_za,v_zai];
    
end

figure(6)
plot(x_pos_a,y_pos_a)
title('Position of vehicle from integrated global accelerations')
xlabel('x position (meters)')


figure(7)
plot(time(11:end),v_xa)
hold on
plot(time(11:end),v_ya)
hold on
plot(time(11:end),v_za)
legend('x velocity','y velocity','z velocity')
title('Velocities integrated from global accelerations')


%% Testing different DCM from euler angles. None of them are good. Let's assume for now the built in matlab function is working propperly

yaw = .8;
pitch = .1;
roll = -.01;

%testing different DCMs:

DCM2 = [cos(yaw)*cos(pitch)       cos(yaw)*sin(pitch)*sin(roll)-sin(yaw)*cos(roll)      cos(yaw)*sin(pitch)*cos(roll)+sin(yaw)*sin(roll);
        sin(yaw)*cos(pitch)       sin(yaw)*sin(pitch)*sin(roll)+cos(yaw)*cos(roll)      sin(yaw)*sin(pitch)*cos(roll)-cos(yaw)*sin(roll);
        -sin(pitch)                         cos(pitch)*sin(roll)                            cos(pitch)*cos(roll)];

DCM3 = [cos(pitch)*cos(yaw)-sin(pitch)*sin(roll)*sin(yaw)      cos(pitch)*sin(yaw)+sin(pitch)*sin(roll)*cos(yaw)  -sin(pitch)*cos(roll);
        -cos(roll)*sin(yaw)                          cos(roll)*cos(yaw)                       sin(roll);
        sin(pitch)*cos(yaw)+cos(pitch)*sin(roll)*sin(yaw)      sin(pitch)*sin(yaw)-cos(pitch)*sin(roll)*cos(yaw)  cos(pitch)*cos(roll)]

DCM1 = angle2dcm( yaw, pitch, roll);

% DCMs can look different and represent the same transformation. Check by
% rotating a vector:

vec = [1;2;3];

vec_g1 = DCM1*vec
vec_g2 = DCM2*vec
vec_g3 = DCM3*vec

%% Measurement model (estimate global position from local tag measurement)


tag1 = [112/39.37,0,-56/39.37]'; %measurements are from the center of the tag? not sure if this is correct


est_pos = zeros(3,length(timeCamA))

%rotate to global frame and translate to origin
for i=1:length(timeCamA)
    if tagDetected(i) ==1
        t = timeCamA(i)
        z = [x_tag(i),y_tag(i),z_tag(i)]';
        %find the closest imu measurement
        [num,timeval]=find(time>timeCamA(i)); %just taking next imu val
        DCM = angle2dcm( yaw(num(1)), pitch(num(1)), roll(num(1)));
        est_pos(:,i) = tag1 - DCM*z;
    end
end
    
%% plot the results

figure(20)
plot(timeCamA, est_pos(1,:),'o');
hold on
plot(timeCamA, est_pos(2,:),'o');
hold on
plot(timeCamA, est_pos(3,:),'o')
xlabel('time (s)')
ylabel('position (m)')
legend('x position','y position', 'z position')

figure(21)
plot3(est_pos(1,:),est_pos(2,:),est_pos(3,:),'o')



















