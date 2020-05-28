function calibrateAudio



[levels_L,levels_R]=calibrateAudio(freq_interp,phon,filters)

% if ~exist('filters','var')
%     filters='disc_dec14_2011';
%     disp(['Using ', filters, ' headphone filters'])
% end
% % load in headphone functions
% plotFreqs=0; %if 1, plot interpolated frequencies x level w/ calibration
% filt = load(filters);% load('sensi_86_nopanel_100Hz_8k_121030'); % disc_dec14_2011
% %filt = load('disc_dec14_2011'); %% old headphones
% %filt = load('calib_filters_proto.mat');  %load the calibration filters
% filt_L = filt.res.L.iri;
% filt_R = filt.res.R.iri;
% 
% tf_freqs = filt.res.L.ir_tf_freqs; %read in the transfer function for our frequency
% 
% tf_L = filt.res.L.ir_tf; %rel gain in dB
% tf_R = filt.res.R.ir_tf;
% 
% our_tf_L = interp1(tf_freqs,tf_L,freq_interp);
% our_tf_R = interp1(tf_freqs,tf_R,freq_interp);
% 
% amp_L = 10.^(our_tf_L/20); %convert to amplitude
% amp_R = 10.^(our_tf_R/20);
% 
% filter_clevels_L = 1./amp_L;
% filter_clevels_R = 1./amp_R;
% 
% filter_clevels_L=filter_clevels_L./max(filter_clevels_L(:));
% filter_clevels_R=filter_clevels_R./max(filter_clevels_R(:));
% 
% 
% if plotFreqs, plot(freq_interp,filter_clevels_R ,'r'); hold on, end

%% now do the conversion based on the isoloudness curves
% this is assuming that the dB is flat across the headphones to start with
[spl freq] = iso226_earmod(phon,2,0); % or iso226(60)
% putting in spl values will produce equal loudness across frequencies
% get levels for these frequencies from equal-loudness curve
spl_interp = spline(freq,spl,freq_interp);

% spl_amp=spl_interp;

spl_amp = 10.^(spl_interp/20);


spl_amp = spl_amp./ max(spl_amp); % normalize to 1

% if plotFreqs, plot(freq_interp,spl_amp ,'b'), end

% sound system calibration curve with the equal-loudness curve
levels_L=spl_amp; % CB edited spl_amp.*filter_clevels_L;
levels_R=spl_amp; %CB edited spl_amp.*filter_clevels_R;
levels_L=levels_L./max(levels_L(:)); %Not sure whether close this part or not
levels_R=levels_R./max(levels_R(:));

% if plotFreqs, hold on, plot(freq_interp,levels_R ,'g'); end
% % 
% % tones = freq_used;    %frequencies in the stimulus
% % 
% % toneamps_L=interp1(freq_interp,levels_L,tones);
% % toneamps_R=interp1(freq_interp,levels_R,tones);





end