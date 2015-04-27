clc
clear all
%%���ն�
LTE_DL_FRAME_PARMS.N_RB_DL = 100;
LTE_DL_FRAME_PARMS.N_RB_UL = 100;
LTE_DL_FRAME_PARMS.Ncp = 0;
LTE_DL_FRAME_PARMS.Ncp_UL = 0;
LTE_DL_FRAME_PARMS.frame_type = 1;%%0 FDD,1 TDD
LTE_DL_FRAME_PARMS.tdd_config = 3;%%0-7,default 3
LTE_DL_FRAME_PARMS.tdd_config_s = 0;%%special subframe config 0-9

LTE_DL_FRAME_PARMS.ofdm_symbol_size = 2048;%% default 2048
LTE_DL_FRAME_PARMS.log2_symbol_size = 11;%% default 2048

LTE_DL_FRAME_PARMS.samples_per_tti = 30720;%%һ����֡�ڵĸ��������
LTE_DL_FRAME_PARMS.symbols_per_tti = 14;%%normal cp

LTE_DL_FRAME_PARMS.nb_antennas_tx = 1;
LTE_DL_FRAME_PARMS.nb_antennas_rx = 1;

LTE_DL_FRAME_PARMS.Nid_cell = 0;

% LTE_DL_FRAME_PARMS.pusch_config_common;%%36.331

LTE_DL_FRAME_PARMS.nb_prefix_samples0 = 160;
LTE_DL_FRAME_PARMS.nb_prefix_samples = 144;


%%eNB ��������
%% hoslds transmit data in time domain,30720��������:a+j*b
LTE_eNB_COMMON.txdata = zeros(LTE_DL_FRAME_PARMS.nb_antennas_tx,LTE_DL_FRAME_PARMS.samples_per_tti);
%% hoslds transmit data in frequency domain,size:15*2048 ��������
LTE_eNB_COMMON.txdataF = zeros(LTE_DL_FRAME_PARMS.nb_antennas_tx,LTE_DL_FRAME_PARMS.ofdm_symbol_size*LTE_DL_FRAME_PARMS.symbols_per_tti);
%% hoslds received data in time domain
LTE_eNB_COMMON.rxdata = zeros(LTE_DL_FRAME_PARMS.nb_antennas_rx,LTE_DL_FRAME_PARMS.samples_per_tti);
%% hoslds received data in frequency domain
LTE_eNB_COMMON.rxdataF = zeros(LTE_DL_FRAME_PARMS.nb_antennas_rx,LTE_DL_FRAME_PARMS.ofdm_symbol_size*LTE_DL_FRAME_PARMS.symbols_per_tti);


%%eNB��������
% PHY_VARS_eNB.LTE.eNB_ULSCH.harq_process;
LTE.eNB_ULSCH.harq_process = 1;%%TODO
LTE_eNB_ULSCH.cyclicShift = 0;%%cyclicShift for DMRS 
LTE_eNB_ULSCH.rnti = 0;%%rnti attributed for this ULSCH

%%eNB��������
% LTE_eNB_PUSCH.rxdataF_ext = zeros(LTE_DL_FRAME_PARMS.nb_antennas_rx,LTE_DL_FRAME_PARMS.symbols_per_tti*LTE_DL_FRAME_PARMS.N_RB_UL*12);%%ȷ�Ͽռ��С��TODO
% LTE_eNB_PUSCH.rxdataF_ext2;
LTE_eNB_PUSCH.drs_ch_estimates_time = zeros(LTE_DL_FRAME_PARMS.nb_antennas_rx,2*2*LTE_DL_FRAME_PARMS.ofdm_symbol_size);
LTE_eNB_PUSCH.drs_ch_estimates = zeros(LTE_DL_FRAME_PARMS.nb_antennas_rx,LTE_DL_FRAME_PARMS.symbols_per_tti*LTE_DL_FRAME_PARMS.N_RB_UL*12);
% LTE_eNB_PUSCH.rxdataF_comp;
% LTE_eNB_PUSCH.ulsch_power;

%%
PHY_VARS_eNB.LTE_eNB_PUSCH = LTE_eNB_PUSCH;
PHY_VARS_eNB.LTE_eNB_ULSCH = LTE_eNB_ULSCH;
PHY_VARS_eNB.LTE_eNB_COMMON = LTE_eNB_COMMON;
PHY_VARS_eNB.LTE_DL_FRAME_PARMS = LTE_DL_FRAME_PARMS;


%%��������
subframe = 3;
subframe = subframe+1;%%#1~#10��ӦЭ���е�#0~#9


%%���ɷ��͵����ݻ��ߴ��ļ��е�������


%%��һ����֡Ϊ��λ��������
%%ȥ��CP,ofdm���� FFT
% for l = subframe*LTE_DL_FRAME_PARMS.symbols_per_tti:(1+subframe)*LTE_DL_FRAME_PARMS.symbols_per_tti
for l = 0:LTE_DL_FRAME_PARMS.symbols_per_tti-1
    slot_fep_ul(LTE_DL_FRAME_PARMS,LTE_eNB_COMMON,mod(l,LTE_DL_FRAME_PARMS.symbols_per_tti/2),floor(l/(floor(LTE_DL_FRAME_PARMS.symbols_per_tti/2))), 0,0);
end

%%��������pusch�ŵ����ŵ����⡢�ŵ����ơ�Ƶƫ���ơ�����ȣ�
rx_ulsch(PHY_VARS_eNB,subframe);%%,0,0,0);

%%ulsch decoding������PUSCH�ŵ����ص�bit��Ϣ
ulsch_decoding(PHY_VARS_eNB,subframe);%%,0,control_only_flag,1,11r8_flag);

