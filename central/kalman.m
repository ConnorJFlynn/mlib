function kalman(alpha, duration, dt)

% function kalman(alpha, duration, dt) - Kalman filter simulation
% alpha = forgetting factor (alpha >= 1)
% duration = length of simulation (seconds)
% dt = step size (seconds)
% Copyright 1998 Innovatia Software.  All rights reserved.
% http://www.innovatia.com/software

measnoise = 10; % position measurement noise (feet)
accelnoise = 0.5; % acceleration noise (feet/sec^2)

a = [1 dt; 0 1]; % transition matrix
c = [1 0]; % measurement matrix
x = [0; 0]; % initial state vector
xhat = x; % initial state estimate

Q = accelnoise^2 * [dt^4/4 dt^3/2; dt^3/2 dt^2]; % process noise covariance
P = Q; % initial estimation covariance
R = measnoise^2; % measurement error covariance

% set up the size of the innovations vector
Inn = zeros(size(R));

pos = []; % true position array
poshat = []; % estimated position array
posmeas = []; % measured position array

Counter = 0;
for t = 0 : dt: duration,
    Counter = Counter + 1;
    % Simulate the process
    ProcessNoise = accelnoise * randn * [(dt^2/2); dt];
    x = a * x + ProcessNoise;
    % Simulate the measurement
    MeasNoise = measnoise * randn;
    z = c * x + MeasNoise;
    % Innovation
    Inn = z - c * xhat;
    % Covariance of Innovation
    s = c * P * c' + R;
    % Gain matrix
    K = a * P * c' * inv(s);
    % State estimate
    xhat = a * xhat + K * Inn;
    % Covariance of prediction error
    P = a * P * a' + Q - a * P * c' * inv(s) * c * P * a';
    % Save some parameters in vectors for plotting later
    pos = [pos; x(1)];
    posmeas = [posmeas; z];
    poshat = [poshat; xhat(1)];
end

% Plot the results
t = 0 : dt : duration;
t = t';
plot(t,pos,'r',t,poshat,'g',t,posmeas,'b');
grid;
xlabel('Time (sec)');
ylabel('Position (feet)');
title('Kalman Filter Performance');
