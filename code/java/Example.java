// Add your the driver dependency to your pom.xml build.gradle etc.
// Java Driver Dependency: http://search.maven.org/#artifactdetails|org.neo4j.driver|neo4j-java-driver|4.0.1|jar
// Reactive Streams http://search.maven.org/#artifactdetails|org.reactivestreams|reactive-streams|1.0.3|jar
// download jars into current directory
// java -cp "*" Example.java

import org.neo4j.driver.*;
import static org.neo4j.driver.Values.parameters;

public class Example {

  public static void main(String...args) {

    Driver driver = GraphDatabase.driver("neo4j://<HOST>:<BOLTPORT>",
              AuthTokens.basic("<USERNAME>","<PASSWORD>"));

    try (Session session = driver.session(SessionConfig.forDatabase("neo4j"))) {

      String cypherQuery =
        "MATCH (u:User {userId:$userId})-[:LISTENED_TO]->(seed:Track)\n" +
        "      <-[:LISTENED_TO]-(peer:User)-[peerListen:LISTENED_TO]->(rec:Track)\n" +
        "WHERE peer <> u AND rec.name IS NOT NULL\n" +
        "  AND NOT EXISTS { MATCH (u)-[:LISTENED_TO]->(rec) }\n" +
        "WITH peer, rec, count(DISTINCT seed) AS commonTracks, max(peerListen.playcount) AS peerPlays\n" +
        "WITH rec, sum(commonTracks) AS score, count(DISTINCT peer) AS similarListeners, sum(peerPlays) AS supportingPlays\n" +
        "RETURN rec.name + ' - ' + coalesce(rec.artist, 'Artista desconhecido') AS recommendation\n" +
        "ORDER BY score DESC, similarListeners DESC, supportingPlays DESC LIMIT 20";

      var result = session.readTransaction(
        tx -> tx.run(cypherQuery, 
                parameters("userId","b80344d063b5ccb3212f76538f3d9e43d87dca9e"))
            .list());

      for (Record record : result) {
        System.out.println(record.get("recommendation").asString());
      }
    }
    driver.close();
  }
}


