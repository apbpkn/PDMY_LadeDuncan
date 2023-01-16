clear all
clc
close all
% Sign Convension: Experiment, compression strain and stress positive; Simulation,Compressioin Negative

% Treatment======================
load strain.out
load stress.out
load press.out
stress(:,2:4)=-stress(:,2:4);
strain(:,2:4)=-strain(:,2:4);

cycle=(strain(1:end-1,1)-20000)/2;
cycle_new=0.0001:0.0001:cycle(end);
Experiment=load('eo_0_585_po_100_csr_0_2.txt');
Pp=Experiment(:,4)+Experiment(:,6)/3.0;
Cp=(stress(:,2)+stress(:,3)+stress(:,4))/3;
% Treatment======================

figure
plot((stress(:,2)+stress(:,3)+stress(:,4))/3,(stress(:,4)-stress(:,2)),'k','linewidth',2.0);
hold on
plot(Pp,Experiment(:,6),'b','linewidth',2.0);
set(gca,'fontsize',20,'FontName','Times New Roman'); 
hold on
xlabel('Confinement (kPa)')
ylabel('Deviator stress (kPa)')
legend('Computed','Experimental','location','Northeast')
legend boxoff
set(gca, 'ytick',[-50:25:50]);


figure
plot(strain(:,4)*100,(stress(:,4)-stress(:,2)),'k','linewidth',2.0);
hold on
plot(Experiment(:,2),Experiment(:,6),'b','linewidth',2.0);
set(gca,'fontsize',20,'FontName','Times New Roman'); 
xlabel('Axial strain (%)')
ylabel('Deviator stress (kPa)')
set(gca, 'ytick',[-50:25:50]);
legend('Computed','Experimental','location','Northeast')
legend boxoff

% figure
% plot(strain(:,4)*100,(stress(:,2)+stress(:,3)+stress(:,4))/3,'b','linewidth',1.0);
% hold on
% plot(Experiment(:,2),Pp,'r','linewidth',1.0);
% set(gca,'fontsize',18,'FontName','Times New Roman'); 
% xlabel('Axial Strain (%)')
% ylabel('Mean Effective Stress, kPa')

figure
plot(cycle,(Cp(1)-Cp(1:end-1))/Cp(1),'k','linewidth',2.0);
hold on
plot(Experiment(:,1)/3,(Pp(1)-Pp)/Pp(1),'b','linewidth',2.0);
set(gca,'fontsize',20,'FontName','Times New Roman'); 
xlabel('No. of cycles')
ylabel('Excess pore pressure (kPa)')
legend('Computed','Experimental','location','Northeast')
legend boxoff
ylim([0 1])
xlim([0 12])

figure
plot((strain(:,1)-20000)/2,strain(:,4)*100,'k','linewidth',2.0);
hold on
plot(Experiment(:,1)/3,Experiment(:,2),'b','linewidth',2.0);
set(gca,'fontsize',20,'FontName','Times New Roman'); 
xlabel('No. of cycles')
ylabel('Axial strain (%)')
legend('Computed','Experimental','location','Northeast')
legend boxoff
xlim([0 12])