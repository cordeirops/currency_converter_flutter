# Gerenciador de Contas em Moedas Estrangeiras

## Descrição

Um aplicativo Flutter para gerenciar contas em diferentes moedas, com conversão automática para BRL (Real Brasileiro) baseada em cotações atualizadas em tempo real.

## Funcionalidades

- **Autenticação de usuários**
  - Cadastro de novos usuários
  - Login seguro com email e senha
  - Proteção de rotas para usuários autenticados

- **Gerenciamento de contas**
  - Adição de contas em diferentes moedas
  - Visualização de saldo em moeda original e convertido para BRL
  - Edição e exclusão de contas existentes
  - Cálculo automático do saldo total consolidado em BRL

- **Cotações de moedas em tempo real**
  - Visualização das cotações atuais
  - Atualização automática a cada 5 minutos
  - Atualização manual sob demanda
  - Suporte para várias moedas (USD, EUR, GBP, JPY, CAD, AUD, CHF)

## Tecnologias utilizadas

- **Flutter** - Framework para desenvolvimento multiplataforma
- **Firebase Authentication** - Autenticação de usuários
- **Cloud Firestore** - Banco de dados para armazenamento das contas
- **API AwesomeAPI** - Integração para obtenção de cotações em tempo real
- **Provider** - Gerenciamento de estado da aplicação

## Arquitetura

O aplicativo segue uma arquitetura de serviços com separação clara de responsabilidades:

- **Models**: Representações de dados (Conta, Moeda)
- **Services**: Lógica de negócios e integração com APIs e banco de dados
  - AuthService: Gerenciamento de autenticação
  - ContaService: Operações CRUD para contas
  - CotacaoService: Obtenção e gerenciamento de cotações
  - ApiService: Comunicação com a API de cotações

## Como usar

1. Faça login com seu email e senha ou cadastre-se caso seja o primeiro acesso
2. Na tela principal, navegue para "Minhas Contas" ou "Cotações de Moedas"
3. Para adicionar uma nova conta:
   - Clique no botão "Nova Conta"
   - Preencha o nome da conta, selecione a moeda e informe o saldo
   - A conversão para BRL é feita automaticamente
4. Para visualizar cotações:
   - Acesse a tela de cotações
   - Para atualizar manualmente, clique no botão de atualização

## Requisitos

- Flutter 2.0 ou superior
- Conexão com internet para atualização de cotações
- Projeto Firebase configurado com Authentication e Firestore

## Segurança

- Autenticação segura via Firebase Authentication
- Regras de segurança no Firestore para controle de acesso
- Contas vinculadas ao ID do usuário
- Atualizações periódicas para manter valores precisos

---

Desenvolvido com Flutter e Firebase. Cotações fornecidas por AwesomeAPI.