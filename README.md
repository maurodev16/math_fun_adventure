# 🧮 Math Fun Adventure

## Documentação Completa do Projeto

### 📝 Resumo Executivo

Math Fun Adventure é um aplicativo educativo gamificado desenvolvido em Flutter, voltado para crianças de 6 a 12 anos. O objetivo principal é tornar o aprendizado de matemática divertido e envolvente através de desafios interativos, sistema de recompensas e uma progressão de dificuldade adaptativa.

### 🎯 Objetivos do Projeto

- Criar uma experiência de aprendizado matemático divertida e envolvente
- Desenvolver habilidades matemáticas fundamentais em crianças de 6 a 12 anos
- Oferecer feedback imediato e positivo para incentivar o aprendizado contínuo
- Implementar elementos de gamificação para manter o engajamento a longo prazo
- Criar uma interface intuitiva com interações do tipo drag and drop
- Proporcionar uma experiência visual atraente com gráficos animados e amigáveis
### 👦👧 Público-Alvo

- **Primário**: Crianças entre 6 e 12 anos
- **Primário**: Crianças entre 6 e 12 anos
- **Secundário**: Pais e educadores que buscam ferramentas educacionais complementares
### 📱 Plataformas Suportadas

- Android (prioridade inicial)
- iOS
- Android (prioridade inicial)
- iOS 
- Web (expansão futura)
- Tablets (otimizado para uso educacional em sala de aula)

## 🏗️ Arquitetura do Projeto

### Estrutura de Camadas (Clean Architecture)
1. **Camada de Apresentação (UI/UX)**
   - Telas e Widgets
   - Gerenciamento de estado (Provider/Riverpod)
   - Animações e efeitos visuais
   
2. **Camada de Domínio (Regras de Negócio)**
   - Entidades (Usuário, Desafio, Progresso)
   - Casos de uso (Geração de desafios, Cálculo de pontuação)
   - Interfaces de repositório
   
3. **Camada de Dados**
   - Implementações de repositórios
   - Fontes de dados locais (Shared Preferences, Hive)
   - Serviços de API (para recursos futuros como sincronização)

### Módulos Principais
1. **Core**
   - Configurações globais
   - Injeção de dependências
   - Utilitários e constantes
   
2. **Autenticação e Perfil**
   - Criação de perfil/avatar
   - Armazenamento de progresso
   - Sistema de conquistas
   
3. **Desafios Matemáticos**
   - Gerador de problemas por nível e tipo
   - Sistema de verificação de respostas
   - Temporizadores e contadores
   
4. **Gamificação**
   - Sistema de recompensas
   - Loja virtual
   - Tabelas de classificação
   
5. **Acessibilidade**
   - Suporte a leitores de tela
   - Configurações de contraste e tamanho
   - Ajustes de dificuldade dinâmicos

## 🎮 Fluxo de Navegação e Experiência do Usuário

### Telas Principais
1. **Tela de Início**
   - Login/perfil (avatar personalizável)
   - Acesso aos mundos/níveis
   - Loja virtual e conquistas
   - Configurações

2. **Seleção de Mundo**
   - Mapa interativo com mundos temáticos
   - Indicadores de progresso
   - Níveis bloqueados/desbloqueados

3. **Seleção de Nível**
   - Lista de desafios disponíveis
   - Estrelas/medalhas conquistadas
   - Dificuldade e tipo de desafio

4. **Tela de Jogo**
   - Área principal de desafio
   - Contador de tempo/pontos
   - Botões de ajuda/dicas
   - Feedback visual e sonoro

5. **Resultado/Recompensa**
   - Resumo de desempenho
   - Recompensas obtidas
   - Botões para próximo nível/repetir/sair

6. **Perfil do Jogador**
   - Estatísticas de desempenho
   - Coleção de conquistas
   - Personalização de avatar
   - Histórico de atividades

### Fluxo de Onboarding
1. Tela de boas-vindas com tutorial interativo
2. Criação de perfil e personalização inicial
3. Primeiro desafio guiado (nível tutorial)
4. Apresentação do sistema de recompensas
5. Desbloqueio do primeiro mundo

## 🎨 Design e Identidade Visual

### Paleta de Cores
- **Principal**: Tons vibrantes e amigáveis
  - Azul primário: #4C6FFF
  - Verde secundário: #42E682
  - Amarelo destaque: #FFD747
  - Vermelho acentuação: #FF6B6B
  
- **Fundos**:
  - Branco: #FFFFFF
  - Cinza claro: #F8F9FA
  - Azul claro: #E9F0FF

### Tipografia
- **Título principal**: Fonte arredondada e lúdica (ex: Quicksand Bold)
- **Texto de jogo**: Fonte clara e legível (ex: Open Sans)
- **Números e elementos matemáticos**: Fonte especializada para clareza matemática

### Estilo de Ilustração
- Personagens cartunescos com proporções amigáveis
- Objetos com contornos suaves e sombras leves
- Animações fluidas com easing curves naturais
- Efeitos de partículas para recompensas e acertos

### Feedback Visual
- Animações de sucesso (estrelas, confetes)
- Indicadores de tempo (barras coloridas)
- Efeitos de shake para respostas incorretas
- Highlight para áreas de drag and drop

## 🧩 Conteúdo Matemático e Progressão

### Mundos Temáticos
1. **Ilha dos Números** (6-7 anos)
   - Reconhecimento de números
   - Contagem básica
   - Sequências simples
   - Comparações maior/menor

2. **Floresta da Adição** (7-8 anos)
   - Adição de números simples
   - Agrupamento e contagem
   - Problemas de enunciado simples
   - Adição com dezenas

3. **Caverna da Subtração** (8-9 anos)
   - Subtração básica
   - Problemas de "quanto falta"
   - Subtração com reagrupamento
   - Comparação de quantidades

4. **Castelo da Multiplicação** (9-10 anos)
   - Multiplicação como adição repetida
   - Tabuadas interativas
   - Multiplicação por dezenas
   - Propriedades básicas

5. **Oceano da Divisão** (10-11 anos)
   - Divisão como partição
   - Divisão exata e com resto
   - Problemas práticos
   - Relação com multiplicação

6. **Laboratório das Frações** (11-12 anos)
   - Frações básicas
   - Comparação de frações
   - Adição e subtração simples
   - Frações equivalentes

### Tipos de Desafios

1. **Arraste e Acerte**
   - Arrastar números para completar equações
   - Posicionar peças numéricas em sequência
   - Completar quebra-cabeças matemáticos

2. **Corrida Contra o Tempo**
   - Resolver máximo de problemas em tempo limitado
   - Completar desafios antes do fim do cronômetro
   - Ganhar tempo extra com respostas corretas

3. **Memória Matemática**
   - Corresponder problemas e soluções
   - Encontrar pares de números com certa relação
   - Recordar sequências numéricas

4. **Construtor de Equações**
   - Montar equações que resultem em valor específico
   - Criar expressões usando operações diversas
   - Reorganizar elementos para obter resultado correto

5. **Desafios de Lógica**
   - Completar sequências lógicas
   - Resolver problemas de raciocínio matemático
   - Identificar padrões e regras

### Progressão de Dificuldade
- **Cada mundo**: 5 níveis + 1 chefe de fase
- **Cada nível**: 3 estrelas possíveis (precisão, tempo, bônus)
- **Desbloqueio**: 70% das estrelas do mundo anterior
- **Adaptação**: Ajuste dinâmico baseado no desempenho do jogador

## 🏆 Sistema de Gamificação

### Recompensas e Motivação
1. **Sistema de Estrelas**
   - 1 estrela: Completar o desafio
   - 2 estrelas: Completar com precisão acima de 80%
   - 3 estrelas: Completar com precisão acima de 95% e tempo ótimo

2. **Conquistas Desbloqueáveis**
   - Sequência de dias jogados
   - Maestria em operações específicas
   - Desafios especiais completados
   - Coleção de itens raros

3. **Moeda Virtual (Math Coins)**
   - Ganhos por completar níveis
   - Bônus por desempenho excepcional
   - Recompensas diárias
   - Conquistas especiais

4. **Loja Virtual**
   - Itens de personalização para avatar
   - Temas para interface
   - Desbloqueio antecipado de conteúdo
   - Poderes especiais (dicas extras, tempo estendido)

### Elementos de Engajamento
1. **Calendário de Recompensas**
   - Prêmios por login diário
   - Desafios semanais especiais
   - Eventos temáticos sazonais

2. **Sistema de Progresso Visual**
   - Mapa de mundos com progresso marcado
   - Barra de experiência de jogador
   - Coleção visível de conquistas

3. **Power-ups e Ajudas**
   - Dicas limitadas por nível
   - Tempo extra
   - Pular pergunta
   - Simplificar problema

## 🛠️ Especificações Técnicas

### Tecnologias Principais

- **Framework**: Flutter (última versão estável)
- **Linguagem**: Dart
- **Gerenciamento de Estado**: Riverpod/Provider
- **Persistência Local**: Hive/SharedPreferences

### Pacotes Recomendados

| Finalidade | Pacote | Justificativa |
|------------|--------|---------------|
| Animações | `flutter_animate`, `rive` | Animações fluidas e interativas |
| Drag and Drop | `flutter_drag_and_drop` | Implementação dos desafios interativos |
| Gerenciamento de estado | `riverpod` | Controle reativo e escalável |
| Áudio | `just_audio` | Efeitos sonoros e músicas temáticas |
| Navegação | `go_router` | Navegação estruturada e padrões de URL |
| Armazenamento | `hive`, `shared_preferences` | Persistência de dados local |
| Internacionalização | `flutter_localizations` | Suporte a múltiplos idiomas |
| Avatar | `fluttermoji` (customizado) | Sistema de avatares personalizáveis |
| Temporizadores | `timer_builder` | Desafios com tempo |
| Gráficos/Charts | `fl_chart` | Visualização de progresso |

### Requisitos de Performance
- **Tamanho do APK**: <30MB
- **Uso de memória**: <150MB
- **Tempo de inicialização**: <3 segundos
- **FPS alvo**: 60fps para todas as animações
- **Compatibilidade**: Android 6.0+ / iOS 12.0+

### Estratégia de Testes
1. **Testes Unitários**
   - Lógica de geração de problemas
   - Cálculo de pontuações e recompensas
   - Gerenciamento de progresso

2. **Testes de Widget**
   - Interações de drag and drop
   - Feedback visual e sonoro
   - Responsividade em diferentes tamanhos

3. **Testes de Integração**
   - Fluxos de navegação completos
   - Persistência de dados
   - Progressão entre níveis

4. **Testes de Usabilidade**
   - Sessões com crianças do público-alvo
   - Feedback de educadores
   - Análise de pontos de frustração

## 📅 Cronograma de Desenvolvimento (MVP)

### Fase 1: Fundação (4 semanas)
- Configuração do projeto e estrutura base
- Implementação da arquitetura core
- Design da UI principal e fluxo de navegação
- Protótipos de interação drag and drop

### Fase 2: Conteúdo Básico (6 semanas)
- Implementação dos primeiros 3 mundos
- Sistema de perfil e progresso
- Mecanismos de recompensa básicos
- Interface de usuário e animações

### Fase 3: Gamificação e Polimento (4 semanas)
- Sistema completo de conquistas
- Loja virtual e moeda do jogo
- Ajustes de dificuldade e balanceamento
- Otimização de performance

### Fase 4: Testes e Lançamento (2 semanas)
- Testes de usabilidade com público-alvo
- Correção de bugs e ajustes finais
- Preparação para lançamento (store listings)
- Lançamento na Play Store (inicial)

## 🔍 Métricas de Sucesso

### KPIs Principais
- **Engajamento**: Tempo médio de sessão > 15 minutos
- **Retenção**: Taxa de retenção D7 > 40%
- **Progresso**: % de usuários completando mundo 1 > 70%
- **Satisfação**: Avaliação média nas lojas > 4.5 estrelas

### Métricas Educacionais
- Melhoria em testes pré/pós sobre conteúdo abordado
- Tempo para domínio de conceitos específicos
- Taxa de acertos em desafios repetidos

## 🚀 Plano de Expansão Futura

### Atualizações Planejadas
1. **Novos Mundos Matemáticos**
   - Geometria básica
   - Medidas e conversões
   - Probabilidade simples
   - Problemas verbais complexos

2. **Recursos Multijogador**
   - Competições entre amigos
   - Desafios cooperativos
   - Tabelas de classificação

3. **Ferramenta para Educadores**
   - Dashboard de progresso por aluno
   - Personalização de conteúdo
   - Exportação de relatórios

4. **Adaptações Regionais**
   - Localização para múltiplos idiomas
   - Conteúdo culturalmente relevante
   - Suporte a diferentes currículos

### Integrações Potenciais
- Sistemas escolares de gestão de aprendizado
- Plataformas de educação em casa
- Aplicações parentais de controle e acompanhamento

## 🔒 Considerações de Privacidade e Segurança

### Proteção de Dados
- Armazenamento local de dados de usuário
- Nenhuma coleta de informação pessoal identificável
- Conformidade com COPPA/GDPR

### Controles Parentais
- Opções de limite de tempo de jogo
- Relatórios de progresso para pais
- Configurações de dificuldade ajustáveis

---

## Apêndice A: Wireframes Iniciais

*[Aqui seriam incluídos esboços das telas principais]*

## Apêndice B: Fluxograma de Navegação

*[Aqui seria incluído um diagrama mostrando a relação entre as telas]*
*[Aqui seriam incluídos exemplos concretos de desafios matemáticos]*
## Apêndice C: Exemplos de Desafios por Nível

*[Aqui seriam incluídos exemplos concretos de desafios matemáticos]*