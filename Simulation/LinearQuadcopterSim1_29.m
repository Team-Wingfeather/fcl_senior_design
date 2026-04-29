%quadcopter simulation 
%D Fredette 11-24-25

%11-24-25
%After debugging the dynamics by themselves in QuadcopterSimOpenLoop.m it
%is time to try again closing the loop with a hover controller. 


%state = [x y z xDot yDot zDot roll pitch yaw rollRate pitchRate yawRate omega1 omega2 omega3 omega4 zErrorInt yawErrorInt pitchErrorInt rollErrorInt]
%input is voltage to motors

clear
%close all
figure(1); figure(2); close([1 2])

%% simulation parameters
simTime = 30; %simulation time in seconds
initialConditions = zeros(20,1); 
animateFlag = false; %set to true if you want to see the full animation, set to false if you only want plots
animateStepSize = 200; %bigger means you will see more fewer little quadcopter depictions in the animation/trajectory plot
% initialConditions(8)=-0.2; 
%initialConditions(1) = 0.1;
%initialConditions(9) = deg2rad(90);


%% controller parameters

%reference inputs
in.zDes = -2; %NOTE: This should always be negative
in.xDes = 0.9;
in.yDes = 1.1;
in.yawDes = deg2rad(0);

%PID gains
in.zP = 3;
in.zD = 4;
in.zI = 0.5;
in.xyP = 0.02; %using this for inner loop lateral controller
in.xyD = 0.09; 
in.xyI = 0; %unused 11-25-25
in.yawP = 0.3;
in.yawI = 0; %unused 1-8-26
in.yawD = 0.03;
in.pitchrollP = 0.0001;
in.pitchrollI = 0;
in.pitchrollD = 0.00008;
%in.rollP = 1;
%in.rollI = 0.1;
%in.rollD = 0.1;


%% model parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%quadcopter physical and electrical characteristics
in.batteryVoltage = 7.6; 
D = 55*10^-3; %prop diameter in m
in.L = 90*10^-3; %distance from center of one motor to anotherin m
in.La = in.L/sqrt(2); %arm length ASSUMES Lx = Ly (a sqare drone)
in.h = 12*10^-3; %height of the main drone body
a = 17*10^-3; %the width of the inner battery/electronics cuboid in m
b = 47*10^-3; %the depth of the inner battery/electronics cuboid in m
c = 12*10^-3; %the height of the inner battery/electronics cuboid in m
mb = 16*10^-3; % mass of the battery/electronics cuboid in kg
%mm = 3*10^-3; %mass of each motor in kg
%ma = .1*10^-3; %mass of each arm   
mProp = (1/7)*10^-3; %mass of prop in kg
in.Komega = .891*10^-3; %Vs/rad speed constant of the motor, calculated with Dr. Brown from nominal electrical characteristics
in.Ra = 0.6; %thevenin resistance of the motor, measured from real motor
in.Kt = .890*10^-3; %Nm/A torque constant of the motor, calculated with Dr. Brown from nominal electrical characteristics
in.TL = 0; %TODO load characteristics of motor (assuming no load right now- probably ok)


%other model parameters
in.IntLimit = 8;
rho = 1.225; %kg/m^3 air density
CT = 0.08; %dimensionless thrust coefficient associated with propeller (# from chatgpt)
CQ = 0.004; %dimensionless torque coefficient associated with propeller (# from chatgpt)
in.kThrust = CT*rho*D^4/(4*pi^2); %constant for relating thrust with motor speed
in.kTorque = CQ*rho*D^4/(4*pi^2); %constant for relating torque with motor speed
in.m = 0.068 + mb + mProp; %mass of copter in kg
in.g = 9.81; %gravitational acceleration

%moments of inertia (from geometry and chatgpt)
in.Jx = 1/12*in.m*(in.L^2+in.h^2);
in.Jy = 1/12*in.m*(in.L^2+in.h^2);
in.Jz = 1/12*in.m*(in.L^2+in.L^2);
in.Jprop = 1/6*mProp*D^2; 
%{
%% model parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%quadcopter physical and electrical characteristics
in.batteryVoltage = 7.6; 
D = 55*10^-3; %prop diameter in m
in.L = 20*10^-3; %distance from center of one motor to anotherin m
in.La = sqrt(1/2*in.L^2); %arm length ASSUMES Lx = Ly (a sqare drone)
a = 7*10^-3; %the width of the inner battery/electronics cuboid in m
b = 7*10^-3; %the depth of the inner battery/electronics cuboid in m
c = 3*10^-3; %the height of the inner battery/electronics cuboid in m
mb = 6*10^-3; % mass of the battery/electronics cuboid in kg
mm = 3*10^-3; %mass of each motor in kg
ma = .1*10^-3; %mass of each arm   
mProp = .5*10^-3; %mass of prop in kg
in.Komega = .891*10^-3; %Vs/rad speed constant of the motor, calculated with Dr. Brown from nominal electrical characteristics
in.Ra = 0.6; %thevenin resistance of the motor, measured from real motor
in.Kt = .890*10^-3; %Nm/A torque constant of the motor, calculated with Dr. Brown from nominal electrical characteristics
in.TL = 0; %TODO load characteristics of motor (assuming no load right now- probably ok)


%other model parameters
in.IntLimit = 1.3;
rho = 1.225; %kg/m^3 air density
CT = 0.08; %dimensionless thrust coefficient associated with propeller (# from chatgpt)
CQ = 0.004; %dimensionless torque coefficient associated with propeller (# from chatgpt)
in.kThrust = CT*rho*D^4/(4*pi^2); %constant for relating thrust with motor speed
in.kTorque = CQ*rho*D^4/(4*pi^2); %constant for relating torque with motor speed
in.m = mb + 4*mm + 4*ma; %mass of copter in grams
in.g = 9.81; %gravitational acceleration

%moments of inertia (from geometry and chatgpt)
in.Jx = 1/12*mb*(b^2+c^2) + 1/6*ma*in.La^2 + 2*mm*in.La^2; 
in.Jy = 1/12*mb*(a^2+c^2) + 1/6*ma*in.La^2 + 2*mm*in.La^2; 
in.Jz = 1/12*mb*(a^2+b^2) + 1/3*ma*in.La^2 + 4*mm*in.La^2;
in.Jprop = 1/6*mProp*D^2; 
%}
%Hover values
in.omega_hover = 6657.43; %approximated from the non-linear simulation
in.f_hover = in.kThrust*(in.omega_hover)^2;%calculated from omega_hover



%% run the simulation
opts = odeset('RelTol',1e-3,'AbsTol',1e-6,'MaxStep',0.01); % adjust MaxStep as needed
[tlist,Slist] = ode45(@(t,S)quadcopterDynamics(t,S,in),[0 simTime],initialConditions,opts);

%% %plot simulation results

% trajectory plot and animation
plotQuadTrajectory(tlist, Slist(:,1:3), Slist(:,7:9), in, 'FrameSize',in.La, 'SampleStep', animateStepSize, 'Animate', animateFlag);


%plot the position states
figure(3)
clf;
subplot(6,1,1)
plot(tlist,Slist(:,1),'m','Linewidth',2)
hold on
line([tlist(1), tlist(end)],[in.xDes,in.xDes],'color','k','linestyle','--')
hold off
xlim([tlist(1) tlist(end)])
title('position and orientation states over time')
ylabel('x')
subplot(6,1,2)
plot(tlist,Slist(:,2),'m','Linewidth',2)
hold on
line([tlist(1), tlist(end)],[in.yDes,in.yDes],'color','k','linestyle','--')
hold off
xlim([tlist(1) tlist(end)])
ylabel('y')
subplot(6,1,3)
plot(tlist,Slist(:,3),'m','Linewidth',2)
xlim([tlist(1) tlist(end)])
hold on
line([tlist(1), tlist(end)],[in.zDes,in.zDes],'color','k','linestyle','--')
hold off
xlim([tlist(1) tlist(end)])
ylabel('z')
subplot(6,1,4)
plot(tlist,Slist(:,7),'r','Linewidth',2)
xlim([tlist(1) tlist(end)])
ylabel('roll')
subplot(6,1,5)
plot(tlist,Slist(:,8),'r','Linewidth',2)
xlim([tlist(1) tlist(end)])
ylabel('pitch')
subplot(6,1,6)
plot(tlist,Slist(:,9),'r','Linewidth',2)
ylabel('yaw')
xlabel('t')
xlim([tlist(1) tlist(end)])

%plot motor speeds omega
figure(4)
clf;
subplot(4,1,1)
plot(tlist,Slist(:,13),'k','linewidth',2)
title('motor speed \omega')
ylabel('\omega_1')
subplot(4,1,2)
plot(tlist,Slist(:,14),'k','linewidth',2)
ylabel('\omega_2')
subplot(4,1,3)
plot(tlist,Slist(:,15),'k','linewidth',2)
ylabel('\omega_3')
subplot(4,1,4)
plot(tlist,Slist(:,16),'k','linewidth',2)
ylabel('\omega_4')

%plot the control and PID sections of the control for altitude/hover
%first calculate what the control was for each state and time step recorded by the simulation
Voltages = zeros(4, length(tlist)); 
PIDContributionsZ = zeros(4,length(tlist)); 
PIDContributionsYaw = zeros(4,length(tlist)); 
PIDContributionsX = zeros(4,length(tlist)); 
PIDContributionsY = zeros(4,length(tlist)); 
PIDContributionsPitch = zeros(4,length(tlist)); 
PIDContributionsRoll = zeros(4,length(tlist)); 
zError = zeros(1,length(tlist));
yawError = zeros(1,length(tlist));
pitchError = zeros(1,length(tlist));
rollError = zeros(1,length(tlist)); 
for k = 1:length(tlist)
    % [T,zError,yawError,pitchError,rollError,in]
    [Voltages(:,k),zError(k),yawError(k),pitchError(k),rollError(k),in] = hoverController(tlist(k),Slist(k,:)',in);
    PIDContributionsZ(:,k) = in.PIDContributionsZ; 
    PIDContributionsYaw(:,k) = in.PIDContributionsYaw; 
    PIDContributionsX(:,k) = in.PIDContributionsX; 
    PIDContributionsY(:,k) = in.PIDContributionsY; 
    PIDContributionsPitch(:,k) = in.PIDContributionsPitch; 
    PIDContributionsRoll(:,k) = in.PIDContributionsRoll; 
end

%plot control voltages for each motor
figure(5)
clf;
subplot(4,1,1)
plot(tlist,Voltages(1,:),'b','linewidth',2)
title('Control Voltages for the four motors')
ylabel('V1')
subplot(4,1,2)
plot(tlist,Voltages(2,:),'b','linewidth',2)
ylabel('V2')
subplot(4,1,3)
plot(tlist,Voltages(3,:),'b','linewidth',2)
ylabel('V3')
subplot(4,1,4)
plot(tlist,Voltages(4,:),'b','linewidth',2)
ylabel('V4')
xlabel('t')

%plot all the (state) error signals over time
figure(6)
clf;
subplot(6,1,1)
line([tlist(1), tlist(end)],[0,0],'color','k','linestyle','--')
hold on
plot(tlist,Slist(:,1)-in.xDes, 'm-.','linewidth',2)
hold off
title('Error signals')
ylabel('xError')
subplot(6,1,2)
line([tlist(1), tlist(end)],[0,0],'color','k','linestyle','--')
hold on
plot(tlist,Slist(:,2)-in.yDes,'m-.','linewidth',2)
hold off
ylabel('yError')
subplot(6,1,3)
line([tlist(1), tlist(end)],[0,0],'color','k','linestyle','--')
hold on
plot(tlist,zError,'m-.','linewidth',2)
hold off
ylabel('zError')
subplot(6,1,4)
line([tlist(1), tlist(end)],[0,0],'color','k','linestyle','--')
hold on
plot(tlist,rollError,'r-.','linewidth',2)
hold off
ylabel('rollError')
subplot(6,1,5)
line([tlist(1), tlist(end)],[0,0],'color','k','linestyle','--')
hold on
plot(tlist,pitchError,'r-.','linewidth',2)
hold off
ylabel('pitchError')
subplot(6,1,6)
line([tlist(1), tlist(end)],[0,0],'color','k','linestyle','--')
hold on
plot(tlist,yawError,'r-.','linewidth',2)
hold off
ylabel('yawError')
xlabel('t')

%plot PID contributions 
figure(7) %altitude controller
clf;
subplot(4,1,1)
plot(tlist,PIDContributionsZ(1,:),'linewidth',2)
hold on
plot(tlist,PIDContributionsX(1,:),'linewidth',2)
plot(tlist,PIDContributionsY(1,:),'linewidth',2)
plot(tlist,PIDContributionsYaw(1,:),'linewidth',2)
plot(tlist,PIDContributionsPitch(1,:),'linewidth',2)
plot(tlist,PIDContributionsRoll(1,:),'linewidth',2)
hold off
title('PID contributions ')
ylabel('P term')
subplot(4,1,2)
plot(tlist,PIDContributionsZ(2,:),'linewidth',2)
hold on
plot(tlist,PIDContributionsX(2,:),'linewidth',2)
plot(tlist,PIDContributionsY(2,:),'linewidth',2)
plot(tlist,PIDContributionsYaw(2,:),'linewidth',2)
plot(tlist,PIDContributionsPitch(2,:),'linewidth',2)
plot(tlist,PIDContributionsRoll(2,:),'linewidth',2)
hold off
ylabel('I term')
subplot(4,1,3)
plot(tlist,PIDContributionsZ(3,:),'linewidth',2)
hold on
plot(tlist,PIDContributionsX(3,:),'linewidth',2)
plot(tlist,PIDContributionsY(3,:),'linewidth',2)
plot(tlist,PIDContributionsYaw(3,:),'linewidth',2)
plot(tlist,PIDContributionsPitch(3,:),'linewidth',2)
plot(tlist,PIDContributionsRoll(3,:),'linewidth',2)
hold off
ylabel('D term')
subplot(4,1,4)
plot(tlist,PIDContributionsZ(4,:),'linewidth',2)
hold on
plot(tlist,PIDContributionsX(4,:),'linewidth',2)
plot(tlist,PIDContributionsY(4,:),'linewidth',2)
plot(tlist,PIDContributionsYaw(4,:),'linewidth',2)
plot(tlist,PIDContributionsPitch(4,:),'linewidth',2)
plot(tlist,PIDContributionsRoll(4,:),'linewidth',2)
hold off
legend('z','x','y','yaw','pitch','roll','location','west')
ylabel('error')
xlabel('t')




%% %dynamic model
function [Sdot,in] = quadcopterDynamics(t,S,in)
    % x = S(1); 
    % y = S(2); 
    % z = S(3); 
    xDot = S(4); 
    yDot = S(5); 
    zDot = S(6); 
    roll = S(7); 
    pitch = S(8); 
    yaw = S(9); 
    rollRate = S(10); 
    pitchRate = S(11); 
    yawRate = S(12); 
    omega = S(13:16); 
    % zErrorInt = S(17); 
    % yawErrorInt = S(18); 
    % pitchErrorInt = S(19); 
    % rollErrorInt = S(20); 

    
    %calculate control voltages 
    %closed Loop
    [V,zError,yawError,pitchError,rollError,in] = hoverController(t,S,in);
    
    %Open Loop
    %V = openLoopController(t,S,in)';
    %zError=0; yawError=0; pitchError=0; rollError=0;

    %torque request 
    T = in.Kt/in.Ra*(V-in.Komega*omega);

    %thrust from motors(thanks chatgpt)
    F = in.kThrust*(2*in.omega_hover*omega - in.omega_hover*[1 1 1 1]'); %thrust from ith motor

    %equations of motion for motor rotational speed
    omegaDot = 1/in.Jprop*(T-in.TL*ones(4,1)); %possibly TL should be proportional to omega or omega^2, it's load or drag force
%NOTE: I may adjust this later, but for now I'll leave it as ones(4,1)

    %equations of motion for position
    xyzDDot = -[(4*pitch*in.f_hover); -(4*roll*in.f_hover); (sum(F))] + [0;0;in.m*9.81];

    %equations of motion for orientation
    rollDDot = 1/in.Jx*( (F(1)+F(2))*in.L/2 - (F(3)+F(4))*in.L/2 ); 
    pitchDDot = 1/in.Jy*( (F(1)+F(4))*in.L/2 - (F(2)+F(3))*in.L/2 ); 
    yawDDot = 1/in.Jz*( T(1)-T(2)+T(3)-T(4)); 

    %aggregate the derivatives of all the states for function output
    Sdot = [xDot yDot zDot xyzDDot' rollRate pitchRate yawRate ...
        rollDDot pitchDDot yawDDot omegaDot' zError yawError pitchError rollError]';    

    disp(t)
    end


function R = rotationMatrix(roll, pitch, yaw)
% rotationMatrix  body->world rotation matrix (ZYX intrinsic)
% Convention: X = forward, Y = left, Z = up

cr = cos(roll); sr = sin(roll);
cp = cos(pitch); sp = sin(pitch);
cy = cos(yaw); sy = sin(yaw);

% elemental rotations (right-handed)
Rx = [1  0   0;
      0 cr -sr;
      0 sr  cr];

Ry = [ cp  0  sp;
       0   1   0;
      -sp  0  cp];

Rz = [ cy -sy  0;
       sy  cy  0;
        0   0  1];

% intrinsic Z-Y-X sequence (body -> world)
R = Rz * Ry * Rx;

% Sanity guard (helpful while debugging)
if abs(det(R) - 1) > 1e-10
    warning('rotationMatrix:detNotOne','det(R) = %g (expected +1). Check elemental signs.', det(R));
end
end


function plotQuadTrajectory(t, pos, ori, in, varargin)
%CHATGPT made a draft of this and I edited it to fit my liking -DF
% plotQuadTrajectory_Xfwd_Yleft(t, pos, eul, ...)
% 3D visualization for quadcopter with axis convention:
%   X = forward, Y = left, Z = up
%
% INPUTS
%   t   - Nx1 time vector
%   pos - Nx3 positions [x y z] in meters (same convention)
%   ori - Nx3 Euler angles [roll pitch yaw] in radians (rows)
%
% OPTIONAL NAME-VALUE PAIRS
%   'FrameSize'    - half arm length (default auto ~ 12% of XY spread)
%   'SampleStep'   - plot occasional full frames (default 100)
%   'ShowTrail'    - true/false (default true)
%   'Animate'      - true/false (default true)
%   'TrailLen'     - integer, length of short visible trail (default 80)
%   'AxisLimits'   - [xmin xmax ymin ymax zmin zmax] (default auto)
%
% Example:
%   plotQuadTrajectory(t, pos, ori, 'Animate', true);

% parse inputs
p = inputParser;
addRequired(p,'t',@isvector);
addRequired(p,'pos',@(x) size(x,2)==3);
addRequired(p,'ori',@(x) size(x,2)==3);
addParameter(p,'FrameSize',[],@(x) isempty(x) || (isnumeric(x)&&isscalar(x)&&x>0));
addParameter(p,'SampleStep',100,@(x) isnumeric(x) && isscalar(x) && x>=1);
addParameter(p,'ShowTrail',true,@islogical);
addParameter(p,'Animate',true,@islogical);
addParameter(p,'TrailLen',80,@(x) isnumeric(x) && isscalar(x) && x>0);
addParameter(p,'AxisLimits',[],@(x) isempty(x) || (isnumeric(x) && numel(x)==6));
parse(p,t,pos,ori,varargin{:});
opts = p.Results;

N = numel(t);
if size(pos,1)~=N || size(ori,1)~=N
    error('t, pos and ori must have same number of rows');
end

% convert degrees -> radians if necessary
if max(abs(ori(:))) > 2*pi
    ori = deg2rad(ori);
end

% Auto frame size if not provided
if isempty(opts.FrameSize) || opts.FrameSize==0
    xrange = max(pos(:,1)) - min(pos(:,1));
    yrange = max(pos(:,2)) - min(pos(:,2));
    typical = mean([xrange, yrange]);
    if typical <= 0
        L = 0.02;
    else
        L = 0.12 * typical;
    end
else
    L = opts.FrameSize;
end
axisScale = L * 0.7; %length of quiver arrows

% Precompute sample indices
sampleIdx = 1:opts.SampleStep:N;
nSamples = numel(sampleIdx);

% Body geometry in body frame (X forward, Y left, Z up) - X configuration
motors = [ L/sqrt(2)  L/sqrt(2)  0;   % front left
         -L/sqrt(2)  L/sqrt(2)  0;   % back left
          -L/sqrt(2)  -L/sqrt(2)  0;   % back right
          L/sqrt(2) -L/sqrt(2)  0];  % front right

% cross frame lines (pairs for drawing)
frameLines = [motors(1,:); motors(2,:); nan(1,3);
              motors(1,:); motors(4,:); nan(1,3);
              motors(3,:); motors(2,:); nan(1,3);
              motors(3,:); motors(4,:)];

% plot the trajectory of the copter on a static plot
figStatic = figure('Name','Quadcopter trajectory plot','Color','w');
axStatic = axes(figStatic); hold(axStatic,'on'); grid(axStatic,'on'); view(axStatic,3);
set(axStatic, 'YDir','reverse', 'ZDir','reverse');
xlabel(axStatic,'X (m)'); ylabel(axStatic,'Y (m)'); zlabel(axStatic,'Z (m)');
title(axStatic,'Quadcopter trajectory');

% axis limits
if isempty(opts.AxisLimits)
    pad = 0.5*max(std(pos));
    xmin = min(pos(:,1))-pad; xmax = max(pos(:,1))+pad;
    ymin = min(pos(:,2))-pad; ymax = max(pos(:,2))+pad;
    zmin = min(pos(:,3))-pad; zmax = max(pos(:,3))+pad;
    axis(axStatic,[xmin xmax ymin ymax zmin zmax]);
else
    axis(axStatic,opts.AxisLimits);
end
axis(axStatic,'equal');

% faint full trajectory for context
plot3(axStatic,pos(:,1),pos(:,2),pos(:,3), '-', 'Color', [0.85 0.85 0.85], 'LineWidth', 0.9);

% draw sampled frames, motors, axes and labels (visible)
for kk = 1:nSamples
    ii = sampleIdx(kk);
    Rk = rotationMatrix(ori(ii,1), ori(ii,2), ori(ii,3));
    flw = (Rk * frameLines')' + pos(ii,:);
    motw = (Rk * motors')' + pos(ii,:);
    plot3(axStatic, flw(:,1), flw(:,2), flw(:,3), '-', 'LineWidth', 1.0, 'Color', [0.2 0.2 0.2]);
    plot3(axStatic, motw(:,1), motw(:,2), motw(:,3), 'o', 'MarkerFaceColor', [0.6 0.6 0.6], ...
          'MarkerEdgeColor','k', 'MarkerSize',5);
    plot3(axStatic, pos(ii,1), pos(ii,2), pos(ii,3), 'bo', 'MarkerFaceColor', 'k', 'MarkerSize', 4); % black dot at CG
    xdir = (Rk * [1;0;0])' * axisScale;
    ydir = (Rk * [0;1;0])' * axisScale;
    zdir = (Rk * [0;0;1])' * axisScale;
    quiver3(axStatic, pos(ii,1), pos(ii,2), pos(ii,3), xdir(1),xdir(2),xdir(3), 'LineWidth',1.0, 'MaxHeadSize',0.5, 'Color','r');
    quiver3(axStatic, pos(ii,1), pos(ii,2), pos(ii,3), ydir(1),ydir(2),ydir(3), 'LineWidth',1.0, 'MaxHeadSize',0.5, 'Color','b');
    quiver3(axStatic, pos(ii,1), pos(ii,2), pos(ii,3), zdir(1),zdir(2),zdir(3), 'LineWidth',1.0, 'MaxHeadSize',0.5, 'Color','g');
    for m = 1:4
        text(axStatic, motw(m,1), motw(m,2), motw(m,3), sprintf('%d', m), ...
            'FontSize',8, 'FontWeight','bold', 'HorizontalAlignment','center', 'VerticalAlignment','bottom', 'Color',[0.1 0.1 0.1]);
    end
end

% Mark start and end on static snapshot as well
plot3(axStatic, pos(1,1), pos(1,2), pos(1,3), 'go', 'MarkerFaceColor','g');
plot3(axStatic, pos(end,1), pos(end,2), pos(end,3), 'ro', 'MarkerFaceColor','r');

% Mark desired hover position of copter 
plot3(axStatic, in.xDes,in.yDes,in.zDes,'p','Markersize',20,'color','m','linewidth',2)

drawnow;

% Optionally run the animation in a separate figure
if opts.Animate
    figAnim = figure('Name','Quadcopter animation','Color','w');
    axAnim = axes(figAnim); hold(axAnim,'on'); grid(axAnim,'on'); view(axAnim,3);
    set(axAnim, 'YDir','reverse', 'ZDir','reverse');
    xlabel(axAnim,'X (m)'); ylabel(axAnim,'Y (m)'); zlabel(axAnim,'Z (m)');
    title(axAnim,'Animation');

    % copy axis limits from static so the view matches
    axis(axAnim, axis(axStatic));    % copy numeric limits
    axis(axAnim, 'equal');           % enforce equal data-aspect ratio
    set(axAnim, 'DataAspectRatioMode', 'manual'); % ensure it stays manual
    axis(axAnim, 'vis3d');           % optional: lock aspect during rotations

    % static faint trajectory for context
    plot3(axAnim,pos(:,1),pos(:,2),pos(:,3), '-', 'Color', [0.85 0.85 0.85], 'LineWidth', 0.9);

    % initialize moving body at first pose
    R0 = rotationMatrix(ori(1,1), ori(1,2), ori(1,3));
    fl0 = (R0 * frameLines')' + pos(1,:);
    mot0 = (R0 * motors')' + pos(1,:);
    hFrame = plot3(axAnim, fl0(:,1), fl0(:,2), fl0(:,3), '-', 'LineWidth', 1.6, 'Color', [0.15 0.15 0.15]);
    hMotors = plot3(axAnim, mot0(:,1), mot0(:,2), mot0(:,3), 'o', 'MarkerFaceColor', [0.6 0.6 0.6], 'MarkerEdgeColor', 'k', 'MarkerSize', 6);
    hX = quiver3(axAnim, pos(1,1), pos(1,2), pos(1,3), 0,0,0, 'LineWidth',1.4, 'MaxHeadSize',0.6, 'Color','r');
    hY = quiver3(axAnim, pos(1,1), pos(1,2), pos(1,3), 0,0,0, 'LineWidth',1.2, 'MaxHeadSize',0.6, 'Color','b');
    hZ = quiver3(axAnim, pos(1,1), pos(1,2), pos(1,3), 0,0,0, 'LineWidth',1.2, 'MaxHeadSize',0.6, 'Color','g');
    hCurMarker = plot3(axAnim, pos(1,1), pos(1,2), pos(1,3), 'bo', 'MarkerFaceColor','b', 'MarkerSize',7);

    % animate
    trailLen = min(opts.TrailLen, N);
    for i = 1:N
        Ri = rotationMatrix(ori(i,1), ori(i,2), ori(i,3));
        flw = (Ri * frameLines')' + pos(i,:);
        motw = (Ri * motors')' + pos(i,:);
        set(hFrame, 'XData', flw(:,1), 'YData', flw(:,2), 'ZData', flw(:,3));
        set(hMotors, 'XData', motw(:,1), 'YData', motw(:,2), 'ZData', motw(:,3));
        set(hCurMarker, 'XData', pos(i,1), 'YData', pos(i,2), 'ZData', pos(i,3));
        % update axes arrows
        xdir = (Ri * [1;0;0])' * axisScale;
        ydir = (Ri * [0;1;0])' * axisScale;
        zdir = (Ri * [0;0;1])' * axisScale;
        set(hX, 'XData', pos(i,1), 'YData', pos(i,2), 'ZData', pos(i,3), 'UData', xdir(1), 'VData', xdir(2), 'WData', xdir(3));
        set(hY, 'XData', pos(i,1), 'YData', pos(i,2), 'ZData', pos(i,3), 'UData', ydir(1), 'VData', ydir(2), 'WData', ydir(3));
        set(hZ, 'XData', pos(i,1), 'YData', pos(i,2), 'ZData', pos(i,3), 'UData', zdir(1), 'VData', zdir(2), 'WData', zdir(3));

        % occasionally show a faint static sample frame on the animation
        if ismember(i, sampleIdx)
            plot3(axAnim, flw(:,1), flw(:,2), flw(:,3), '-', 'LineWidth',1.0, 'Color', [0.6 0.6 0.6]);
            plot3(axAnim, motw(:,1), motw(:,2), motw(:,3), 'o', 'MarkerFaceColor', [0.6 0.6 0.6], 'MarkerEdgeColor','k', 'MarkerSize',4);
        end

        drawnow limitrate;

        %MAKE IT A GIF
        % Name of the output file
        gifFile = 'quadcopterAnimation.gif';
        
        skip = 5; 
        if mod(i,skip) == 0 || i == N
            frame = getframe(figAnim);               % capture current frame
            im = frame2im(frame);                    % convert to image
            [imind, cm] = rgb2ind(im, 256);          % convert to indexed color
            
            if i == skip
                imwrite(imind, cm, gifFile, 'gif', 'Loopcount', inf, 'DelayTime', 0.1);
            else
                imwrite(imind, cm, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
            end
        end
    end
end

end



function [control, PIDContributions] = PIDController(error, errorDerivative, errorIntegral, Kp, Ki, Kd)
    %execute a basic PID controller
    control = Kp*error + Ki*errorIntegral + Kd*errorDerivative; 

    %in case you want to see the control for debugging purposes
    PIDContributions = [Kp*error, Ki*errorIntegral, Kd*errorDerivative, error];
end



function V = openLoopController(t,S,in)
    %pick a voltage open loop
    if t<1
        V = [1.256 1.256 1.256 1.256];%in.batteryVoltage*[.4 .4 0 0 ]'; 
    else
        V = [1.256 1.256 1.256 1.256]; 
    end
end

function [V,zError,yawError,pitchError,rollError,in] = hoverController(t,S,in)
    %assumes roll and pitch angles are small
    
    x = S(1); 
    y = S(2); 
    z = S(3); 
    xDot = S(4); 
    yDot = S(5); 
    zDot = S(6); 
    roll = S(7); 
    pitch = S(8); 
    yaw = S(9); 
    rollRate = S(10); 
    pitchRate = S(11); 
    yawRate = S(12); 
    omega = S(13:16);
    zErrorInt = S(17); 
    yawErrorInt = S(18); 
    pitchErrorInt = S(19); 
    rollErrorInt = S(20); 
     

    %altitude controller 
    zError = -(in.zDes - z); 
    zErrorDeriv = -(0 - zDot); %Note: the zero is there because the desired altitude is constant.
    zErrorInt2 = zErrorInt;

    %Quick fix for integral windup:
    if zErrorInt*in.zI > in.IntLimit
        zErrorInt2 = in.IntLimit/in.zI;
    end

    [thrustCommand, in.PIDContributionsZ] = ...
        PIDController(zError, zErrorDeriv, zErrorInt2, in.zP, in.zI, in.zD);

    
    %hold off on this until z works
    yawError = in.yawDes-yaw;
    yawErrorDeriv = 0 - yawRate;
    [yawCommand, in.PIDContributionsYaw] = ...
        PIDController(yawError, yawErrorDeriv, 0, in.yawP, in.yawI, in.yawD);

    %I think we will want to make the coordinate conversion before the
    %first PID controller -BS
    %x =  x*cos(yaw) + y*sin(yaw);
    %y = temp*sin(yaw) + y*cos(yaw);

    XError = in.xDes-x;
    YError = in.yDes-y;
    XDeriv = 0 - xDot;
    YDeriv = 0 - yDot;

    XErrorRel = XError*cos(yaw) + YError*sin(yaw);
    YErrorRel = -XError*sin(yaw) + YError*cos(yaw);
    XDerivRel = XDeriv*cos(yaw) + YDeriv*sin(yaw);
    YDerivRel = -XDeriv*sin(yaw) + YDeriv*cos(yaw);
    
    %XErrorRel = XError;
    %YErrorRel = YError;
    %XDerivRel = -xDot;
    %YDerivRel = -yDot;
    

    [pitchDes, in.PIDContributionsX] = ...
        PIDController(XErrorRel, XDerivRel, 0, in.xyP, in.xyI, in.xyD);

    [rollDes, in.PIDContributionsY] = ...
        PIDController(YErrorRel, YDerivRel, 0, in.xyP, in.xyI, in.xyD);
    
    pitchDes = -pitchDes;

    %TODO we don't remember why we were dividing by thrustCommand 1-15-26
    % rollDes = rollDes/abs(thrustCommand);
    % pitchDes = -pitchDes/abs(thrustCommand);

    %saturation on rollDes and pitchDes is great for preventing crazy behavior in a pinch
    %rollDes = max(-deg2rad(15), min(deg2rad(15), rollDes));
    %pitchDes = max(-deg2rad(15), min(deg2rad(15), pitchDes));

    rollError = rollDes - roll;
    rollDeriv = 0 - rollRate;
    [rollCommand, in.PIDContributionsRoll] = ...
        PIDController(rollError, rollDeriv, 0, in.pitchrollP, in.pitchrollI, in.pitchrollD);
    pitchError = pitchDes - pitch;
    pitchDeriv = 0 - pitchRate;
    [pitchCommand, in.PIDContributionsPitch] = ...
        PIDController(pitchError, pitchDeriv, 0, in.pitchrollP, in.pitchrollI, in.pitchrollD);
   
    %motor mixing algorithm
    % These are all in units of Newtons (thus the /in.La term)
    Mfr = thrustCommand - yawCommand/in.La + pitchCommand/in.La - rollCommand/in.La; %motor 4
    Mfl = thrustCommand + yawCommand/in.La + pitchCommand/in.La + rollCommand/in.La; %motor 1
    Mbr = thrustCommand + yawCommand/in.La - pitchCommand/in.La - rollCommand/in.La; %motor 3
    Mbl = thrustCommand - yawCommand/in.La - pitchCommand/in.La + rollCommand/in.La; %motor 2


    % steady state/past time step V calculation: 
    % Vss = in.Komega*omega + in.Kt/in.Ra*in.TL; 
    % V = (Vss + [Mfl Mbl Mbr Mfr]');

    V = [Mfl Mbl Mbr Mfr]';
    % 
    % nextV = V + deltaV; 

    for k = 1:length(V)
        if V(k) > in.batteryVoltage  
            V(k) = in.batteryVoltage; 
        elseif V(k) < 0
            V(k) = 0; 
        end
    end


end


