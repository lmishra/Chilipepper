%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Model/simulation parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OS_RATE = 8;
SNR = 100;
fc = 10e3/20e6; % sample rate is 20 MHz, top is 10 kHz offset
muFOC = floor(.01*2^12)/2^12;
muTOC = floor(.01*8*2^12)/2^12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize LUTs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
make_srrc_lut;
make_train_lut;
make_trig_lut;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Emulate microprocessor packet creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data payload creation
messageASCII = 'hello world!';
message = double(unicode2native(messageASCII));
% add on length of message to the front with four bytes
msgLength = length(message);
messageWithNumBytes =[ ...
    mod(msgLength,2^8) ...
    mod(floor(msgLength/2^8),2^8) ...
    mod(floor(msgLength/2^16),2^8) ...
    1 ... % message ID
    message];
% add two bytes at the end, which is a CRC
messageWithCRC = CreateAppend16BitCRC(messageWithNumBytes);
ml = length(messageWithCRC);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FPGA radio transmit core
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_in = 0;
empty_in = 1;
tx_en_in = 0;
numBytesFromFifo = 0;
num_samp = ml*8*2*2*3;
x = zeros(1,num_samp);
CORE_LATENCY = 4;
data_buf = zeros(1,CORE_LATENCY);
empty_buf = ones(1,CORE_LATENCY);
clear_buf = zeros(1,CORE_LATENCY);
tx_en_buf = zeros(1,CORE_LATENCY);
for i1 = 1:num_samp
    % first thing the processor does is clear the internal tx fifo
    if i1 == 1
        clear_fifo_in = 1;
    else
        clear_fifo_in = 0;
    end

    if i1 == 5 % wait a little bit then begin to load the fifo
        empty_in = 0;
        numBytesFromFifo = 0;
    end

    data_buf = [data_buf(2:end) data_in];
    empty_buf = [empty_buf(2:end) empty_in];
    clear_buf = [clear_buf(2:end) clear_fifo_in];
    tx_en_buf = [tx_en_buf(2:end) tx_en_in];
    [i_out, q_out, re_byte_out, tx_done_out, d1, d2, d3] = ...
        qpsk_tx(data_buf(1),empty_buf(1),clear_buf(1),tx_en_buf(1));
    x_out = complex(i_out,q_out)/2^11;
    x(i1) = x_out;

    %%% Emulate read FIFO AXI interface
    if re_byte_out == 1 && numBytesFromFifo < length(messageWithCRC)
        data_in = messageWithCRC(numBytesFromFifo+1);
        numBytesFromFifo = numBytesFromFifo + 1;
    end
    % processor loaded all bytes into FIFO so begin transmitting
    if numBytesFromFifo == length(messageWithCRC)
        empty_in = 1;
        tx_en_in = 1;
    end    
end
if 1 % load data that was transmitted and captured from chipscope
    if 1
        fid = fopen('tx.prn');
        M = textscan(fid,'%d %d %d %d %d %d %d %d %d %d','Headerlines',1);
        fclose(fid);
        iFile = double(M{3})'/2^11;
        qFile = double(M{4})'/2^11;
    else
        M = load('dac.prn');
        if M(1,end-1) == 0
            iFile = M(1:2:end,end)'/2^11;
            qFile = M(2:2:end,end)'/2^11;
        else
            qFile = M(1:2:end,end)'/2^11;
            iFile = M(2:2:end,end)'/2^11;
        end
    end
    x = complex(iFile,qFile);
end

index = find(abs(x) > sum(SRRC))+24*8; % constant is pad bits
offset = index(1)+6+length(TB_i)*OS_RATE;
idx = offset:8:(offset+8*ml*4-1);
y = x(idx); % four symbos per byte of data
sc = zeros(1,18*8);
sc(1:2:end) = real(y);
sc(2:2:end) = imag(y);
sh = sign(sc);
sb = (sh+1)/2;
d = zeros(1,ml);
for i1 = 1:ml
    si = sb(1+(i1-1)*8:i1*8);
    d(i1) = bi2de(si);
end
figure(1)
clf
plot(real(x))
hold on
plot(idx,real(y),'ro')
title('Transmit samples');

error_tx = sum(abs(d-messageWithCRC));
if error_tx == 0
    disp('Transmitted message correctly');
else
    disp('Transmitted message incorrectly');
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Emulate channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pad on either side with zeros
p = complex(zeros(1,100),zeros(1,100));
xp = [p x p]; % pad

% Apply frequency offset and receive/over-the-air AWGN
y = xp.*exp(1i*2*pi*fc*(0:length(xp)-1));
rC = y/max(abs(y))*.1*2^11; % this controls receive gain
r = awgn(rC,SNR,0,1);
r = rC;
if 0
    %M = load('rx.prn');
    fid = fopen('rx.prn');
    %M = textscan(fid,'%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d','Headerlines',1);
    M = textscan(fid,'%d %d %d %d','Headerlines',1);
    fclose(fid);
    is = double(M{3});
    qs = double(M{4});
    r = complex(is,qs);
    figure(3)
    subplot(2,1,1);
    plot(is);
    subplot(2,1,2);
    plot(qs)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main receiver core
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = zeros(1,length(r));
r_out = zeros(1,length(r));
s_f = zeros(1,length(r));
s_t = zeros(1,length(r));
tau = zeros(1,length(r));
s_o = zeros(1,length(r));
o = zeros(1,length(r));
bytes = zeros(1,ml); byte_count = 0;
for i1 = 1:length(r)+200
    if i1 == 1
        mcu_rdy = 0;
    else
        mcu_rdy = 1;
    end
    if i1 > length(r)
        r_in = 0;
    else
        r_in = r(i1);
    end
    i_in = round(real(r_in));
    q_in = round(imag(r_in));
    [byte, en, clear_fifo(i1), num_bytes_ready_out, ...
        r_out(i1), s_f(i1), s_c(i1), s_t(i1), t_est(i1), s_p(i1), s_o(i1), ...
        fe_out(i1)] = ...
        qpsk_rx(i_in, q_in, floor(muFOC*2^12), floor(muTOC*2^12), mcu_rdy);

    if en == 1
        byte_count = byte_count + 1;
        bytes(byte_count) = byte;
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(2)
subplot(2,4,1)
scatter(real(r),imag(r))
title('OTA Receive Signal');
subplot(2,4,5)
plot(real(r_out));
title('OTA Receive Signal (real part)');
subplot(2,4,2)
scatter(real(s_f),imag(s_f))
title('Signal Post FOC');
subplot(2,4,6)
plot(real(s_f));
title('Signal Post FOC (real part)');
subplot(2,4,3)
scatter(real(s_t),imag(s_t))
title('Signal Post TOC');
subplot(2,4,7)
plot(t_est);
title('Time estimate');
subplot(2,4,4)
plot(real(s_p));
title('Message bits');
axis([0 length(s_p) -1.25 1.25]);
subplot(2,4,8)
plot(s_o);
title('Correlation magnitude');
axis([0 length(s_o) 0 160]);

numRecBytes = bytes(1)+bytes(2)+bytes(3);
msgBytes = bytes((1+4):(numRecBytes+4));
if sum(msgBytes-message) == 0
    disp('Received message correctly');
else
    disp('Received message incorrectly');
end    
native2unicode(bytes);
native2unicode(msgBytes)

if 0
    bs = double(M{end-1});
    es = double(M{end});
    recBytes = bs(find(es==1));
    native2unicode(recBytes')
end




