% Calcula a magnitude média dos pesos para cada atributo (sem o bias)
W_sem_bias = W_todos(2:end, :);
magnitude_pesos = mean(abs(W_sem_bias), 2);

% Identifica os atributos mais importantes
[pesos_ordenados, indices_ordenados] = sort(magnitude_pesos, 'descend');

% Análise por tipo de atributo
pesos_clinicos = [magnitude_pesos(1:11); magnitude_pesos(33)]; % O atributo 34 está na posição 33 após remover o bias
pesos_histopatologicos = magnitude_pesos(12:32); % Atributos 12:33 estão nas posições 12:32

media_clinicos = mean(pesos_clinicos);
media_histopatologicos = mean(pesos_histopatologicos);

%% QUESTÃO 2.4: COMPARAÇÃO E CONCLUSÕES

% Determina o melhor conjunto
if taxa_acerto_media_clinicos > taxa_acerto_media_histo
    melhor_subset = 'clinicos';
else
    melhor_subset = 'histopatologicos';
end

% Verifica se é possível reduzir atributos
if taxa_acerto_media_todos > max(taxa_acerto_media_clinicos, taxa_acerto_media_histo)
    reducao_possivel = 0; % Não
else
    reducao_possivel = 1; % Sim
end

% Conjunto mais importante pela análise de sensibilidade
if media_clinicos > media_histopatologicos
    mais_importante = 'clinicos';
else
    mais_importante = 'histopatologicos';
end

clear derm_input;       % liberar espaço de memória
clear derm_target;clear derm_target;



sinal
