function h = data_control_multiplexing( q,f,q_ri,q_ack,Qm,Q_CQI,G,Qprime_RI,Qprime_ACK,N_pusch_symb )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    %%q_ri��q_ack����һά���飬����һά�����������������
    %% [1,2;3,4] ��ʾΪ[1,3,2,4]
    %%qΪCQI bit��
    ColumnSet_RI = [1,4,7,10;0,3,5,8];
    ColumnSet_HARQ = [2,3,8,9;1,2,6,7];
    
    %%CQI��PUSCH data ����
    H = G+Q_CQI;
    Hprime = H/Qm;
    
    i = 0;
    j = 0;
    k = 0;
    g = zeros(Qm,Hprime);
    while j < Q_CQI
        g(:,k+1) = q(j+1:(j+1)+Qm-1)';%%j+1��Ϊmatlab�±��1��ʼ
        j = j+Qm;
        k = k+1;
    end
    
    while i < G
        g(:,k+1) = f(i+1:(i+1)+Qm-1)';
        i = i+Qm;
        k = k+1;
    end

    %%�ŵ���֯
    Hpp = Hprime + Qprime_RI;
    Cmux = N_pusch_symb;
    Rmux = (Hpp*Qm)/Cmux;
    Rmux_prime = Rmux/Qm;
    
    %%RI�ŵ���֯
    i = 0;
    j = 0;
    r = Rmux_prime - 1;
    cp = 0;%%TODO �������û�ȡ
    y = zeros(1,Rmux*Cmux);
    flag = zeros(1,Rmux*Cmux);%%��עy�е�λ���Ƿ���ӳ��RI
    while i < Qprime_RI
        cRI = ColumnSet_RI(1+cp,j+1);
%         y((r+1):(r+1)+Qm-1,cRI + 1) = q_ri(i);%%q_riΪ������
        %%y������ʵ��ʱ����һά����ʵ��
        y(Qm*(r*Cmux+cRI)+1:Qm*(r*Cmux+cRI)+Qm) = q_ri(i*Qm+1:i*Qm+Qm);
        flag(Qm*(r*Cmux+cRI)+1:Qm*(r*Cmux+cRI)+Qm) = 1;
        i = i+1;
        r = Rmux_prime -1 -floor(i/4);
        j = mod(j+3,4);
    end
    
    i= 0;
    k = 0;
    while k < Hprime
        if flag(i+1:i+Qm) == 0
            y(i+1:i+Qm) = g(:,k+1)';
            k = k+1;
        end
        i = i+Qm;
    end
    
    i = 0;
    j = 0;
    r = Rmux_prime - 1;
    while i < Qprime_ACK
        cACK = ColumnSet_HARQ(1+cp,j+1);
        y(Qm*(r*Cmux+cACK)+1:Qm*(r*Cmux+cACK)+Qm) = q_ack(i*Qm+1:i*Qm+Qm);
        i = i+Qm;
        r = Rmux_prime -1 -floor(i/4);
        j = mod(j+3,4);
    end
    
    %%����������ɺ��bit
    tmp = reshape(y,Rmux/Qm,Cmux*Qm);
    b = zeros(Rmux,Cmux);
    for i = 0:Rmux/Qm-1
        a = tmp(i+1,:);
        b(i*Qm+1:i*Qm+Qm,:) = reshape(a,Qm,length(a)/Qm);
    end
    [i,j] = size(b);
    x = 1:i;
    y = 1:j;
    surf(y,x,b);
    h = reshape(b,1,Rmux*Cmux);
end

