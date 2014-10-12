function [data,proj_comb,t_pvaf,s_vd,s_vp,s_vr,t]=pvaracc(ALLEEG,comps,times,sets)

%.........................................................................
%Start... Handle inputs...
%.........................................................................
%Create time vector "t"...
t=1:ALLEEG(1).pnts;
t=t*(1000/ALLEEG(1).srate);
t=t+(1000*ALLEEG(1).xmin);

%Create time indices "pnts" from inout "times"
[~,pnts(1)]=findnear(t,times(1));
[~,pnts(2)]=findnear(t,times(2));

%.........................................................................
%End... Handle inputs...
%.........................................................................



%.........................................................................
%Start... Create data vectors "data" & "proj"...
%.........................................................................
%Create "data", "icaact" and "proj" arrays...

switch length(sets)
    case 1
        data = mean(ALLEEG(sets).data(:,:,:),3);
        icaact = mean(ALLEEG(sets).icaact(comps,:,:),3);
        proj_comb = ALLEEG(sets).icawinv(:,comps,:)*icaact;
        for i=1:length(comps);
            icaact = mean(ALLEEG(sets).icaact(comps(i),:,:),3);
            proj_uniq(:,:,i)=ALLEEG(sets).icawinv(:,comps(i))*icaact;
        end
    case 2
        data = mean(ALLEEG(sets(1)).data(:,:,:),3)-mean(ALLEEG(sets(2)).data(:,:,:),3);
        icaact = mean(ALLEEG(sets(1)).icaact(comps,:,:),3)-mean(ALLEEG(sets(2)).icaact(comps,:,:),3);
        proj_comb = ALLEEG(sets(1)).icawinv(:,comps)*icaact;
        length(comps)
        for i=1:length(comps);
            icaact = mean(ALLEEG(sets(1)).icaact(comps(i),:,:),3)-mean(ALLEEG(sets(2)).icaact(comps(i),:,:),3);
            proj_uniq(:,:,i)=ALLEEG(sets(1)).icawinv(:,comps(i))*icaact;
        end
end

%Reduce rows of "t", "Data" and "proj" to indices found in "pnts"...
t=t(pnts(1):pnts(2));
data=data(:,pnts(1):pnts(2));
proj_comb=proj_comb(:,pnts(1):pnts(2));
proj_uniq=proj_uniq(:,pnts(1):pnts(2),:);
%.........................................................................
%End... Create data vectors "data" & "proj"...
%.........................................................................


%.........................................................................
%Start... Plot outcome...
%.........................................................................
%Plot all "data" (black), "proj" (grey) and the residual (red)...
figure;plot(t,data','k');
hold on;
plot(t,proj_comb','Color',[.7 .7 .7]);
data_res=data-proj_comb;
plot(t,data_res','r')
hold off
set(gca,'XLim',[times(1),times(2)])
title('Channel overlay of "data" (black), "proj" (grey) and the residual (red)');
xlabel('Time');
ylabel('Uv');

%Calculate tempral variance...
t_vr = var((data-proj_comb),[],2);
t_vd = var(data,[],2);
t_pvaf = 100-(100*(t_vr./t_vd));

%Calculate spatial variance...
s_vd = var(data,[],1);
s_vp = var(proj_comb,[],1);
s_vr = var((data-proj_comb),[],1);
%if length(comps)>1;
    for i=1:length(comps);
        s_vp_u(1,:,i)=var(proj_uniq(:,:,i),[],1);
    end
%end
figcol=[0,0,0;1,0,0;0,1,0;0,0,1;.3,.3,.3;1,.3,.3;.3,1,.3;.3,.3,1;.6,.6,.6;1,.6,.6;.6,1,.6;.6,.6,1];
%figcol=[1,.3,.3;.3,1,.3;.3,.3,1;1,.6,.6;.6,1,.6;.6,.6,1];
%Plot s_vd (black), s_vp (grey) and s_vr (red)...
figure;
plot(t,s_vr,'r','LineWidth',3);
hold on
plot(t,s_vp,'Color',[.7 .7 .7],'LineWidth',3);
plot(t,s_vd,'k','LineWidth',3);
for i=1:length(comps);
    plot(t,s_vp_u(1,:,i),'Color',figcol(i,:));
end
hold off
set(gca,'XLim',[times(1),times(2)])
title('Spatial variance of "data" (black), "proj" (grey) and the residual (red)');
xlabel('Time');
ylabel('Variance');

%Calculate the spatial percentage of variance accounted for...
%s_pvaf=(s_vd-s_vr)./s_vd;
%Plot s_pvaf...
%figure;plot(t,(s_pvaf*100),'b');
%set(gca,'XLim',[times(1),times(2)])
%title('Spatial percentage of variance accounted for ((s_vd-s_vr)./s_vd)');
%xlabel('Time');
%ylabel('percent');
%Plot s_vd-s_vr...
%figure;plot(t,(s_vd-s_vr),'b');
%set(gca,'XLim',[times(1),times(2)])
%title('Spatial variance accounted for (s_vd-s_vr)');
%xlabel('Time');
%ylabel('variance');
%.........................................................................
%End... Plot outcome...
%.........................................................................
