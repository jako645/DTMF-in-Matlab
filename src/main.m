clc
close all
clear all

%% FILE DESCRIPTION
% Authors:          Jakub Kokosiński
%                   Michał Kubik
% Project name:     DTMF
% Date:             7-04-2024

%% Read audio file
% Possible audio files:
%   - 3.m4a
%   - 5.m4a
%   - 7.m4a
%   - noise.m4a
[audio,fs] = audioread('../TestAudioFiles/7.m4a');
audioThreshold = 40;

dt = 1/fs;
s = length(audio);
tmax = s*dt;
timeVector = 0:dt:tmax-dt;
freqVector = (0:s-1)/s*fs;

figure
plot(timeVector, audio)
xlabel('Time [s]')
ylabel('Magnitude [~]')
title('Audio file in the time domain')

%% Apply Groetzel algorithm
dtmfFrequencies = [697 770 852 941 1209 1336 1477];
freqIndices = round(dtmfFrequencies/fs*s) + 1;   
dftAudio = goertzel(audio, freqIndices);

figure
stem(dtmfFrequencies, abs(dftAudio))
ax = gca;
ax.XTick = dtmfFrequencies;
xlabel('Frequency [Hz]')
ylabel('DFT Magnitude [~]')
title('DFT with second-order Goertzel algorithm')

%% Check threshold
freqAnswers = abs(dftAudio') >= audioThreshold;
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
elseif freqAnswers == noFreqAnswer(1:end)
    pressedButton = 'n'; % none
% freqAnswers has more than two '1' - error
else
    warning('Error occured when decoding frequencies. Recalibrate threshold level.')
end

%% Print output
if pressedButton ~= "n"
    fprintf("\nButton '%c' was pressed.\n\n", pressedButton)
end