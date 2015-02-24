% inhibitory and excitatory neurons
% with synaptic Conductance with time constant
% with random connectivity


% PROB:
% no refratory period

% BA092308
% Excitatory         Inhibitory
Ne = 1000;         Ni = 200;
total = Ne+Ni;

Vte=-45e-3;     Vti=-45e-3;	% Threshold
Vre=-44e-3;     Vri=-50e-3; % Resting Potential
ce = -55e-3;    ci = -55e-3; % reset potential
Re = 100e6;     Ri = 20e6; % Ohms
Ce = 0.1e-9;    Ci = 0.1e-9; %Farads
Vie = Vre;   Vii = Vri; % mV % initial potential

vpeake = 35e-3; vpeaki = 35e-3; % spike peak amplitude

refTime = [ones(1,Ne)*1/120 ones(1,Ni)*1/300].*1e3; % absolute refractory period
INoise_std = 10e-12; % std of noise in Amps

% synapses
Sg=zeros(total,total);
% % Sg(:,1) = 5; Sg(:,101) = 20; % enter as nS
% add random connectivity
% P-> I connections
Cpi = 0.1; Spi = 1; 
%   POST  PRE synaptic
Sg(Ne+1:end,1:Ne) = (rand(Ni,Ne)> (1-Cpi))*Spi; % 
% P-> P connections
Cpp = 0.01; Spp =0; 
%   POST  PRE synaptic
Sg(1:Ne,1:Ne) = (rand(Ne,Ne)> (1-Cpi))*Spp; % 
% I-> P connections
Cip = 0.3; Sip =20; 
Sg(1:Ne,Ne+1:end) = (rand(Ne,Ni)> (1-Cip))*Sip; % 
% I-> I connections
Cii = .3; Sii = Sip; 
Sg(Ne+1:end,Ne+1:end) = (rand(Ni,Ni)> (1-Cii))*Sii; % 
% spy(Sg)
Sg = Sg.*~eye(size(Sg));%%REMOVE autapes if that matters

Sg = Sg*1e-9; % convert to S
stdecay = 8; % decay of synapses ms
Stau = ones(size(Sg)).*stdecay; % decay of all synapses ms
SEVr = 0; SIVr = -75e-3; % reversal potential for Ex and In synapses
S_Vr = repmat([SEVr*ones(1,Ne) SIVr*ones(1,Ni)],total,1); % Vr for each synapse (all synapses from a Presynatic cell are in the same column and have the same reversal potential)


% numExi=Nei;	numExr=Ner;	numIn=Ni;			numLTS=Nlts;	% num cells to record


V=[Vie*ones(Ne,1); Vii*ones(Ni,1);];			% initial v
Vt=[Vte*ones(Ne,1); Vti*ones(Ni,1)];
Vr=[Vre*ones(Ne,1); Vri*ones(Ni,1)];
c=[ce*ones(Ne,1); ci*ones(Ni,1)];
R=[Re*ones(Ne,1); Ri*ones(Ni,1)];
C=[Ce*ones(Ne,1); Ci*ones(Ni,1)];
vpeak=[vpeake*ones(Ne,1) ;  vpeaki*ones(Ni,1)];

% initialize
cg = zeros(size(Sg)); % current conductance of each synapse

% Setup simulation time
T=500; tau=.25;			% time span and step (ms)
n = round(T/tau);

T1=T/10;

% Externally injected current for each time step
I2 = [zeros(n,Ne) zeros(n,Ni)];
I2 = [ones(n,Ne)*2e-11 ones(n,Ni)*0e-11];
I2(1:end/5:end,1:Ne) = repmat([120:-20:21]',1,Ne)*1e-10;

%% run simulation
% preallocate intracellular records
vsave = zeros(n,total);
Issave = vsave;
firedsave = zeros(n,total,'int16'); fired = [];
lastfiredtime = ones(1,total).*1e3*tau; % for Refractory period intialized so that cells can spike immediately

bVC = 1; % save VClamp data
if bVC; saveIex = vsave; saveIin = vsave; end;
for i=1:n
    t = i*tau;
    if (t>T1/2) & (t<T*2/10) % stimulating current
        %         I=-500e-12;
        I=0;
    else
        I=0;
    end;

    if fired % debugging
        cg;
    end
    % synpases
    cg(:,fired) = cg(:,fired) + Sg(:,fired); % compute CURRENT synaptic conducance by adding synaptic conductance from fired cells
    temp = cg.*(S_Vr-repmat(V,1,total));
    if bVC % record Ex and In synaptic currents  (not necessary for function of model)
        saveIin(i,:) = sum(temp(:,Ne+1:end),2)';
        saveIex(i,:) = sum(temp(:,1:Ne),2)';
    end
    Is=sum(temp,2);				% compute synaptic current from spiked neurons
    cg =  cg.*exp(-tau./Stau); % decay synaptic conductance (exp could be computed outside of loop)

    % Refactory period add conductance
    INoise = randn(total,1)*0*INoise_std;
    I=I+Is+INoise+I2(i,:)';


    reset = fired;
    V = V + tau*(Vr + R.*I - V)./(R.*C*1e3); % euler onestep
    V(reset) = c(reset);% reset

    fired=find(V>=Vt & V<vpeak & (abs(lastfiredtime-i).*tau > refTime)'); % cross threshold and pass refractory period
    lastfiredtime(fired) = i;
    
    vsave(i,:) = V';   
    vsave(i,fired) = vpeak(fired);  % saved Vm has spikes but model doesn't 
%     Issave(i,:) = Is';
    Issave(i,:) = I';
    firedsave(i,fired) =1; 
    
    % catch occational run away (FIND OUT REASON)
%     temp = V>100;
%     V(temp) = Vr(temp);
end;


% rasterplot
figure(1000);clf;
set(1000,'Position',[   1016         707         560         420]);
data = firedsave(:,1:Ne)';
plot([1:size(data,2)]*tau,repmat([1:size(data,1)]',1,size(data,2)).*double(data),'.b');hold all
data = firedsave(:,Ne+1:end)';
plot([1:size(data,2)]*tau,repmat([Ne+1:Ne+size(data,1)]',1,size(data,2)).*double(data),'.r');
% ylim([0.5 size(data,1)])
ylim([0.5 size(firedsave',1)])
xlabel('Time (ms)')
%%
PLOTCELL = [200];
figure(999);clf;
set(999,'Position',[  1024         204         560         420]);
subplot(2,1,1);plot([1:n]*tau,vsave(:,PLOTCELL)); % plot Vm
% subplot(2,1,2);plot([1:n]*tau,Issave(:,PLOTCELL)); % plot synaptic currents
subplot(2,1,2);plot([1:n]*tau,saveIin(:,PLOTCELL),'-b'); hold on;% plot synaptic currents
plot([1:n]*tau,saveIex(:,PLOTCELL),'-r'); % plot synaptic currents

% figure(1000);clf;
% set(1000,'Position',[   1016         707         560         420]);
% data = firedsave';
% plot([1:size(data,2)]*tau,repmat([1:size(data,1)]',1,size(data,2)).*double(data),'.b');hold all
% ylim([0.5 size(firedsave',1)])
% xlabel('Time (ms)')
% 
% 
