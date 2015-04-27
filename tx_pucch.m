function tx_pucch( phy_vars_ue,pucch_format,payload )
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
    frame_parms = phy_vars_ue.LTE_DL_FRAME_PARMS;
    
    %%��������ʱ϶�ͷ��ŵ�ncs_cell
    ncs_cell = init_ncs_cell( frame_parms);
    
    N_PUCCH_seq = 12;
    M_RS_sc = N_PUCCH_seq;
    
    delta_PUCCH_shift = frame_parms.PUCCH_CONFIG_COMMON.delta_PUCCH_shift;
    N1_cs_div_deltaPUCCH_Shift = frame_parms.PUCCH_CONFIG_COMMON.nCS_AN;
    
    if pucch_format == 0
        %%pucch format 1
        d(1) = 1;
    elseif pucch_format == 1
        %%pucch format 1a
        if payload(1) == 0
            d(1) = 1;
        elseif payload(1) == 1
            d(1) = -1;
        end
    elseif pucch_format == 2
        %%pucch format 1b
        if payload(1) == 0 && payload(2) == 0
            d(1) = 1;
        elseif payload(1) == 0 && payload(2) == 1
            d(1) = -j;
        elseif payload(1) == 1 && payload(2) == 0
            d(1) = j;
        elseif payload(1) == 1 && payload(2) == 1
            d(1) = -1;
        end
    end
 
    if frame_parms.Ncp == 0
        d = 2;
        c = 3;
    else
        d = 0;
        c = 2;
    end
    
    %%����n1_PUCCH��n2_PUCCH����PDCCH��λ�ú͸߲������йأ�36.213 10.1
    %%n1_PUCCH��ʾ��PUCCH format1 ��������Դ
    %%n2_PUCCH��ʾ��PUCCH format2��������Դ 
    %%TODO(�����Ƿ��и����ʵļ���λ��)
    n1_PUCCH = 0;%%���д��
    
    if n1_PUCCH < c*N1_cs_div_deltaPUCCH_Shift
        Nprime = N1_cs;
    else
        Nprime = 12;
    end
    
    %%����nprime��ns����nsΪż�����
    ns = 0:2:19;
    if n1_PUCCH < c*N1_cs_div_deltaPUCCH_Shift
        nprime(ns+1) = n1_PUCCH;
    else
        nprime(ns+1) = mod(n1_PUCCH - c*N1_cs_div_deltaPUCCH_Shift,c*12/delta_PUCCH_shift);
    end
    
    %%����nprime��ns����nsΪ�������
    ns = 1:2:19;
    h = mod(nprime(ns-1 + 1)+d,c*Nprime/delta_PUCCH_shift);
    for ns = 1:2:19
        idx = nprime(ns-1+1)+1;
        seq_c(ns+1) = lte_gold_sequence(frame_parms.Nid_cell,idx);
    end
    if n1_PUCCH >= c*N1_cs_div_deltaPUCCH_Shift
        nprime(ns+1) = mod(seq_c(ns+1),c*c*12/delta_PUCCH_shift+1) - 1;
    else
        nprime(ns+1) = floor(h/c)+mod(h,c)*Nprime/delta_PUCCH_shift;
    end
    
    %%����ncs
    
    if frame_parms.Ncp == 0   
        for ns  = 0:19;
            for l = 0:6;
                n_cs(ns+1,l+1) = mod(ncs_cell(ns+1,l+1) + mod(nprime(ns+1)*delta_PUCCH_shift + mod(n_oc(ns+1),delta_PUCCH_shift),Nprime),12);
                n_oc(ns+1,l+1) = nprime(ns+1)*delta_PUCCH_shift/Nprime;
            end
        end
    else   
        for ns  = 0:19
            for l = 0:5
                n_cs(ns+1,l+1) = mod(ncs_cell(ns+1,l+1) + mod(nprime(ns+1)*delta_PUCCH_shift + n_oc(ns+1)/2,Nprime),12);
                n_oc(ns+1,l+1) = 2*floor(nprime(ns+1)*delta_PUCCH_shift/Nprime);
            end
        end
    end
    
    alpha = 2*pi*n_cs/12;
    
    %%����S(ns)
    for ns = 0:19
        if mod(nprime(ns+1),2) == 0
            S(ns+1) = 1;
        else
            S(ns+1) = exp(j*pi/2);
        end
    end
    if shortened == 0
        N_PUCCH_SF = 4;
        w4 = [1,1,1,1;1,-1,1,-1;1,-1,-1,1];
    else 
        if mod(ns,2) == 0
            N_PUCCH_SF = 4;
            w = [1,1,1,1;1,-1,1,-1;1,-1,-1,1];
        else
            N_PUCCH_SF = 3;
            w = [1,1,1;1,exp(j*2*pi/3),exp(j*4*pi/3);1,exp(j*4*pi/3),exp(j*2*pi/3)];
        end
    end
    
    %%����u��v
    %%���Ƶ����PUSCH��PUCCH��ͬ
    f_gh = 0;
    if group_hopping == 1
        for i = 0:7
            c = mod(lte_gold_sequence(frame_parms.Nid_cell/30,8*ns +i)*2^i,30);
            f_gh = f_gh + c;
        end
    end
    %%������λģʽ����PUSCH��PUCCH��ͬ
    f_PUCCH = mod(frame_parms.Nid_cell,30);
    
    u = mod(f_gh + f_PUCCH,30);
    
    %%�������е�Ƶ��ֻ�е��ο��ź�ռ�ó������ߵ���6RBʱ���Ż������е�Ƶ������v = 0
    %%����PUCCH,vʼ�յ���0����ΪPUCCH��Ӧ�Ĳο��ź�ֻռ��1��RB��format 1,2
    v = 0;
    %%��Ƶ
    y = d(1)*exp(j*alpha*n).*generate_ul_ref_base_seq(u,v,12);%%pucch format 1,1a,1b,ռ��һ��RB
    for mprime = 0:1
        for m = 0:N_PUCCH_SF-1
            for n = 0:N_PUCCH_seq -1
                z(mprime*N_PUCCH_SF + m*N_PUCCH_seq + n +1) = S(ns+1)*w(m+1)*y(n+1);
            end
        end
    end
    
end

