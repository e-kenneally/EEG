% lab 4 code %

clearvars;

fs = 256;
data = load("part1mux.mat");
y = data.y;
channels = 18;

start = 60; %s
fin = 90;
winlength = fin - start;
winSamples = winlength*fs;
idxStart = start*fs;
idxEnd = fin*fs;

grid_rows = ceil(sqrt(channels));
grid_cols = ceil(channels / grid_rows);

time = (0:(idxEnd-idxStart)) / fs;  % time vector in seconds


% plotting all channels just to see!
figure;

% skip channel 1 - ground  
% channel 2 is the trigger
for i = 2:channels
    eeg = y(i, idxStart:idxEnd);

    subplot(channels,1,i);
    plot(time, eeg, 'r');
    ylabel(sprintf('Ch %d', i));
    if i < channels
        set(gca,'XTick',[]); % hide x-axis except bottom
    else
        xlabel('Time (s)');
    end
end

% report part 1 - average all trials 

% get first channel (trigger)
trigger = y(1,:);
threshold = 0.5 * max(trigger);

% get time indices of tone onset
onsets = find(diff(trigger > threshold) == 1);

% define window - lab says 100 ms before, 500 ms after
pre  = 0.1; 
post = 0.5; 
win_samples = round([-pre*fs : post*fs]); 
epoch_length = length(win_samples);

n_trials = length(onsets);
n_channels = size(y,1);

% set empty array
epochs = zeros(n_channels-1, epoch_length, n_trials);

% loop over trials
for t = 1:n_trials
    onset = onsets(t);
    idx = onset + win_samples;
    
    % make sure its full length (otherwise avg. doesnt work)
    if idx(1) < 1 || idx(end) > size(y,2)
        continue;   % skip incomplete trials
    end
    
    epochs(:,:,t) = y(2:end, idx);
end

% average them for ERP! trials are in 3rd dim of epoch array
erp = mean(epochs, 3);
time_axis = win_samples / fs; 

figure;
offset = 20; 
hold on;
for ch = 2:(n_channels-1)
    plot(time_axis, erp(ch,:) + (ch-1)*offset, 'g');
end

% mark time 0 (stimulus onset)
xline(0, 'r--', 'LineWidth', 1.5);
hold off;

xlabel('Time');
yticks((0:n_channels-2)*offset);
yticklabels(arrayfun(@(x) sprintf('Ch %d',x+1), 1:(n_channels-1), 'UniformOutput', false));
title('ERP avg');
