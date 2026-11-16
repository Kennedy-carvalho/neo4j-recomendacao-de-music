const { Neo4jGraphQL } = require("@neo4j/graphql");
const { ApolloServer } = require("apollo-server");
const neo4j = require("neo4j-driver");
const dotenv = require("dotenv");
const fs = require("fs");
const path = require("path");

dotenv.config({ path: path.join(__dirname, "..", "..", "graphql", ".env") });

if (!process.env.NEO4J_URI || !process.env.NEO4J_USER || !process.env.NEO4J_PASSWORD) {
  throw new Error("Configure NEO4J_URI, NEO4J_USER e NEO4J_PASSWORD no arquivo .env.");
}

const driver = neo4j.driver(
  process.env.NEO4J_URI,
  neo4j.auth.basic(process.env.NEO4J_USER, process.env.NEO4J_PASSWORD)
);

const typeDefs = fs
  .readFileSync(path.join(__dirname, "..", "..", "graphql", "schema.graphql"))
  .toString("utf-8");

const neoSchema = new Neo4jGraphQL({ typeDefs, driver });

neoSchema
  .getSchema()
  .then((schema) => {
    const server = new ApolloServer({ schema });
    return server.listen();
  })
  .then(({ url }) => {
    console.log(`Music recommendations GraphQL API ready at ${url}`);
  })
  .catch((error) => {
    console.error("Could not start the GraphQL API:", error);
    process.exitCode = 1;
  });
