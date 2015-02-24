load('E:\Bass\ephys\Sert_179\012414\Matlab\datafile003_ns6_5.mat')
load('E:\Bass\ephys\filt\datafile003_DAQchn5filt500_5000_60_0HPsubsample1')
figure ; 
N = 100000;
plot([1:N]*d.dt,d.Data(1:N))
hold all; plot([1:N]*d.dt,filterdata(1:N))