function [data_sv,proj_svr_uniq,proj_spvaf_uniq,proj_svc_uniq,proj_spc_uniq,pvaf_uniq_out]=icID_pvaf(ALLEEG,sets,times,comps,chans,varargin)


%.........................................................................
%Start... Handle inputs...
%.........................................................................
%Create time vector "t"...
t=1:ALLEEG(1).pnts;
t=t*(1000/ALLEEG(1).srate);
t=t+(1000*ALLEEG(1).xmin);
%Create time indices "pnts" from input "times"
[~,pnts(1)]=findnear(t,times(1));
[~,pnts(2)]=findnear(t,times(2));


%Handle varargin...
if ~isempty( varargin ), g=struct(varargin{:});
else g= []; end;

try, g.critval;		    catch, g.critval	= .95; 	end;
try, g.method;		    catch, g.method     = 2; 	end;
try, g.nep; 		    catch, g.nep        = []; 	end;
try, g.btsblpnts;       catch, g.btsblpnts  = [];   end;
try, g.btsscrit;        catch, g.btsscrit   = [];   end;


ERPpnts=[pnts(1):pnts(2)];

if isempty(comps);
    comps=1:size(ALLEEG(sets(1)).icaweights,1);
end

%Create channel indices "chinds" from input "chans"...
chaninds=chans;
%if isempty(chans);
%    chans={ALLEEG(sets(1)).chanlocs.labels};
%    chaninds=[1:ALLEEG(sets(1)).nbchan];
%else
%    j=0;
%    for i=1:length(chans);
%        if ~isempty(strmatch(chans{i},{ALLEEG(sets(1)).chanlocs.labels},'exact'));
%            j=j+1;
%            chaninds(j)=strmatch(chans{i},{ALLEEG(sets(1)).chanlocs.labels},'exact');
%        end
%    end
%end

%.........................................................................
%End... Handle inputs...
%.........................................................................
 
 
%.........................................................................
%Start... Bootstrap determination of ERP time indices "ERPpnts" ...
%.........................................................................
if ~isempty(g.nep);
    for srgi=1:1000;
        if length(sets)==1;
            csrgind = ceil(rand(1,ALLEEG(sets(1)).trials)*ALLEEG(sets(1)).trials);
            bts(1,:,srgi)=var(mean(ALLEEG(sets(1)).data(:,:,csrgind(1:g.nep)),3),[],1);
        elseif length(sets)==2;
            csrgind1 = ceil(rand(1,ALLEEG(sets(1)).trials)*ALLEEG(sets(1)).trials);
            dat1=mean(ALLEEG(sets(1)).data(:,:,csrgind1(1:g.nep)),3);
            csrgind2 = ceil(rand(1,ALLEEG(sets(2)).trials)*ALLEEG(sets(2)).trials);
            dat2=mean(ALLEEG(sets(2)).data(:,:,csrgind2(1:g.nep)),3);
            bts(1,:,srgi)=var(dat2-dat1,[],1);
        end
    end
    
    m=mean(bts,3);
    s=std(bts,0,3);
    figure;plot(t,squeeze(m));
    hold on;
    uprci=m+(s*g.btsscrit);
    lwrci=m-(s*g.btsscrit);
    crit=mean(squeeze(m(g.btsblpnts(1):g.btsblpnts(2))));
    j=0;
    for i=1:length(lwrci);
        if lwrci(i)>crit||uprci(i)<crit;
            j=j+1;
            ERPpnts(j)=i;
        end
    end
    
    ERPpnts=ERPpnts(find(ERPpnts>pnts(1)));    
    ERPpnts=ERPpnts(find(ERPpnts<pnts(2)));

    plot(t,squeeze(uprci),'Color',[.7 .7 .7])
    plot(t,squeeze(lwrci),'Color',[.7 .7 .7])
    plot(t,ones(1,ALLEEG(sets(1)).pnts)*crit,'Color',[0 0 0]);
    x=zeros(1,ALLEEG(sets(1)).pnts);
    x(ERPpnts)=1;
    plot(t,x,'Color',[1,0,0]);
else
    ERPpnts=[pnts(1):pnts(2)];
end
%.........................................................................
%End... Bootstrap determination of ERP time indices "ERPpnts" ...
%.........................................................................


%.........................................................................
%Start... Create data vectors "data" & "proj"...
%.........................................................................
if length(sets)==1;
    data = mean(ALLEEG(sets).data(:,:,:),3);
    for ici=1:length(comps);
        proj_uniq(:,:,ici)=ALLEEG(sets).icawinv(:,comps(ici))* ...
                        mean(ALLEEG(sets).icaact(comps(ici),:,:),3);
    end
elseif length(sets)==2;
    data=mean(ALLEEG(sets(1)).data(:,:,:),3)-mean(ALLEEG(sets(2)).data(:,:,:),3);
    for ici=1:length(comps);
        proj_uniq(:,:,ici)=ALLEEG(sets(1)).icawinv(:,comps(ici),:)* ...
                        mean(ALLEEG(sets(1)).icaact(comps(ici),:,:),3)- ...
                        ALLEEG(sets(2)).icawinv(:,comps(ici),:)* ...
                        mean(ALLEEG(sets(2)).icaact(comps(ici),:,:),3);
    end
end
%.........................................................................
%End... Create data vectors "data" & "proj"...
%.........................................................................


%.........................................................................
%Start... IC contribution measures...
%.........................................................................
%Spatial variance measures...
data_sv=var(data(:,ERPpnts),[],1);
proj_sv_uniq=var(proj_uniq(:,ERPpnts,:),[],1);
for ici=1:length(comps);
    proj_svr_uniq(1,:,ici)=var((data(:,ERPpnts)-proj_uniq(:,ERPpnts,ici)),[],1);
    proj_spvaf_uniq(1,:,ici)=mean(data_sv-proj_svr_uniq(1,:,ici),2)./mean(data_sv,2);
    proj_svc_uniq(1,:,ici)=abs(data_sv-proj_svr_uniq(1,:,ici));
    proj_spc_uniq(1,1,ici)=mean(proj_svc_uniq(:,:,ici),2)/mean(data_sv,2);
    pvaf_uniq_out(:,ici)=squeeze(proj_svc_uniq(:,:,ici))./squeeze(data_sv);
end

%Tempral variance accounted for... INCLUDE CUMULATIVE MEASURES HERE...
data_tv=var(data(chaninds,ERPpnts),[],2);
proj_tv_iniq=var(proj_uniq(chaninds,ERPpnts,:),[],2);
for ici=1:length(comps);
    proj_tvr_uniq(:,1,ici)=var((data(chaninds,ERPpnts)-proj_uniq(chaninds,ERPpnts,ici)),[],2);
    proj_tpvaf_uniq(:,1,ici)=mean(data_tv-proj_tvr_uniq(:,1,ici),1)./mean(data_tv,1);
    proj_tvc_uniq(:,1,ici)=abs(data_tv-proj_tvr_uniq(:,1,ici));
    proj_tpc_uniq(1,1,ici)=mean(proj_tvc_uniq(:,:,ici),1)/mean(data_tv,1);
end
%.........................................................................
%End... IC contribution measures ...
%.........................................................................


%.........................................................................
%IC selection...
%.........................................................................
%Select measure to use for criteria... THIS NEEDS AN INPUT VARIABLE
sort_var=squeeze(proj_tpc_uniq);

[sort_var_desc,sort_var_desc_i]=sort(sort_var,1,'descend');
figure;plot(sort_var_desc,'k','LineWidth',3);
title('Sorted measure for each IC projection');

%calculate cumulative projection measures...
for ici=1:length(comps);
    if length(sets)==1;
        proj_cum(:,:,ici)=ALLEEG(sets).icawinv(:,sort_var_desc_i(1:ici))* ...
            mean(ALLEEG(sets).icaact(sort_var_desc_i(1:ici),:,:),3);
    elseif length(sets)==2;
        proj_cum(:,:,ici)=ALLEEG(sets(1)).icawinv(:,sort_var_desc_i(1:ici),:)* ...
            mean(ALLEEG(sets(1)).icaact(sort_var_desc_i(1:ici),:,:),3)- ...
            ALLEEG(sets(2)).icawinv(:,sort_var_desc_i(1:ici),:)* ...
            mean(ALLEEG(sets(2)).icaact(sort_var_desc_i(1:ici),:,:),3);
    end
    proj_tvr_cum(:,1,ici)=var((data(chaninds,ERPpnts)-proj_cum(chaninds,ERPpnts,ici)),[],2);
    proj_tpvaf_cum(:,1,ici)=mean(data_tv-proj_tvr_cum(:,1,ici),1)./mean(data_tv,1);
    proj_tvc_cum(:,1,ici)=abs(data_tv-proj_tvr_cum(:,1,ici));
    proj_tpc_cum(1,1,ici)=mean(proj_tvc_cum(:,:,ici),1)/mean(data_tv,1);
end
hold on;plot(squeeze(proj_tpvaf_cum),'r','LineWidth',3);
grid minor

%sort_var
%g.critval

icID=[];
if g.method==1;
    icID=find(sort_var>g.critval);
elseif g.method==2;
    for i=1:length(comps);
        if proj_tpvaf_cum(i)>g.critval&&isempty(icID);
            icID=sort_var_desc_i(1:i);
            break
        end
    end
end

%.........................................................................
%End of IC selection...
%.........................................................................


%.........................................................................
%Plot outcome...
%.........................................................................
if length(sets)==1;
    figdata=ALLEEG(sets(1));
else
    figdata=[ALLEEG(sets(1)),ALLEEG(sets(2))];
end
figure; pop_envtopo(figdata, [ALLEEG(sets(1)).xmin*1000 ALLEEG(sets(1)).xmax*1000] , ...
    'compnums',[icID], ...
    'title', 'sigerpic', ....
    'electrodes','off');

[~,~,~,~,~,~,~]=pvaracc(ALLEEG,icID,[ALLEEG(sets(1)).xmin*1000,ALLEEG(sets(1)).xmax*1000],sets);
%.........................................................................
%End of Plotting outcome...
%.........................................................................
