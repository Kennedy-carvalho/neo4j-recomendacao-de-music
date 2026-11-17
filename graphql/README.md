# API GraphQL de recomendação musical

API Node.js com `@neo4j/graphql` para consultar usuários, faixas, artistas, gêneros e tags.

## Requisitos

- Node.js 20 ou superior.
- Um banco Neo4j acessível que contenha o grafo musical.

## Configuração

1. Copie `.env.example` para `.env` e informe a URI, o usuário e a senha do Neo4j. O exemplo usa `NEO4J_DATABASE=projeto-dio`; ajuste esse valor se o seu banco tiver outro nome.
2. Confirme que esse banco contém o grafo musical e que o usuário tem permissão de leitura nele.
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
  users(where: { userId: { eq: "b80344d063b5ccb3212f76538f3d9e43d87dca9e" } }) {
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
  tracks(where: { trackId: { eq: "TRIOREW128F424EAF0" } }) {
    name
    artist
    similar(first: 10) {
      name
      artist
    }
  }
}
```
