clc; clear; close all;

%% Parameters
n = 1024;              % number of bits
fc = 100e3;            % carrier frequency = 100 kHz
Eb = 1;                % energy per bit
T = 0.1e-3;            % symbol duration = 0.1 ms
Fs = 10e6;             % sampling frequency
EbN0_dB = 0:1:10;
EbN0 = 10.^(EbN0_dB/10);

bits = randi([0 1], 1, n);

M_values = [2 4 8];

%% Time-domain PSK waveforms
figure;

for k = 1:length(M_values)
    M = M_values(k);
    bps = log2(M);              % bits per symbol
    Es = Eb * bps;              % symbol energy

    bit_matrix = reshape(bits(1:floor(n/bps)*bps), bps, []).';
    symbols = bi2de(bit_matrix, 'left-msb');

    phases = 2*pi*symbols/M;

    num_symbols_plot = 8;
    t_symbol = 0:1/Fs:T-1/Fs;
    waveform = [];

    for i = 1:num_symbols_plot
        s = sqrt(2*Es/T) * cos(2*pi*fc*t_symbol - phases(i));
        waveform = [waveform s];
    end

    t = (0:length(waveform)-1)/Fs;

    subplot(3,1,k);
    plot(t*1e3, waveform);
    grid on;
    xlabel('Time (ms)');
    ylabel('Amplitude');
    title([num2str(M) '-PSK Time-Domain Waveform']);
end

%% Error probability calculations
Pb_2 = qfunc(sqrt(2*EbN0));
Ps_2 = Pb_2;

Pb_4 = qfunc(sqrt(2*EbN0));
Ps_4 = erfc(sqrt(EbN0));

M = 8;
Ps_8 = 2*qfunc(sqrt(2*log2(M)*EbN0) * sin(pi/M));
Pb_8 = Ps_8 / log2(M);

%% Plot bit error probability
figure;
semilogy(EbN0_dB, Pb_2, 'o-', 'LineWidth', 1.5); hold on;
semilogy(EbN0_dB, Pb_4, 's-', 'LineWidth', 1.5);
semilogy(EbN0_dB, Pb_8, '^-', 'LineWidth', 1.5);
grid on;
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Probability P_b');
title('Bit Error Probability of M-PSK');
legend('2-PSK', '4-PSK', '8-PSK');

%% Plot symbol error probability
figure;
semilogy(EbN0_dB, Ps_2, 'o-', 'LineWidth', 1.5); hold on;
semilogy(EbN0_dB, Ps_4, 's-', 'LineWidth', 1.5);
semilogy(EbN0_dB, Ps_8, '^-', 'LineWidth', 1.5);
grid on;
xlabel('E_b/N_0 (dB)');
ylabel('Symbol Error Probability P_s');
title('Symbol Error Probability of M-PSK');
legend('2-PSK', '4-PSK', '8-PSK');
