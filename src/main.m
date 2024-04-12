clc
close all
clear all

%% FILE DESCRIPTION
% Authors:          Jakub Kokosiński
%                   Michał Kubik
% Project name:     DTMF
% Date:             7-04-2024

%% Script parameters
recDuration = 2;        % for recording object
fs = 16000;
recNBits = 8;
recNChannels = 1;

audioThreshold = 40;    % for signal processing

%% Record audio
recObj = audiorecorder(fs, recNBits, recNChannels);
fprintf("Begin speaking.\n")
recordblocking(recObj,recDuration);
fprintf("End of recording.\n")

%% Set signal parameters
audio = getaudiodata(recObj);

dt = 1/fs;
s = recDuration/dt;
timeVector = 0:dt:recDuration-dt;
freqVector = (0:s-1)/s*fs;

% plot recorded signal in time domain
figure
plot(timeVector, audio)
xlabel('Time [s]')
ylabel('Magnitude [~]')
title('Audio file in the time domain')

%% Apply Groetzel algorithm
dtmfFrequencies = [697 770 852 941 1209 1336 1477];
freqIndices = round(dtmfFrequencies/fs*s) + 1;   
dftAudio = goertzel(audio, freqIndices);
dftAudio = abs(dftAudio');

% plot dft of recorded signal 
figure
stem(dtmfFrequencies, dftAudio)
ax = gca;
ax.XTick = dtmfFrequencies;
xlabel('Frequency [Hz]')
ylabel('DFT Magnitude [~]')
title('DFT with second-order Goertzel algorithm')

%% Get two frequencies with the greatest magnitude
[~, greatestLowFreqPosition] = max(dftAudio(1:4));
[~, greatestHighFreqPosition] = max(dftAudio(5:7));
greatestHighFreqPosition = greatestHighFreqPosition + 4;

%% Check threshold
freqAnswers = zeros(1, 7);
freqAnswers(greatestLowFreqPosition) = dftAudio(greatestLowFreqPosition) >= audioThreshold;
freqAnswers(greatestHighFreqPosition) = dftAudio(greatestHighFreqPosition) >= audioThreshold;
freqAnswers = double(freqAnswers);

%% Get output
freqPossibleAnswers = [
   %[697 770 852 941 1209 1336 1477]
    [1   0   0   0   1    0    0];    % 1
    [1   0   0   0   0    1    0];    % 2
    [1   0   0   0   0    0    1];    % 3
    [0   1   0   0   1    0    0];    % 4
    [0   1   0   0   0    1    0];    % 5
    [0   1   0   0   0    0    1];    % 6
    [0   0   1   0   1    0    0];    % 7
    [0   0   1   0   0    1    0];    % 8
    [0   0   1   0   0    0    1];    % 9
    [0   0   0   1   1    0    0];    % *
    [0   0   0   1   0    1    0];    % 0
    [0   0   0   1   0    0    1]];   % #

noFreqAnswer = [0   0   0   0   0    0    0];

% freqAnswers has two '1' - button was pressed
if freqAnswers == freqPossibleAnswers(1, 1:end)
    pressedButton = '1';
elseif freqAnswers == freqPossibleAnswers(2, 1:end)
    pressedButton = '2';
elseif freqAnswers == freqPossibleAnswers(3, 1:end)
    pressedButton = '3';
elseif freqAnswers == freqPossibleAnswers(4, 1:end)
    pressedButton = '4';
elseif freqAnswers == freqPossibleAnswers(5, 1:end)
    pressedButton = '5';
elseif freqAnswers == freqPossibleAnswers(6, 1:end)
    pressedButton = '6';
elseif freqAnswers == freqPossibleAnswers(7, 1:end)
    pressedButton = '7';
elseif freqAnswers == freqPossibleAnswers(8, 1:end)
    pressedButton = '8';
elseif freqAnswers == freqPossibleAnswers(9, 1:end)
    pressedButton = '9';
elseif freqAnswers == freqPossibleAnswers(10, 1:end)
    pressedButton = '*';
elseif freqAnswers == freqPossibleAnswers(11, 1:end)
    pressedButton = '0';
elseif freqAnswers == freqPossibleAnswers(12, 1:end)
    pressedButton = '#';
% freqAnswers has no '1' - no button was pressed
elseif sum(freqAnswers(:) == 1) == 0
    pressedButton = 'n'; % none
% freqAnswers has one '1' - warning
else
    pressedButton = 'n'; % none
    warning('Error occured when decoding frequencies. Recalibrate threshold level.')
end

%% Print output
if pressedButton ~= "n"
    fprintf("\nButton '%c' was pressed.\n\n", pressedButton)
end