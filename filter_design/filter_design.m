%% Design FIR filters
n_taps = 30;
fs = 48000;

fc_lpf = 1000;
wc_lpf = 2 * fc_lpf / fs;
lpf = fir1(n_taps, wc_lpf, chebwin(n_taps+1));

fc_bpf = [3000, 4000];
wc_bpf = 2 .* fc_bpf ./ fs;
bpf = fir1(n_taps, wc_bpf, chebwin(n_taps+1));

fc_hpf = 1400;
wc_hpf = 2 * fc_hpf / fs;
hpf = fir1(n_taps, 0.15, 'high', chebwin(n_taps+1));

%% Write to file
fileID = fopen('lpf.txt','w');
for i = 0:n_taps
    val = round(lpf(i+1)*1024);
    if (val >= 0); sign = ""; else; sign = "-"; end
    output = fprintf(fileID, "5'd%d:\tcoeff = %s11'sd%d;\n", i, sign, abs(val));
end
fclose(fileID);
    
fileID = fopen('bpf.txt','w');
for i = 0:n_taps
    val = round(bpf(i+1)*1024);
    if (val >= 0); sign = ""; else; sign = "-"; end
    output = fprintf(fileID, "5'd%d:\tcoeff = %s11'sd%d;\n", i, sign, abs(val));
end
fclose(fileID);
    
fileID = fopen('hpf.txt','w');
for i = 0:n_taps
    val = round(hpf(i+1)*1024);
    if (val >= 0); sign = ""; else; sign = "-"; end
    output = fprintf(fileID, "5'd%d:\tcoeff = %s11'sd%d;\n", i, sign, abs(val));
end
fclose(fileID);
    

%% Plot frequency response
figure;
subplot(3,1, 1)
[h_l, w_l] = freqz(lpf, 1);
semilogx(w_l/pi*fs, db(h_l))
title('Low Pass Filter')

% figure;
subplot(3,1, 2)
[h_b, w_b] = freqz(bpf, 1);
semilogx(w_b/pi*fs, db(h_b))
ylabel('$|H(\Omega)|$ [dB]', 'Interpreter', 'latex')
title('Band Pass Filter')

% figure;
subplot(3,1, 3)
[h_h, w_h] = freqz(hpf, 1);
semilogx(w_h/pi*fs, db(h_h))
xlabel("Frequency [Hz]")
title('High Pass Filter')

%% Design shelving filters
gain = 5; % gain in dB for shelves
slope = 0.5;
fc_low = 600;
wc_low = 2 * fc_low / fs;
[B1, A1] = designShelvingEQ(gain, slope, wc_low, "Orientation", "row");

fvtool( ...
    dsp.BiquadFilter([B1,A1]), ...
    "Fs", fs, ...
    "FrequencyScale", "Log");


