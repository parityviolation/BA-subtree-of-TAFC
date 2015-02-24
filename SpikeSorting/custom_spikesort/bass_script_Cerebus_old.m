% load gils data
fn='g01717022012001_tet20_Clean';


fid=fopen(fn);

% Nr Events
fseek(fid,0,'eof');
fidlength = ftell(fid);
fclose(fid);
tic
fid=fopen(fn);
TetrodeData=fread(fid,fidlength,'float');


nrEvents=fidlength/193/4;
datafidlength=fidlength/4;

%%%Extract event time points
EventTimes=TetrodeData((193:193:end));
%% build spikes struct
clear spikes;
nchn = 4;
nsamples = 48;
Fs = 30000;

first = 1;
last = length(TetrodeData);

nevents=int32((last-first)/193);
temp =TetrodeData(first:last);
temp(193:193:end) = [];
temp = single(temp);
temp2 = reshape(temp,nchn,nsamples,nevents);

spikes.waveforms=permute(temp2,[3,2,1]);

clear temp temp2

% NOTE BELOW IS WRONG ONLY FOR TEMP USE
spikes.spiketimes=single(TetrodeData(193:193:(193*nevents))');% THIS SHOULD BE TRIAL TIME
ss_removeBelowPercentile(spikes,90);

spikes = ss_default_params_custom(Fs,spikes);
spikes = ss_instead_of_detect(spikes);


clear TetrodeData
%% run algorithm

spikes = ss_align(spikes);
spikes = ss_kmeans(spikes);
spikes = ss_energy(spikes);
spikes = ss_aggregate(spikes);

% main tool
splitmerge_tool(spikes)

% stand alone outlier tool
outlier_tool(spikes)

%
% Note: In the code below, "clus", "clus1", "clus2", and "clus_list" are dummy
% variables.  The user should fill in these vlaues with cluster IDs found 
% in the SPIKES object after running the algorithm above.
%

% plots for single clusters
plot_waveforms( spikes, clus );
plot_stability( spikes, clus);
plot_residuals( spikes,clus);
plot_isi( spikes, clus );
plot_detection_criterion( spikes, clus );

% comparison plots
plot_fld( spikes,clus1,clus2);
plot_xcorr( spikes, clus1, clus2 );

% whole data plots
plot_features(spikes );
plot_aggtree(spikes);
show_clusters(spikes, [clus_list]);
compare_clusters(spikes, [clus_list]);

% outlier manipulation (see M-files for description on how to use)
spikes = remove_outliers( spikes, which ); 
spikes = reintegrate_outliers( spikes, indices, mini );

% quality metric functions
%
% Note: There are versions of these functions in the quality_measures 
% directory that have an interface that does not depend on the SPIKES
% structure.  These are for use by people who only want to use the quality
% metrics but do not want to use the rest of the package for sorting. 
% These functions have the same names as below but without the "ss_" prefix.
%
FN1 = ss_censored( spikes, clus1 );
FP1 = ss_rpv_contamination( spikes, clus1  );
FN2 = ss_undetected(spikes,clus1);
confusion_matrix = ss_gaussian_overlap( spikes, clus1, clus2 ); % call for every pair of clusters


toc

