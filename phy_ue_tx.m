function phy_ue_tx( PHY_VARS_UE )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    %%======================���Բ�����ֵ======================%%
    %%����PUCCH����
    pucch = 1;
    
    %%======================���Բ�����ֵ======================%%
    
    phy_vars_ue = PHY_VARS_UE;
    frame_parms = PHY_VARS_UE.LTE_DL_FRAME_PARMS;
    
    slot_tx = phy_vars_ue.slot_tx;
    subframe_tx = slot_tx/2;
    frame_tx = phy_vars_ue.frame_tx;
    
    if mod(slot_tx,2) == 0
        %%���ʣ�
        if phy_vars_ue.UE_State ~= 1
            harq_pid = subframe2harq_pid(frame_parms,frame_tx,subframe_tx);
            
          %%�ж��Ƿ�Ҫ����Msg3
          %%����RAR����ȡPUSCH����
          
          if phy_vars_ue.ulsch_ue.harq_processes(harq_pid).subframe_scheduling_flag == 1
              generate_ul_signal = 1;
              phy_vars_ue.ulsch_ue.harq_processes(harq_pid).subframe_scheduling_flag = 0;
%               ack_status = get_ack();%% 36.213 table 10.1-1 TODO
              first_rb = phy_vars_ue.ulsch_ue.harq_processes(harq_pid).first_rb;
              nb_rb = phy_vars_ue.ulsch_ue.harq_processes(harq_pid).nb_rb;
              
              msg3_flag = 0;
              if(msg3_flag == 1)
                  %%send msg3 TODO
              else
                  %%��L2��ȡ����
                  %%����ʱ���Բ���L1�Լ���������
                  input_buffer_length = phy_vars_ue.ulsch_ue.harq_processes(harq_pid).TBS;
                  ulsch_input_buf = round(2*rand(1,input_buffer_length)/2);%%�������input_buffer_length��bit
                  
                  ulsch_encoding(ulsch_input_buf,phy_vars_ue,harq_pid,0,0,0);
                  
                  ulsch_modulation(phy_vars_ue,amp,frame_tx,subframe_tx,phy_vars_ue.ulsch_ue);%%ampʱ���ȵ���ϵ���������붨�㻰�йأ�TODO
                  
                  %%generate dmrs ,ul has only one tx antenna
                  generate_drs_pusch(phy_vars_ue,amp,sunframe_tx,first_rb,nb_rb,0);
                  
              end
%           elseif cba == 1%%what is cba?
          elseif pucch == 1 && phy_vars_ue.UE_State == 3;%% PUCCH���������жϣ�TODO
              bundling_flag = 0;%%TODO
              payload = 1;
              pucch_format = 0;%%pucch format 1
              tx_pucch(phy_vars_ue,pucch_format,payload);
              
          end
          
          if generate_ul_signal == 1
              
              ulsch_start = frame_parms.samples_per_tti*subframe_tx - phy_vars_ue.N_TA_offset;
              
              if frame_parms.Ncp == 0
                  nsymb = 14;
              else 
                  nsymb = 12;
              end
              
              %%����SC-FDMA����
              phy_ofdm_mod();%%TODO
              
              %%ƫ��7.5KHZ
              %%TODO   
          end     
        end
                  
        %%����prach
        %%Ӧ����L2����������ʱ������L1���д���
        %%TODO
        
    end

end

