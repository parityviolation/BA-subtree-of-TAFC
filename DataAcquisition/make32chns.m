function make32chns
% Defines channels in the global object AIOBJ using the cell array
% Parameters.
%
%
% BA to add channels above 24 
p = load('F:\VCData\Settings\DaqSetup\Cindy_ExtraChans');
parameters = p.Parameters;

global AIOBJ
RigDef = RigDefs;

for i = 1:size(parameters,2) % just take the
    if strcmp(parameters{i,2},'yes')
        hwCh = str2num(parameters{i,4});
        if 0
        %         if isstr(parameters{i,1})
        %             index = str2num(parameters{i,1});
        %         else
        %             index = parameters{i,1};
        %         end
        else
            ch = AIOBJ.Channel;
            index = length(ch)+1;
        end
       
        ch(index) = addchannel(AIOBJ,hwCh,index,parameters{i,3});
        set(ch(index),'InputRange',str2num(parameters{i,5}));
        set(ch(index),'SensorRange',str2num(parameters{i,6}));
        set(ch(index),'Units',parameters{i,8});
    end
    
end