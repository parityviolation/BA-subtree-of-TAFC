%% Pseudo-population analysis
% Training set: different stimuli

neurTAFCm_SharedVariables
load myTAFC
Animals = fieldnames(myTAFC);
filename = 'myTAFCm_that8';
savevar = true;
N = 100;
GM = cell(length(Animals),1);
GMsmooth = cell(length(Animals),1);
MLE = cell(length(Animals),2);

edges = 0:50;
bin = 500;
bounds = [-1 3]*1000;
step = 50;
stepsize = bin/step;
T = bounds(1):stepsize:bounds(2);

for a = 1:length(Animals)
    %% 
    animal = Animals{a};
    Sessions = fieldnames(myTAFC.(animal));
    
    %% Big Psychometric Function
    bigSess = [];
    bhv = [];
    myFields = {'ChoiceLeft','ChoiceCorrect','Interval'};
    for f = 1:length(myFields)
        bhv.(myFields{f}) = [];
    end
    for s = 1:length(Sessions)
        session = Sessions{s};
        for f = 1:length(myFields)
            bhv.(myFields{f}) = [bhv.(myFields{f}), myTAFC.(animal).(session).bhv.(myFields{f})];
        end
%         bigSess = [bigSess; bhv]
    end
    bhv.IntervalSet = unique(bhv.Interval(~isnan(bhv.Interval)));
    [psyc,~,beta] = psycurve(bhv,0,1);
    %%
    for s = 1:length(Sessions)
        session = Sessions{s};
        Intervals = myTAFC.(animal).(session).bhv.IntervalSet;
        cNdx = myTAFC.(animal).(session).bhv.ChoiceCorrect == 1;
        GMs = zeros(length(edges),length(T),size(myTAFC.(animal).(session).neur.Counts,3));
        
        M0 = false(length(Intervals),length(T));
        for i = Intervals
            %     M0(Intervals==i,:) = T >= 0 & T <= Intervals(Intervals==i)*3000;
            M0(Intervals==i,:) = T <= Intervals(Intervals==i)*3000;
        end
        M0 = logical(M0);
        
        for i = Intervals
            cv = exp(beta(1)+beta(2)*i); cv = cv./(1+cv); cv = cv*(1-cv);
            h = histc(myTAFC.(animal).(session).neur.Counts(cNdx,M0(Intervals==i,:),:),edges);
            temp = zeros(length(edges),length(T),size(h,3));
            temp(:,M0(Intervals==i,:),:) = h;
            GMs = GMs + temp*cv;
            clear h temp
        end
        GM{a} = cat(3,GM{a},GMs);        
        clear GMs
    end
    %% SMOOTHING LAST SESSION ONLY!!
    gm = GM{a};
    for u = 1:size(gm,3)
        for b = 1:size(gm,2)
            gm(:,b,u) = smooth(gm(:,b,u),10,'lowess')'; % 10 before, Joe uses 30
            gm(gm(:,b,u)<0,b,u) = 0;
            gm(:,b,u) = gm(:,b,u)/sum(gm(:,b,u));
        end
    end
    gm = .9*gm + .1*ones(size(gm))/length(edges);
    GMsmooth{a} = gm;
    clear gm
    
    Intervals = [.35 .65];
    M0_binNdx = false(length(Intervals),length(T));
    for i = Intervals
        M0_binNdx(Intervals==i,:) = T <= Intervals(Intervals==i)*3000;
    end
    M0_binNdx = logical(M0_binNdx);
    
    for i = Intervals
        MLE{a,Intervals==i}.choiceE.max = nan(N,length(T));
        MLE{a,Intervals==i}.choiceE.cm = nan(N,length(T));
        MLE{a,Intervals==i}.choiceE.mat = nan(length(T),length(T),N);
        MLE{a,Intervals==i}.choiceC = MLE{a,Intervals==i}.choiceE;
        
        binNdxTe = M0_binNdx(Intervals==i,:);
        display(sprintf('%2.2f',i))
        cv = exp(beta(1)+beta(2)*i); cv = cv./(1+cv); cv = cv*(1-cv);
        
        %% Sudopops - Correct Trials
        counts = [];        
        for s = 1:length(Sessions)
            bhv =  myTAFC.(animal).(Sessions{s}).bhv;
            bhv.Interval = round(bhv.Interval*100);
            iNdx = bhv.Interval == i*100;
            nanNdx = any(squeeze(any(isnan(myTAFC.(animal).(Sessions{s}).neur.Counts),2)),2)';
            cNdx = bhv.ChoiceCorrect == 1;
            temp = myTAFC.(animal).(Sessions{s}).neur.Counts(iNdx & ~nanNdx & cNdx,:,:); 
            try
                counts = cat(3,counts,temp(randsample(size(temp,1),N),:,:));
            catch
                sudoNdx = [1:size(temp,1), randsample(size(temp,1),N-size(temp,1),true)'];
                sudoNdx = sudoNdx(randperm(N));
                counts = cat(3,counts,temp(sudoNdx,:,:));
                display(['Sessions ' Sessions{s}(2:end) ' has less then N trials: ' num2str(size(temp,1))])
            end
            clear bhv indx nanNdx cNdx temp
        end
        
        for n = 1:N
            display(sprintf('%2.0f',n))
            % Smart GLM: local adjustment
            gm = GM{a}(:,binNdxTe,:) - histc(counts(n,binNdxTe,:),edges,1)*cv;
            for u = 1:size(gm,3)
                for b = 1:size(gm,2)
                    gm(:,b,u) = smooth(gm(:,b,u),10,'lowess')'; % 10 before, Joe uses 30
                    gm(gm(:,b,u)<0,b,u) = 0;
                    gm(:,b,u) = gm(:,b,u)/sum(gm(:,b,u));
                end
            end
            gm = .9*gm + .1*ones(size(gm))/length(edges);
            [~,Yte] = thatp(counts(n,binNdxTe,:),gm);
            MLE{a,Intervals==i}.choiceC.max(n,binNdxTe) = Yte.max;
            MLE{a,Intervals==i}.choiceC.cm(n,binNdxTe) = Yte.cm;
            MLE{a,Intervals==i}.choiceC.mat(binNdxTe,binNdxTe,n) = Yte.mat;
            clear gm Yte
        end
        clear counts
        
        %% Sudopops - Incorrect trials
        counts = [];        
        for s = 1:length(Sessions)
            bhv =  myTAFC.(animal).(Sessions{s}).bhv;
            bhv.Interval = round(bhv.Interval*100);
            iNdx = bhv.Interval == i*100;
            nanNdx = any(squeeze(any(isnan(myTAFC.(animal).(Sessions{s}).neur.Counts),2)),2)';
            cNdx = bhv.ChoiceCorrect == 0;
            temp = myTAFC.(animal).(Sessions{s}).neur.Counts(iNdx & ~nanNdx & cNdx,:,:); 
            try
                counts = cat(3,counts,temp(randsample(size(temp,1),N),:,:));
            catch
                sudoNdx = [1:size(temp,1), randsample(size(temp,1),N-size(temp,1),true)'];
                sudoNdx = sudoNdx(randperm(N));
                counts = cat(3,counts,temp(sudoNdx,:,:));
                display(['Sessions ' Sessions{s}(2:end) ' has less then N trials: ' num2str(size(temp,1))])
            end
            clear bhv indx nanNdx cNdx temp
        end
        for n = 1:N
            display(sprintf('%2.0f',n))
            gm = GMsmooth{a}(:,binNdxTe,:);
            [~,Yte] = thatp(counts(n,binNdxTe,:),GMsmooth{a}(:,binNdxTe,:));
            
            MLE{a,Intervals==i}.choiceE.max(n,binNdxTe) = Yte.max;
            MLE{a,Intervals==i}.choiceE.cm(n,binNdxTe) = Yte.cm;
            MLE{a,Intervals==i}.choiceE.mat(binNdxTe,binNdxTe,n) = Yte.mat;
            
            clear gm
        end
        clear counts
        tnow = toc;
        display([sprintf('%4.1f',tnow) 's'])
    end
    
    if savevar; save(filename,'MLE','-v7.3'); end
end