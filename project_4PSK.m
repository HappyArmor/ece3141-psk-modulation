% create random bits
n = 1024;
bits = randi([0 1], 1, n);

% let M = 4
M_list = [2 4 8];
for M = M_list
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
    
    t = linspace(0, T, 100);
    
    % plot first symbol waveform
    s = sqrt(2*Es/T) * cos(2*pi*fc*t - phase(1));

    figure;
    plot(t, s);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title([num2str(M) '-PSK waveform for one symbol']);
    grid on;

    % plot ideal constellation points
    idealSymbols = 0:M-1;
    idealPhase = 2*pi*idealSymbols/M;

    I = cos(idealPhase);
    Q = sin(idealPhase);

    figure;
    scatter(I, Q, 'filled');
    xlabel('In-phase');
    ylabel('Quadrature');
    title([num2str(M) '-PSK Constellation Diagram']);
    grid on;
    axis equal;
end