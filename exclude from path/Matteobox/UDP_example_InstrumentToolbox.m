% This is an example of how to set up a UDP communication between 2
% computers: a remote host, where the UDP signal is originating, and a
% local host, where the UDP signal is received.
% 
% This is asynchronous event-based communication, meaning that when the UDP
% arrives you can execute a call-back function without stalling Matlab
% during the execution.
% 
% In this example I am considering the case of a UDP signal coming from ZPEP/MPEP.
% The call-back function executed when the UDP arrives simply prompts the 
% various info sent out by zpep/mpep.
%
% NOTE: If you are not sure which port is used by the remote host use 'CurrPorts'
% softwear (in zserver Installers) to minitor the ports' activity.
%
% AB March 2011
 

%% Create the UDP object

z = udp; 
z.name = 'Whatever name';
z.RemotePort = 1103;                     % port used to send out UDP
z.LocalPort  = 1001;                     % port where UDP is received
z.RemoteHost = '144.82.xx.xxx';          % IP of computer sending out UDP
z.LocalHost  = '144.82.xx.xxx';          % IP of computer receiving UDP 
z.DatagramReceivedFcn  = {'mycallback'}; % call-back fcn when signal arrives
z.InputBufferSize = 1e6;                 % max bites that can be received
fopen(z);                                % open UDP channel

% If needed, close UDP channel and delete the object
fclose(z); delete(z); 


%% Call-back

function mycallback(obj, event)
 % MYCALLBACK Prompts event information for the specified zpep/mpep event.

% Two lines below work for any UDP event 
fprintf('UDP from %s from port %d to local port %d\n',obj.RemoteHost,obj.RemotePort,obj.LocalPort)
[A,count,msg,datagramaddress,datagramport] =  fread(obj);

% Code below works for zpep/mpep UDP events only 
[header, animal, series, expt, repNo, stimNo, dur] = strread(char(A),'%s %s %s %s %s %s %s',...
    'delimiter',' ');

header = header{1};  animal = animal{1};
series = series{1};  expt   = expt{1};
if ~isempty(repNo),  repNo  = repNo{1};  else repNo  = ' '; end
if ~isempty(stimNo), stimNo = stimNo{1}; else stimNo = ' '; end
if ~isempty(dur),    dur    = dur{1};    else dur    = ' '; end

fprintf('%s %s %s %s %s %s %s\n',header, animal, series, expt, repNo, stimNo, dur);

