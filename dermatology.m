clear; close; clc;

%% CARREGA DADOS DA REDE
load derm_input.txt;
load derm_target.txt;

%% QUESTÃO 1: TODOS OS ATRIBUTOS

% Seleciona todos os atributos
dados = derm_input;     % vetores com todos atríbutos de entrada da rede
alvos = derm_target;    % vetores com as saídas desejadas correspondentes

[LinD, ColD] = size(dados);   % Qtd de linhas (atributos) e colunas (instâncias) dos dados de entrada

% Normaliza o conjunto de treinamento para média zero e variância unitária
for i = 1:LinD
    mi = mean(dados(i,:));    %média das linhas
    di = std(dados(i,:));     %desvio padrão das linhas
    dados(i,:) = (dados(i,:) - mi)./di; % dados de entrada normalizados
end

%% DEFINE A ARQUITETURA DA REDE
No = 6;     % No. de neurônios na camada de saída
n = 50;      % No. de rodadas de teste para medidas estatísticas
eta = 0.01;  % Taxa de aprendizado
ptrn = 0.8; % Porcentagem usada para treinamento
crit_EQ = 0.05; % Critério de parada baseado no erro quadrático
CONF_todos = zeros(No,No+1);

tic
for Rodada = 1:n
    J = floor(ptrn * ColD);
    
    I = randperm(ColD);
    aux_d = dados(:,I);     % Embaralha as entradas para cada rodada de treinamento da rede
    aux_a = alvos(:,I);     % Embaralha as saídas desejadas para rodada treinamento da rede
    
    % Subconjunto de dados e alvos para o treinamento da rede
    P = aux_d(:,1:J);
    T = aux_a(:,1:J);
    [linT, colT] = size(P);
    
    % Subconjunto de dados e alvos para a validação da rede
    P2 = aux_d(:,J+1:end);
    T2 = aux_a(:,J+1:end);
    [linV, colV] = size(P2);
    
    % Iniciando a matriz de pesos sinápticos com valores aleatórios
    W = 0.1*rand(linT+1,No);
    epoca = 1;
    media_EQ = 1;
    
    while(media_EQ(epoca)>crit_EQ)
        %% ETAPA DE TREINAMENTO
        I = randperm(colT);
        P = P(:,I);             % Embaralha as entradas para cada época de treinamento da rede
        T = T(:,I);             % Embaralha as saídas desejadas para época treinamento da rede
        EQ=0;
        for i=1:colT
            X = [-1; P(:,i)];   % Construindo o vetor de entradas com a adição da entrada cte -1
            u = W'*X;           % Ativação dos neurônios

            for m=1:No          % Função de ativação do tipo Signal
                if (u(m,:)>=0)
                    y(m,:) = 1;
                else
                    y(m,:) = 0;
                end
            end

            % Cálculo do erro
            e = T(:,i) - y;
            EQ = EQ + sum(e.^2);
            W = W + eta*X*e';
        end
        epoca = epoca + 1;
        media_EQ(epoca)=EQ/colT;
    end
    
    % Salva pesos da última rodada para análise de sensibilidade
    if Rodada == n
        W_todos = W;
    end
    
    %% ETAPA DE VALIDAÇÃO
    y_v = [];
    for i=1:colV
            X = [-1; P2(:,i)];  % Construindo o vetor de entradas para validação da rede com a adição da entrada cte -1
            u = W'*X;           % Ativação dos neurônios

            for m=1:No          % Função de ativação do tipo Signal
                if (u(m,:)>=0)
                    y(m,:) = 1;
                else
                    y(m,:) = 0;
                end
            end
            y_v = [y_v, y];
    end
    
    % CÁLCULO DA TAXA DE ACERTO
    count_ok = 0;
    for i=1:colV
        i_T2 = find(T2(:,i));
        i_yV = find(y_v(:,i));
        
        if(size(i_T2)==size(i_yV))
            if(i_T2==i_yV)
                count_ok = count_ok + 1;
            end
            CONF_todos(i_T2,i_yV) = CONF_todos(i_T2,i_yV) + 1;
        else
            [n_yV_,n_yV] = size(i_yV); 
            if (n_yV_==0)
                n_yV = 0;
            end
        

            if(n_yV>0)
                for t=1:n_yV
                    CONF_todos(i_T2,i_yV(t)) = CONF_todos(i_T2,i_yV(t)) + 1;
                end
            else
                CONF_todos(i_T2,No+1) = CONF_todos(i_T2,No+1) + 1;
            end
        end
        
    end
    
    tx_acerto_todos(Rodada) = 100*count_ok/colV;
    
end

% 1.1 Taxa de acerto média e variância
taxa_acerto_media_todos = sum(tx_acerto_todos)/n;
variancia_todos = var(tx_acerto_todos);

% 1.3 Precisão e acurácia
precisao_todos = zeros(1, No);
for i = 1:No
    tp = CONF_todos(i, i);    % Verdadeiros positivos
    fp = sum(CONF_todos(:, i)) - tp;    % Falsos positivos
    if (tp + fp) > 0
        precisao_todos(i) = tp / (tp + fp);
    else
        precisao_todos(i) = 0;
    end
end

% Precisão média
precisao_media_todos = mean(precisao_todos);

% Acurácia geral
acertos_totais = sum(diag(CONF_todos));
total_amostras = sum(sum(CONF_todos));
acuracia_todos = acertos_totais / total_amostras;

% 1.2 Matriz de confusão já calculada: CONF_todos
disp(' '); % Adiciona uma linha em branco para espaçamento
disp('Matriz de Confusão Final (soma das rodadas):');
disp(CONF_todos);

fprintf('Acurácia Global: %.2f%%\n', acuracia_todos * 100);
fprintf('Precisão Média: %.2f%%\n', precisao_media_todos * 100);

% Exibe os acertos como números inteiros
fprintf('Total de Acertos: %d de %d amostras de validação.\n\n', acertos_totais, total_amostras);

toc
