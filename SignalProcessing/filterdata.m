function data = filterdata(data,dt,cutoff,type)
% function prodata = filterdata(data,dt,cutoff,type)
% Function filters data 
% INPUT:  
%     data-    matrice of data.
%     dt -    sampling (used to turn cutoff into appropriate frequency)
%     cutoff - "cut off frequency" (Hz)
%     type - 0 = low-pass, 1 = high-pass
%     
% OUTPUT:
%     prodata
%
% BA103006

if type ==0 
    stype = 'low';
elseif type ==1
    stype = 'high';
else
    error('Unknown fiter type')
end

if iscolumn(data)
    data = data';
end
    
% tic
[B,A] = butter(2,2*cutoff*dt,stype);
% toc
ntrials = size(data,1);
for itrial = 1:ntrials
    data(itrial,:) =   filtfilt(B,A,double(data(itrial,:)));
end