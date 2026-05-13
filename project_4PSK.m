% create random bits
n = 1024;
bits = randi([0 1], 1, n);

% M values
M_list = [2 4 8];

% Eb/N0 range
EbN0_dB = 0:0.1:10;
EbN0 = 10.^(EbN0_dB/10);

% line styles
lineStyles = {'b-', 'r--', 'k-.'};

% one window for all plots
figure;
tl = tiledlayout(4, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% store spectral efficiencies
spectral_efficiencies = zeros(size(M_list));

% bit error probability plot
axPb = nexttile(tl, 1);
hold(axPb, 'on');
grid(axPb, 'on');
title(axPb, 'Bit Error Probability');
xlabel(axPb, 'E_b/N_0 (dB)');
ylabel(axPb, 'P_b');

% % symbol error probability plot
axPs = nexttile(tl, 2);
hold(axPs, 'on');
grid(axPs, 'on');
title(axPs, 'Symbol Error Probability');
xlabel(axPs, 'E_b/N_0 (dB)');
ylabel(axPs, 'P_s');

% symbol error probability plot
% axPs = nexttile(tl, 2);
% hold(axPs, 'on');
% grid(axPs, 'on');
% grid(axPs, 'minor');
% 
% % use logarithmic y-axis for error probability
% set(axPs, 'YScale', 'log');
% 
% title(axPs, 'Symbol Error Probability');
% xlabel(axPs, 'E_b/N_0 (dB)');
% ylabel(axPs, 'Symbol Error Probability P_s');
% 
% % optional but recommended for probability plots
% ylim(axPs, [1e-6 1]);

%

% waveform plot, span two columns
axWave = nexttile(tl, 3, [1 2]);
hold(axWave, 'on');
grid(axWave, 'on');
title(axWave, 'Waveforms for 2-, 4- and 8-PSK');
xlabel(axWave, 'Time (s)');
ylabel(axWave, 'Amplitude');




for idx = 1:length(M_list)

    M = M_list(idx);
    % group bits into M-ary symbols
    k = log2(M);
    % Number of bits carried by each symbol.
    % For example, if M = 4, then k = log2(4) = 2.
    % This means every 2 bits form one PSK symbol.
    
    numSymbols = floor(n/k);
    % Calculate how many complete symbols can be formed from n bits.
    % floor() is used to round down, so incomplete leftover bits are ignored.
    % For example, if n = 1025 and k = 2, only 512 complete symbols can be formed.
    
    bitGroups = reshape(bits(1:numSymbols*k), k, []).';
    % Take only the bits that can form complete groups: bits(1:numSymbols*k).
    % reshape() rearranges the bit stream into groups of k bits.
    % k means each group has k bits.
    % [] lets MATLAB automatically calculate the number of columns needed.
    % .' transposes the matrix so that each row represents one symbol.
    % Example:
    % [1 0 0 1 1 1] becomes:
    % [1 0
    %  0 1
    %  1 1]
    
    symbols = bi2de(bitGroups, 'left-msb');
    % Convert each group of binary bits into a decimal symbol number.
    % 'left-msb' means the leftmost bit is the most significant bit.
    % Example:
    % [0 0] -> 0
    % [0 1] -> 1
    % [1 0] -> 2
    % [1 1] -> 3
    
    % map symbols to phase
    phase = 2*pi*symbols/M;
    
    % generate waveform for one symbol
    fc = 100e3;
    Eb = 1;
    T = 0.1e-3;
    Es = Eb * log2(M);
    
    t_vec = linspace(0, T, 100);
    
   
    s = sqrt(2*Es/T) * cos(2*pi*fc*t_vec - phase(1));
    
    % check the probabilities
    
    if M == 2
        % 2-PSK / BPSK
        P_b = qfunc(sqrt(2 * EbN0));
        P_s = P_b;

    elseif M == 4
        % 4-PSK / QPSK, using the lab sheet formula
        P_b = qfunc(sqrt(2 * EbN0));
        P_s = erfc(sqrt(EbN0));

    elseif M == 8
    % 8-PSK with Gray mapping
      k = log2(M);
      P_s = 2 .* qfunc(sqrt(2 .* k .* EbN0) .* sin(pi ./ M));
      P_b = P_s ./ k;
    end


   % plot bit error probability
    semilogy(axPb, EbN0_dB, P_b, lineStyles{idx}, ...
        'LineWidth', 1.5, ...
        'DisplayName', [num2str(M) '-PSK']);

    % plot symbol error probability
    semilogy(axPs, EbN0_dB, P_s, lineStyles{idx}, ...
        'LineWidth', 1.5, ...
        'DisplayName', [num2str(M) '-PSK']);

    % plot all waveforms in the same axes
    plot(axWave, t_vec, s, lineStyles{idx}, ...
        'LineWidth', 1.2, ...
        'DisplayName', [num2str(M) '-PSK']);

    % save spectral efficiency
    spectral_efficiencies(idx) = log2(M);

    % constellation plot
    idealSymbols = 0:M-1;
    idealPhase = 2*pi*idealSymbols/M;

    I_coord = cos(idealPhase);
    Q_coord = sin(idealPhase);

    axConst = nexttile(tl, 4 + idx);
    scatter(axConst, I_coord, Q_coord, 'filled');
    grid(axConst, 'on');
    axis(axConst, 'equal');
    title(axConst, [num2str(M) '-PSK Constellation']);
    xlabel(axConst, 'In-phase');
    ylabel(axConst, 'Quadrature');


end


% spectral efficiency plot
axSpec = nexttile(tl, 8);
bar(axSpec, M_list, spectral_efficiencies);
grid(axSpec, 'on');
xlabel(axSpec, 'M');
ylabel(axSpec, 'bits/s/Hz');
title(axSpec, 'Spectral Efficiency');

% legends
legend(axPb, 'show');
legend(axPs, 'show');
legend(axWave, 'show');
