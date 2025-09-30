%%% HW 1 - eck2180 %%%

clearvars;

fs = 256;
y = load("lab2_experiment1_1_group7.mat");
eeg = y.y;
time = (0:size(eeg,2)-1)/fs;
channels = size(eeg,1);

% I want to plot first 30 seconds 
startIdx=5*fs;
endIdx=30*fs;
figure;
for i = 1:channels
    subplot(channels,1,i);
    plot(time(startIdx:endIdx), eeg(i,startIdx:endIdx));
    xlabel('Time (s)');
    ylabel(sprintf('Ch %d', i));
    xlim([5 30]);
end
sgtitle('Raw EEG Data');


% Remove DC component 

eeg_noDC = eeg - mean(eeg);

figure;
for i = 1:channels
    subplot(channels,1,i);
    plot(time(startIdx:endIdx), eeg_noDC(i,startIdx:endIdx));
    xlabel('Time (s)');
    ylabel(sprintf('Ch %d', i));
    xlim([5 30]);
end
sgtitle('EEG no DC');

% Filter

alpha = eegfilt(eeg, fs, 8, 13);
beta = eegfilt(eeg, fs, 14, 32);

% got these values from the raw data screenshots
% changed these with every run
start = 152;
fin = 177;
idxStart = start*fs; 
idxEnd = fin*fs;

allPxx = [];

% loop over channels 
% skip first channel because it's ground
for i = 2:channels
    data = eeg(i,:);
    % alpha = eegfilt(data, fs, 8, 13);
    % beta = eegfilt(data, fs, 14, 32);
    
    segment  = data(idxStart:idxEnd);
    
    % power spectrum
    [pxx,f] = pwelch(segment, hamming(1024), [], [], fs);
    allPxx(:,i) = pxx;
    
end


allAlpha = [];
allBeta  = [];

for i = 2:channels
    data = eeg(i,:);

    % filter with eegfilt (from lab notes)
    alpha = eegfilt(data, fs, 8, 13);     
    beta  = eegfilt(data, fs, 14, 30);  

    % segment
    alpha_seg = alpha(idxStart:idxEnd);
    beta_seg  = beta(idxStart:idxEnd);

    [pxx_alpha,f] = pwelch(alpha_seg, hamming(1024), [], [], fs);
    [pxx_beta, ~] = pwelch(beta_seg,  hamming(1024), [], [], fs);

    allAlpha(:,i) = pxx_alpha;
    allBeta(:,i)  = pxx_beta;
end

% compute average for ease of reporting 
meanAlpha = mean(allAlpha,2);
meanBeta  = mean(allBeta,2);

figure;

subplot(2,1,1);
plot(f,10*log10(meanAlpha),'b','LineWidth',1.5);
xlim([0 40]);
ylabel('Power');
title('alpha average');

subplot(2,1,2);
plot(f,10*log10(meanBeta),'r','LineWidth',1.5);
xlim([0 40]);
ylabel('Power');
xlabel('Frequency');
title('beta average');

% changed with every iteration
sgtitle('touching electrodes');

% print out power
alphaPower = bandpower(meanAlpha, f, [8 13], 'psd')
betaPower  = bandpower(meanBeta,  f, [14 30],  'psd')