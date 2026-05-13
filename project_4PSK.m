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

% symbol error probability plot
axPs = nexttile(tl, 2);
hold(axPs, 'on');
grid(axPs, 'on');
title(axPs, 'Symbol Error Probability');
xlabel(axPs, 'E_b/N_0 (dB)');
ylabel(axPs, 'P_s');

% waveform plot, span two columns
axWave = nexttile(tl, 3, [1 2]);
hold(axWave, 'on');
grid(axWave, 'on');
title(axWave, 'Waveforms for 2-, 4- and 8-PSK');
xlabel(axWave, 'Time (s)');
ylabel(axWave, 'Amplitude');

for idx = 1:length(M_list)

    M = M_list(idx);

    % number of bits per symbol
    k = log2(M);

    % number of complete symbols
    numSymbols = floor(n/k);

    % group bits into symbols
    bitGroups = reshape(bits(1:numSymbols*k), k, []).';

    % convert bit groups to decimal symbols
    symbols = bi2de(bitGroups, 'left-msb');

    % map symbols to phase
    phase = 2*pi*symbols/M;

    % signal parameters
    fc = 100e3;
    Eb = 1;
    T = 0.1e-3;
    Es = Eb * k;

    % generate waveform for several symbols
    samplesPerSymbol = 200;
    numPlotSymbols = 8;

    t_total = [];
    s_total = [];

    for m = 1:numPlotSymbols

        t_sym = linspace((m-1)*T, m*T, samplesPerSymbol);

        s_sym = sqrt(2*Es/T) * ...
            cos(2*pi*fc*t_sym - phase(m));

        t_total = [t_total t_sym];
        s_total = [s_total s_sym];

    end

    % calculate error probabilities
    if M == 2
        % 2-PSK / BPSK
        P_b = qfunc(sqrt(2 * EbN0));
        P_s = P_b;

    elseif M == 4
        % 4-PSK / QPSK
        P_b = qfunc(sqrt(2 * EbN0));
        P_s = erfc(sqrt(EbN0));

    elseif M == 8
        % 8-PSK with Gray mapping
        P_s = 2 .* qfunc(sqrt(2 .* k .* EbN0) .* sin(pi ./ M));
        P_b = P_s ./ k;
    end
    xlim(axWave, [0 4/fc]);

    % plot bit error probability
    semilogy(axPb, EbN0_dB, P_b, lineStyles{idx}, ...
        'LineWidth', 1.5, ...
        'DisplayName', [num2str(M) '-PSK']);

    % plot symbol error probability
    semilogy(axPs, EbN0_dB, P_s, lineStyles{idx}, ...
        'LineWidth', 1.5, ...
        'DisplayName', [num2str(M) '-PSK']);

    % plot multi-symbol waveform
    plot(axWave, t_total, s_total, lineStyles{idx}, ...
        'LineWidth', 1.2, ...
        'DisplayName', [num2str(M) '-PSK']);

    % save spectral efficiency
    spectral_efficiencies(idx) = k;

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
