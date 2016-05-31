%clc
%clear all
%colo = ['r', 'b', 'k'];
%ddd = [1e3];

%for i=1:length(ddd)
%% Doyle-Fuller-Newman Model
%   Created May 22, 2012 by Scott Moura
%clc;
%clear;
tic;

%% Model Construction
% Electrochemical Model Parameters
% run params_bosch
% run params_dualfoil
% run params_FePO4_ACC15

run params_NMC_Samsung_new_iteration
%run params_NMC_Samsung_new_iteration_after_test_2
%p.sig_n = ddd(i);
% p.D_s_n = ddd(i); %1.736e-14;  % Diffusion coeff for solid in neg. electrode, [m^2/s]
% p.D_s_p = 2.00E-14; %8.256e-14;  % Diffusion coeff for solid in pos. electrode, [m^2/s]




%load('data/Int_Obs/UDDS_data_Oct_26_2015_Sample_05sec');



%load('data/Int_Obs/IC_Pulse')

%load('data/Int_Obs/Cby2Pulse')

load('data/Int_Obs/Samsung_EV_data')

% load('data/Int_Obs/1C_data_Oct_26_2015_05_sample')


%load('data/Int_Obs/UDDS_data_Oct_26_2015_Sample_001sec');

%load('data/Int_Obs/UDDS_data_Oct_26_2015_Sample_05sec_added_zero_trail');

%load('data/Int_Obs/UDDS_data_Oct_26_2015_Sample_05sec_check_1_all_zerosl');

%load('data/Int_Obs/UDDS_data_Oct_26_2015_Sample_05sec_check_2_NOT_all_zerosl');

%load('data/Int_Obs/1C_data_Oct_26_2015_05_sample_w_temp.mat')
%load('data/Int_Obs/test.mat')

% time_exp = time_exp(1:6157);
% volt_exp = volt_exp(1:6157);
% current_exp = current_exp(1:6157);



%% JUST ADDED FROM params_bosch
% p.R_f_n = 1.0000e-05;
% p.R_f_p = 5.0000e-05;
% p.n_Li_s = 2.5975;

% Vector lengths
Ncsn = p.PadeOrder * (p.Nxn-1);
Ncsp = p.PadeOrder * (p.Nxp-1);
Nce = p.Nx - 3;
Nc = Ncsn+Ncsp+Nce;
Nn = p.Nxn - 1;
Np = p.Nxp - 1;
Nnp = Nn+Np;
Nx = p.Nx - 3;
Nz = 3*Nnp + Nx;

% % For LiCo02, with voltage lim [2.5, 4.05], n_Li_s = 2.50, the capacity is
% % 29.601016543579075 Ah/m^2
% OneC = 29.601016543579075; %[Ah/m^2]

% For LiFePO4, with voltage lim [2.0, 3.60], n_Li_s = 0.100687787424000, the capacity is
% 2.590706610839782 Ah/m^2
OneC = 2.08;%<-- This is Ah for Samsug cell, NOT Ah/m^2, %2.590706610839782; %[Ah/m^2]

%% Constant Current Data %%
p.delta_t = 0.05;
%t = 0:p.delta_t:(72);
%t = 0:p.delta_t:1800;
%%I(mod(t,20) < 10) = 350; %350, 10C Discharge for LiFePO4 Cell @ 35Ah/m^2 for 1C

%I(mod(t,20) < 10) = -3*67; %-201, 3C Charge for LiCoO2 Cell 67Ah/m^2 for 1C (etas)
% I(mod(t,20) < 10) = 7*67; %7C Discharge for LiCoO2 Cell 67Ah/m^2 for 1C (ce)
%I = 1*OneC*ones(size(t));

%%%%%%%%%%%%%%%%% FOR INPUT CYCLE FROM DFN MODEL %%%%%%%%%%%%%%%%
% % datafile='data/june292014UDDS.mat';
% datafile='data/UDDSx2_dfn.mat';
% load(datafile);
% 
% t_long = out.time';
% t = (t_long(1):1:t_long(end))';
% NT = length(t);
% 
% % Current | Positive <=> Discharge, Negative <=> Charge
% I_long = out.cur';
% I = interp1(t_long,I_long,t,'linear*');
% % I(t <=0) = 0;

%%%%%%%%% Commented by Federico %%%%%%%%%%%

% Pulse Data
% t = -2:p.delta_t:120;
% I(t >= 0) = 0; 
% I(mod(t,20) < 10) = 350;% 3C = 105   -10C = -350
% Iamp = I;

% Experimental Data
%%%%%%%%%%% Uncommented by Federico %%%%%%%%%%%%%
% %  load('data/UDDSx2_batt_ObsData.mat');
% %  tdata = t;
% %  Tfinal = tdata(end);
% %  t = -2:p.delta_t:Tfinal;
% %  Iamp = interp1(tdata,I,t,'spline',0);
% %  Ah_amp = trapz(tdata,I)/3600;
% %  I = Iamp * (0.4*35)/Ah_amp;
% % %  I = I*4;

%%% Interval Observer Input %%%

%load('data/Int_Obs/UDDSx2_batt_ObsData');
% I = 3*1*I';
% t = t';

I = -current_exp'/p.Area;
t = time_exp';

%%%%%%%%% Uncommented by Federico %%%%%%%%%%%

NT = length(t);

%% Initial Conditions & Preallocation
% Solid concentration

%V0 = 3.9322;%3.6659;%5C pulse, 3.6663;% for 1C Pulse, for UDDS 3.9322;%4.1985;% for 1C, for UDDS 3.9322;
V0 = 3.8290; %3.8288 for NEDC, || 3.8290 for EV || 3.7476 for HEV;

[csn0,csp0] = init_cs(p,V0);

c_s_n0 = zeros(p.PadeOrder,1);
c_s_p0 = zeros(p.PadeOrder,1);

%%%%% Initial condition based on controllable canonical form
% c_s_n0(1) = csn0 * (-p.R_s_n/3) * (p.R_s_n^4 / (3465 * p.D_s_n^2));
% c_s_p0(1) = csp0 * (-p.R_s_p/3) * (p.R_s_p^4 / (3465 * p.D_s_p^2));

%%%%% Initial condition based on Jordan form
c_s_n0(3) = csn0;
c_s_p0(3) = csp0;
%%%%%

c_s_n = zeros(Ncsn,NT);
c_s_p = zeros(Ncsp,NT);

c_s_n(:,1) = repmat(c_s_n0, [Nn 1]);
c_s_p(:,1) = repmat(c_s_p0, [Nn 1]);

% Electrolyte concentration
c_e = zeros(Nx,NT);
c_e(:,1) = p.c_e * ones(Nx,1);

c_ex = zeros(Nx+4,NT);
c_ex(:,1) = c_e(1,1) * ones(Nx+4,1);

% Temperature
T = zeros(NT,1);
T(1) = p.T_amp;

% Solid Potential
Uref_n0 = refPotentialAnode(p, csn0(1)*ones(Nn,1) / p.c_s_n_max);
Uref_p0 = refPotentialCathode(p, csp0(1)*ones(Np,1) / p.c_s_p_max);

phi_s_n = zeros(Nn,NT);
phi_s_p = zeros(Np,NT);
phi_s_n(:,1) = Uref_n0;
phi_s_p(:,1) = Uref_p0;

% Electrolyte Current
i_en = zeros(Nn,NT);
i_ep = zeros(Np,NT);

% Electrolyte Potential
phi_e = zeros(Nx,NT);

% Molar Ionic Flux
jn = zeros(Nn,NT);
jp = zeros(Np,NT);

% Surface concentration
c_ss_n = zeros(Nn,NT);
c_ss_p = zeros(Np,NT);
c_ss_n(:,1) = repmat(csn0, [Nn 1]);
c_ss_p(:,1) = repmat(csp0, [Np 1]);

% Volume average concentration
c_avg_n = zeros(Nn,NT);
c_avg_p = zeros(Np,NT);
c_avg_n(:,1) = repmat(csn0, [Nn 1]);
c_avg_p(:,1) = repmat(csp0, [Np 1]);

SOC = zeros(NT,1);
SOC(1) = mean(c_avg_n(:,1)) / p.c_s_n_max;

% Overpotential
eta_n = zeros(Nn,NT);
eta_p = zeros(Np,NT);

% Constraint Outputs
c_e_0p = zeros(NT,1);
c_e_0p(1) = c_ex(1,1);

eta_s_Ln = zeros(NT,1);
eta_s_Ln(1) = phi_s_p(1,1) - phi_e(1,1);

% Voltage
Volt = zeros(NT,1);
Volt(1) = phi_s_p(end,1) - phi_s_n(1,1);

% Conservation of Li-ion matter
n_Li_s = zeros(NT,1);
n_Li_e = zeros(NT,1);

% Stats
newtonStats.iters = zeros(NT,1);
newtonStats.relres = cell(NT,1);
newtonStats.condJac = zeros(NT,1);

% Initial Conditions
x0 = [c_s_n(:,1); c_s_p(:,1); c_e(:,1); T(1)];

z0 = [phi_s_n(:,1); phi_s_p(:,1); i_en(:,1); i_ep(:,1);...
      phi_e(:,1); jn(:,1); jp(:,1)];

%% Preallocate
x = zeros(length(x0), NT);
z = zeros(length(z0), NT);

x(:,1) = x0;
z(:,1) = z0;

%% Precompute data
% Solid concentration matrices
[A_csn,B_csn,A_csp,B_csp,C_csn,C_csp,A_csn_normalized, A_csp_normalized] = c_s_mats(p);
p.A_csn = A_csn;
p.A_csn_normalized= A_csn_normalized;
p.B_csn = B_csn;
p.A_csp = A_csp;
p.A_csp_normalized=A_csp_normalized;
p.B_csp = B_csp;
p.C_csn = C_csn;
p.C_csp = C_csp;

clear A_csn B_csn A_csp B_csp C_csn C_csp A_csn_normalized A_csp_normalized;

% Electrolyte concentration matrices
[M1n,M2n,M3n,M4n,M5n, M1s,M2s,M3s,M4s, M1p,M2p,M3p,M4p,M5p, C_ce] = c_e_mats_scott(p);

p.ce.M1n = M1n;
p.ce.M2n = M2n;
p.ce.M3n = M3n;
p.ce.M4n = M4n;
p.ce.M5n = M5n;

p.ce.M1s = M1s;
p.ce.M2s = M2s;
p.ce.M3s = M3s;
p.ce.M4s = M4s;

p.ce.M1p = M1p;
p.ce.M2p = M2p;
p.ce.M3p = M3p;
p.ce.M4p = M4p;
p.ce.M5p = M5p;

p.ce.C = C_ce;

clear M1n M2n M3n M4n M5n M1s M2s M3s M4s M1p M2p M3p M4p M5p C_ce;

% Solid Potential
[F1_psn,F1_psp,F2_psn,F2_psp,G_psn,G_psp,...
    C_psn,C_psp,D_psn,D_psp] = phi_s_mats(p);
p.F1_psn = F1_psn;
p.F1_psp = F1_psp;
p.F2_psn = F2_psn;
p.F2_psp = F2_psp;
p.G_psn = G_psn;
p.G_psp = G_psp;
p.C_psn = C_psn;
p.C_psp = C_psp;
p.D_psn = D_psn;
p.D_psp = D_psp;

clear F1_psn F1_psp F2_psn F2_psp G_psn G_psp C_psn C_psp D_psn D_psp;

% Electrolyte Current
[F1_ien,F1_iep,F2_ien,F2_iep,F3_ien,F3_iep] = i_e_mats(p);
p.F1_ien = F1_ien;
p.F1_iep = F1_iep;
p.F2_ien = F2_ien;
p.F2_iep = F2_iep;
p.F3_ien = F3_ien;
p.F3_iep = F3_iep;

clear F1_ien F1_iep F2_ien F2_iep F3_ien F3_iep;

% Jacobian
[f_x, f_z, g_x, g_z] = jac_dfn_pre(p);
p.f_x = f_x;
p.f_z = f_z;
p.g_x = g_x;
p.g_z = g_z;
clear f_x f_z g_x g_z

%% Integrate!
disp('Simulating DFN Model...');
Tbatt(1)=24.8;
for k = 1:(NT-1)
    
    % Current
    if(k == 1)
        Cur_vec = [I(k), I(k), I(k+1)];
    else
        Cur_vec = [I(k-1), I(k), I(k+1)];
    end
    
    % Step-forward in time
    [x(:,k+1), z(:,k+1), stats] = cn_dfn_federico_scott(x(:,k),z(:,k),Cur_vec,p);

    % Parse out States
    c_s_n(:,k+1) = x(1:Ncsn, k+1);
    c_s_p(:,k+1) = x(Ncsn+1:Ncsn+Ncsp, k+1);
    c_e(:,k+1) = x(Ncsn+Ncsp+1:Nc, k+1);
    T(k+1) = x(end, k+1);
    phi_s_n(:,k+1) = z(1:Nn, k+1);
    phi_s_p(:,k+1) = z(Nn+1:Nnp, k+1);
    i_en(:,k+1) = z(Nnp+1:Nnp+Nn, k+1);
    i_ep(:,k+1) = z(Nnp+Nn+1:2*Nnp, k+1);
    phi_e(:,k+1) = z(2*Nnp+1:2*Nnp+Nx, k+1);
    jn(:,k+1) = z(2*Nnp+Nx+1:2*Nnp+Nx+Nn, k+1);
    jp(:,k+1) = z(2*Nnp+Nx+Nn+1:end, k+1);
    
%     i_en(:,k+1)
%     i_ep(:,k+1)
%     
%     phi_s_n(:,k+1)
%     phi_s_p(:,k+1)
%     
%     phi_e(:,k+1)
%     
%     jn(:,k+1)
%     jp(:,k+1)
    
    newtonStats.iters(k+1) = stats.iters;
    newtonStats.relres{k+1} = stats.relres;
    newtonStats.condJac(k+1) = stats.condJac;
    
    % Output data
    [trash_var, trash_var, checking_v, y] = dae_dfn_federico_scott(x(:,k+1),z(:,k+1),I(k+1),p);
    
    c_ss_n(:,k+1) = y(1:Nn);
    c_ss_p(:,k+1) = y(Nn+1:Nnp);
    
    c_avg_n(:,k+1) = y(Nnp+1:Nnp+Nn);
    c_avg_p(:,k+1) = y(Nnp+Nn+1 : 2*Nnp);
    SOC(k+1) = mean(c_avg_n(:,k+1)) / p.c_s_n_max;
    
    c_ex(:,k+1) = y(2*Nnp+1:2*Nnp+Nx+4);
    
    eta_n(:,k+1) = y(2*Nnp+Nx+4+1 : 2*Nnp+Nx+4+Nn);
    eta_p(:,k+1) = y(2*Nnp+Nx+4+Nn+1 : 2*Nnp+Nx+4+Nn+Np);
    
    c_e_0p(k+1) = y(end-4);
    eta_s_Ln(k+1) = y(end-3);
    
    Volt(k+1) = y(end-2);
    n_Li_s(k+1) = y(end-1);
    n_Li_e(k+1) = y(end);
    
    eta_s_n = phi_s_n - phi_e(1:Nn,:);
    eta_s_p = phi_s_p - phi_e(end-Np+1:end, :);
    
    Q_in(:,k+1) = checking_v';
    
    
    
%     T_dot(k) = (p.h*(p.T_amp - Tbatt(k)) - I(k)*volt_exp(k) - Q_in(k)) / (p.rho_avg*p.C_p);
%     Tbatt(k+1) = Tbatt(k) + T_dot(k)*p.delta_t;
    
%     fprintf(1,'Time : %3.2f sec | C-rate : %2.2f | SOC : %1.3f | Voltage : %2.4fV\n',...
%         t(k),I(k+1)/OneC,SOC(k+1),Volt(k+1));
    
    if(Volt(k+1) < p.volt_min)
        fprintf(1,'Min Voltage of %1.1fV exceeded\n',p.volt_min);
%       c_s_n(:,k+1) = x(1:Ncsn, k+1)
%     c_s_p(:,k+1) = x(Ncsn+1:Ncsn+Ncsp, k+1)
%     c_e(:,k+1) = x(Ncsn+Ncsp+1:Nc, k+1)
%     T(k+1) = x(end, k+1)
%     phi_s_n(:,k+1) = z(1:Nn, k+1)
%     phi_s_p(:,k+1) = z(Nn+1:Nnp, k+1)
%     i_en(:,k+1) = z(Nnp+1:Nnp+Nn, k+1)
%     i_ep(:,k+1) = z(Nnp+Nn+1:2*Nnp, k+1)
%     phi_e(:,k+1) = z(2*Nnp+1:2*Nnp+Nx, k+1)
%     jn(:,k+1) = z(2*Nnp+Nx+1:2*Nnp+Nx+Nn, k+1)
%     jp(:,k+1) = z(2*Nnp+Nx+Nn+1:end, k+1)
    
    
        beep;
        %break;
    elseif(Volt(k+1) > p.volt_max)
        fprintf(1,'Max Voltage of %1.1fV exceeded\n',p.volt_max);
        beep;
        break;
    elseif(any(c_ex(:,k) < 1))
        fprintf(1,'c_e depleted below 1 mol/m^3\n');
        beep;
        %break;
    end

end


%% Outputs
disp('Simulating Output Vars...');
simTime = toc;
fprintf(1,'Simulation Time : %3.2f min\n',simTime/60);

%% Plot Results

% figure(1)
% clf
% subplot(411)
% plot(t,I/OneC)
% legend('Icrate')
% xlim([0 t(end)])
% subplot(412)
% plot(t,Volt)
% legend('V')
% xlim([0 t(end)])
% subplot(413)
% plot(t,c_e_0p/1e3)
% hold on
% plot(t,0.15*ones(size(t)),'k--')
% legend('ce0p')
% xlim([0 t(end)])
% subplot(414)
% plot(t,eta_s_Ln)
% hold on
% plot(t,0*ones(size(t)),'k--')
% legend('eta')
% ylim([-0.15 0.2])
% xlim([0 t(end)])


%% Save Output Data for Plotting (HEP)
out.date=date;
out.time=t;
out.cur=I;
out.volt=Volt;
out.soc=SOC;
out.c_ss_n=c_ss_n;
out.c_ss_p=c_ss_p;
out.eta_s_Ln=eta_s_Ln;
out.ce0p=c_e_0p;
out.simtime=simTime;

%save('data/new/dfn_etas_new.mat', '-struct', 'out'); %3C Charge LiCoO2
% save('data/new/dfn_ce_new.mat', '-struct', 'out'); %10C Discharge LiCoO2


%%

figure(11)
plot(t,Volt,'linewidth',2)
hold on
grid on
legend('DFN Model Data')
xlabel('Time [s]')
ylabel('Voltage [V]')
%ylim([3.2 4.22])


%% Load experimental data and check

figure(1)
plot(t,Volt,'linewidth',2)
hold on
grid on
plot(t,volt_exp,'r','linewidth',2)
legend('DFN Model Data','Experimental Data')
xlabel('Time [s]')
ylabel('Voltage [V]')
%ylim([3.56 3.76])
ylim([3.25 4.1])
% 
% 
figure(2)
plot(t,Volt-volt_exp,'r')
hold on
grid on
title('Voltage Error')
%plot(t,volt_exp,'r','linewidth',2)
%legend('DFN Model Data','Experimental Data')
xlabel('Time [s]')
ylabel('Voltage [V]')

rmse = rms(Volt-volt_exp)
%ylim([-0.05 0.15])
% 
% 
% figure(3)
% subplot(2,1,1)
% plot(t,chck_chck(1,:))
% ylim([3.7 4.1])
% legend('phi-s-p-bcs(2)')
% ylabel('Voltage [V]')
% hold on
% subplot(2,1,2)
% plot(chck_chck(2,:),'r')
% ylim([0.05 0.5])
% legend('phi-s-p-bcs(1)')
% xlabel('Time [s]')
% ylabel('Voltage [V]')
% figure(4)
% plot(t,chck_chck(9:11,:))



%end




