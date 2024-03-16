%% OPIS SKRYPTU
%{
Autorzy:        Jakub Kokosiński, Michał Kubik
Projekt:        DTMF
Funkcjonalnosc:
    - nagranie i odczyt do pliku wav w pętli
    - nieskończona pętla
    - dekodowanie sygnału funkcją goertzel()
    - wyświetlenie wyniku w postaci grafu
    - dekodowanie wartości do zmiennej typu char
%}

%% USTAWIENIA
close all
clear all

audiofilename = 'audio_for_dtmf_v2_2.wav';

freq_treshhold = 20;    % próg uwzględniania odpowiedzi 

tic_toc_time = 0.1;     % czas trwania nagrywania

deviceReader = audioDeviceReader;   % ustawienia nagrywania dźwięku
setup(deviceReader)

%% MAIN LOOP

while 1 == 1
    %% NAGRYWANIE
    fileWriter = dsp.AudioFileWriter(audiofilename,'FileFormat','WAV', 'SampleRate', 44100);
    disp('Speak into microphone now.')
    tic
    while toc < tic_toc_time
        acquiredAudio = deviceReader();
        fileWriter(acquiredAudio);
    end
    disp('Recording complete.')
    
    clf
    
    %% WCZYTANIE SYGNAŁU WEJŚCIOWEGO
    [data, Fs] = audioread(audiofilename);
    data = data';
    
    %% WYKRES W DZIEDZINIE CZASU
    N = length(data);
    T = 1/Fs;
    t = (0:N-1)*T;
    
    figure(1)
    plot(t, data)
    xlabel('Time (s)')
    ylabel('Magnitude')
    
    %% WYZNACZANIE ODPOWIEDZI GOERTZEL'A
    f = [697 770 852 941 1209 1336 1477];
    freq_indices = round(f/Fs*N) + 1;
    dft_data = goertzel(data,freq_indices);
    
    %% WYKRES DLA GOERTZEL'A
    figure(2)
    stem(f,abs(dft_data))
    
    ax = gca;
    ax.XTick = f;
    xlabel('Frequency (Hz)')
    ylabel('DFT Magnitude')
    
    %% ODPOWIEDŹ DLA GOERTZEL'A
    freq_ans = [];
    for i = 1:7
        if abs(dft_data(i)) >= freq_treshhold
            freq_ans(i) = 1;
        else
            freq_ans(i) = 0;
        end
    end
    
    freq_possible_ans = [
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
        [0   0   0   1   0    0    1];    % #
        ];
    
    if freq_ans == freq_possible_ans(1, 1:end)
        pressed_button = '1';
    elseif freq_ans == freq_possible_ans(2, 1:end)
        pressed_button = '2';
    elseif freq_ans == freq_possible_ans(3, 1:end)
        pressed_button = '3';
    elseif freq_ans == freq_possible_ans(4, 1:end)
        pressed_button = '4';
    elseif freq_ans == freq_possible_ans(5, 1:end)
        pressed_button = '5';
    elseif freq_ans == freq_possible_ans(6, 1:end)
        pressed_button = '6';
    elseif freq_ans == freq_possible_ans(7, 1:end)
        pressed_button = '7';
    elseif freq_ans == freq_possible_ans(8, 1:end)
        pressed_button = '8';
    elseif freq_ans == freq_possible_ans(9, 1:end)
        pressed_button = '9';
    elseif freq_ans == freq_possible_ans(10, 1:end)
        pressed_button = '*';
    elseif freq_ans == freq_possible_ans(11, 1:end)
        pressed_button = '0';
    elseif freq_ans == freq_possible_ans(12, 1:end)
        pressed_button = '#';
    else
        pressed_button = 'null';
    end
    
    pressed_button    % wyświetlenie odpowiedzi
    
    pause(0.0000001)
end

release(deviceReader)
release(fileWriter)