# API GraphQL de recomendação musical

API Node.js com `@neo4j/graphql` para consultar usuários, faixas, artistas, gêneros e tags.

## Configuração

1. Copie `.env.example` para `.env` e informe as credenciais do seu Neo4j.
2. Carregue o grafo conforme as instruções do README principal.
3. Na pasta `graphql`, instale as dependências e inicie o servidor:

```powershell
npm install
npm start
```

O GraphQL Playground estará disponível em `http://localhost:4000`.

## Exemplos

Recomendações colaborativas para um usuário:

```graphql
query {
  users(where: { userId: "b80344d063b5ccb3212f76538f3d9e43d87dca9e" }) {
    userId
    recommendations(first: 10) {
      trackId
      name
      artist
    }
  }
}
```

Faixas com tags semelhantes:

```graphql
query {
  tracks(where: { trackId: "TRIOREW128F424EAF0" }) {
    name
    artist
    similar(first: 10) {
      name
      artist
    }
  }
}
```
