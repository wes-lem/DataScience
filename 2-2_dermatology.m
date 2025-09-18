clear dados alvos;

% Seleciona apenas atributos histopatológicos
dados = derm_input(12:33, :);         % vetores com os atríbutos hispatologicos
alvos = derm_target;

[LinD, ColD] = size(dados);

% Normaliza o conjunto de treinamento
for i = 1:LinD
    mi = mean(dados(i,:));
    di = std(dados(i,:));
    dados(i,:) = (dados(i,:) - mi)./di;
end

CONF_histo = zeros(No,No+1);

tic
for Rodada = 1:n
    J = floor(ptrn * ColD);
    
    I = randperm(ColD);
    aux_d = dados(:,I);
    aux_a = alvos(:,I);
    
    P = aux_d(:,1:J);
    T = aux_a(:,1:J);
    [linT, colT] = size(P);
    
    P2 = aux_d(:,J+1:end);
    T2 = aux_a(:,J+1:end);
    [linV, colV] = size(P2);
    
    W = 0.1*rand(linT+1,No);
    epoca = 1;
    media_EQ = 1;
    
    while(media_EQ(epoca)>crit_EQ)
        I = randperm(colT);
        P = P(:,I);
        T = T(:,I);
        EQ=0;
        for i=1:colT
            X = [-1; P(:,i)];
            u = W'*X;

            for m=1:No
                if (u(m,:)>=0)
                    y(m,:) = 1;
                else
                    y(m,:) = 0;
                end
            end

            e = T(:,i) - y;
            EQ = EQ + sum(e.^2);
            W = W + eta*X*e';
        end
        epoca = epoca + 1;
        media_EQ(epoca)=EQ/colT;
    end
    
    y_v = [];
    for i=1:colV
            X = [-1; P2(:,i)];
            u = W'*X;

            for m=1:No
                if (u(m,:)>=0)
                    y(m,:) = 1;
                else
                    y(m,:) = 0;
                end
            end
            y_v = [y_v, y];
    end
    
    count_ok = 0;
    for i=1:colV
        i_T2 = find(T2(:,i));
        i_yV = find(y_v(:,i));
        
        if(size(i_T2)==size(i_yV))
            if(i_T2==i_yV)
                count_ok = count_ok + 1;
            end
            CONF_histo(i_T2,i_yV) = CONF_histo(i_T2,i_yV) + 1;
        else
            [n_yV_,n_yV] = size(i_yV); 
            if (n_yV_==0)
                n_yV = 0;
            end

            if(n_yV>0)
                for t=1:n_yV
                    CONF_histo(i_T2,i_yV(t)) = CONF_histo(i_T2,i_yV(t)) + 1;
                end
            else
                CONF_histo(i_T2,No+1) = CONF_histo(i_T2,No+1) + 1;
            end
        end
    end
    
    tx_acerto_histo(Rodada) = 100*count_ok/colV;
end

% 2.2 Taxa de acerto média e variância para atributos histopatológicos
taxa_acerto_media_histo = sum(tx_acerto_histo)/n;
variancia_histo = var(tx_acerto_histo);

% Precisão e acurácia para atributos histopatológicos
precisao_histo = zeros(1, No);
for i = 1:No
    tp = CONF_histo(i, i);
    fp = sum(CONF_histo(:, i)) - tp;
    if (tp + fp) > 0
        precisao_histo(i) = tp / (tp + fp);
    else
        precisao_histo(i) = 0;
    end
end

precisao_media_histo = mean(precisao_histo);
acertos_totais_histo = sum(diag(CONF_histo));
total_amostras_histo = sum(sum(CONF_histo));
acuracia_histo = acertos_totais_histo / total_amostras_histo;

toc
