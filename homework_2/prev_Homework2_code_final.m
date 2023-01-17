clear all;
close all;
clc;

load Received.mat

%% Initialise the parameters

c = 1500; %m.s-1 speed of sound

t_end = 2.5; %s
dt = 8.3361e-4; %s
t = 0.6252:dt:t_end; %time of sampling, maybe useless

h = 150; %depth of the channel

number_receivers = 9; % the number of receivers
x_receivers = 0; %could be whatever but (easier?) like this
z_receivers = 15:15:15*number_receivers; %15*5;%
number_reflections = 16; % 8 on each side of the channel

%x_table = length(1:1000);
%z_table = length(1:150);
%table = zeros(z_table,x_table);

% The furthest the source could be is d= 2.5 * 1500 = 3750 m. Given the
% delay, it should be less.
% Both sides should be symmetrical so we'll study only one side at first.

zin = 80;
zout= 100;
xin = -1040;
xout = 1040;
table=zeros(zin-zout,xin-xout);
step = 1;
z_range = zin:step:zout;
x_range = xin:step:xout;
table = zeros(size(z_range,2),size(x_range,2));
%table = zeros(150/10,(xout-xin)/10);

for j = 1:1:size(z_range,2) %zin:int(zout/zin):zout %the y (or z) in meters on the grid
    for i = 1:1:size(x_range,2) %xin:int(zout/zin):xout %flip 1000:1:0 %the x in meters on the grid
        %
        position = [z_range(j), x_range(i)]; %We get the potential position of the source in the grid.
        %         disp(position)
        
        summed_flipped_signals = zeros(1,5000); %Initialise the summed flipped signal each time.
        summed_delayed=zeros(1,5000);
        for n_r = 1:number_receivers % loop around the number of receivers.
            
            %             ded = [];
            
            delayed_flipped_signals=[];
            
            Arrayz_virtuals = Arrayofz(number_reflections,h,z_receivers(n_r));
            
            for n_virtual = Arrayz_virtuals % loop over the reflections .
                % Get the distance from the difference between position of the grid point and
                % virtual source
                if ~mod(number_reflections,2) % j is even
                    zdist = n_virtual-position(1);
                else         % j is odd
                    zdist = n_virtual+position(1);
                end
                distance = sqrt(position(2).^2 + zdist.^2);
                %                ded(end+1) = distance;
                
                % Get the signal from 1 receiver.
                
                delay = round((1/(dt*c))*distance);
                flipped_signal = flip(green(n_r,:)); % flip(green(n_r,:));
                delayed_flipped_signals = [zeros(1,delay) flipped_signal]/distance;
                
                if length(summed_delayed)>length(delayed_flipped_signals)
                    delayed_flipped_signals = [delayed_flipped_signals, zeros(1,(length(summed_delayed)-length(delayed_flipped_signals)))];
                else
                    summed_delayed = [summed_delayed, zeros(1,(length(delayed_flipped_signals)-length(summed_delayed)))];
                end
                
                summed_delayed= summed_delayed + delayed_flipped_signals;
            end
            % %             figure(1)
            % %             hold on
            % %             plot(summed_delayed+(n_r-1)*max(delayed_flipped_signal));
            %             % Sum the signals from all the receivers.
            if length(summed_flipped_signals)>length(summed_delayed)
                summed_delayed = [summed_delayed, zeros(1,(length(summed_flipped_signals)-length(summed_delayed)))];
            else
                summed_flipped_signals = [summed_flipped_signals, zeros(1,(length(summed_delayed)-length(summed_flipped_signals)))];
            end
            summed_flipped_signals = summed_flipped_signals + summed_delayed;
            summed_normalised = normalize(summed_flipped_signals);
        end
        %plot(summed_flipped_signals);
        % Stock the maximum of the summed signal in the table to see where
        % the source is.
        
        table(j,i)=max(summed_normalised);
        
        
    end
end

figure(2)
grid on
%pcolor(table)
image(table,'CDataMapping','scaled')
xticklabels((xticks*step)-step + x_range(1))%plot axes will be messed up resolutions lower to 1
yticklabels((yticks*step)- step + z_range(1))%plot axes will be messed up resolutions lower to 1
%image('CData',table)
%h1 = pcolor(table);
%set(h1, 'EdgeColor', 'none');

%h = heatmap(table,x_table,z_table);

%test = Arrayofz(3,h,z_receivers)
function[array]= Arrayofz(number_of_reflections,depth,z_original)

n_r = number_of_reflections;
array=[];
one=zeros(1);
for n = 0:n_r
    if ~mod(n,2) % j is even
        one= z_original+(n*depth);
    else         % j is odd
        one= z_original -(n + 1)*depth;
    end
    
    array = [array, one];
end

%array = [ -flip(array(3:end)), array];

end
