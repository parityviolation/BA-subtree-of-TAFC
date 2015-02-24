% Matteobox Toolbox.
% Version of 22-February-2002
% amended 28 November 2003
% amended 30 November 2004
%
% Matteo Carandini's utilities toolbox for Matlab
%
% Started in 1995
%
% GRAPHICS
% scalebar                - places a colorbar in a designated axis
% gridplot                - a smarter version of subplot
% mergefigs               - merges two or more figures
% alphabet                - useful for labeling axes
% circle                  - draws a circle
% errstar                 - plots a series of points with error bars in both x and y
% fillplot                - fills the area between two plots
% supertitle              - makes a big title over all subplots
% moveax                  - moves a list of axes by a given displacement
% matchy                  - fixes the y scale of a list of axes
% changeunits             - expresses axes dims in different units
% disptune                - displays experimental data and a tuning curve
% islogspaced	          - tries to see if a vector is more linearly spaced or log spaced...
% lognums	              - useful numbers for logplots
% sidetitle               - places a title on the right side of an axes object
% PlotDisplaced           - PlotDisplaced plots traces vertically displaced
% scaleax                 - scales a list of axes by a given factor
% enhance                 - Enhances or compresses a colormap wrt the middle value
% errstartcb              - ERRSTAR plots a series of points with errors in x and y
%
% TWO DIMENSIONAL HISTOGRAMS
% hist2			          - 2-dimensional histogram
% 
% VISUAL STIMULI
% plaidimage              - draws a plaid or a grating, useful for talks, papers, posters...
%
% TO FIND SPIKES AND WORK WITH THEM
% findspikes              - finds the spike times in membrane potential traces
% spikehisto              - computes cycle histograms of spikes
% ftspikes                - Fourier Transform of full/sparse data at a given frequency
% freq                    - frequencies corresponding to the elements of an fft
% ft                      - Fourier Transform at a given frequency, obtained with dot product
%
% FOR PSYCHOPHYSICS
% psycho 	              - the erf function with two parameters
% rvc 	      	          - psychophysical contrast response function R = k c^(m+n)/[sigma^m + c^m]
% tvc   		          - threshold vs. contrast function based on rvc
%
% FITTING FUNCTIUONS
% fitit                   - least squares fitting of a model (based on 'fmins')
% lsqfit                  - least squares fitting of a model (using 'lsqcurvefit')
% fitline                 - fits a line to the data
% fminfit                 - fminfit minimize the distance between model and data using fmincon
% runmodel                - runmodel implement a model such that it can be fitted with lsqcurvefit
%	
% TO FIT DATA
% generictune             - sum of two gaussians that meet at the peak, eg to fit frequency tuning
% fitgeneric              - fits generictune to the data
% oritune                 - sum of two gaussians living on a circle, for orientation tuning
% fitori                  - fit orientation tuning data with oritune curve
% hyper_ratio             - hyperbolic ratio function, eg to fit contrast responses
% fit_hyper_ratio         - fits hyper_ratio to the data
% expfunc                 - exponential decay function
% gaussian                - a gaussian
%
% STATISTICS
% circCorr                - circular correlation coefficient based on Fisher & Lee Biometrika (1983).
% cxcorr                  - Circular correlation coefficient based on Fisher & Lee Biometrika (1983).
% circstats               - circular statistics (circular variance, preferred angle)
% CircStats360            - CircStats360 returns basic circular statistics for the 0-360 range
% myxcov                  - Matteo's cross-covariance, with the right weights...
% nansem                  - standard error of the mean that ignores NaNs
% pcorr                   - Partial correlation
% rowsem                  - standard error of the mean across rows only
% rowstd                  - takes std across rows only
% sem                     - Standard error of the mean.
% totregress              - totregress total least squares linear regression on 1-dimensional data
%
% MakeSeparable           - MakeSeparable finds the best separable approximation to a matrix
% SeparateN               - SeparateN takes a N-d matrix and separates it into N vectors
% separate                - approximate with a separable matrix
%
% FOR CROSS-PLATFORM ISSUES
% grep                    - finds the files that contain a certain string
% mac2pc                  - fixes the end-of-line problem when going from the Mac to the PC
%
% MISCELLANEOUS
% myetime                 - elapsed time in seconds, ignoring days, months and years
% cm2deg                  - converts centimeters into degrees
% deg2cm                  - converts degrees into centimeters
% degdiff 		          - difference in degrees between two angles
% diffangle               - phase difference between two complex numbers or vectors
% findmax		          - finds the position of the maximum in a vector
% changeunits             - expresses axes dims in different units
% vecdeal                 - deals a vector to a comma-separated list of variable names
% RaisedCosWin            - RaisedCosWin a raised cosine window useful for filtering
% phase                   - a smart measure of complex number phase
% robustassgn             - robust subscript assignment (NaNs for subscripts out of range)
% robustlineerror         - is used by fitline to compute robust fits
% rowmean                 - computes the mean across rows only
% GaussNoiseRate          - GaussNoiseRate firing rate model based on potential and gaussian noise
% TemplateSlideError      - TemplateSlideError slides a template over a matrix and computes norm error
% TileLag                 - TileLag builds a matrix from components that are increasingly lagged
%
% OBSOLETE
% MakeBestSeparableModel  - Uses SVD to obtain the best separable model of MatrixIn. Use MAKESEPARABLE