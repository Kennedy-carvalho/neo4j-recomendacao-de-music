// install dotnet core on your system
// dotnet new console -o .
// dotnet add package Neo4j.Driver
// paste in this code into Program.cs
// dotnet run

using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Neo4j.Driver;
  
namespace dotnet {
  class Example {
  static async Task Main() {
    var driver = GraphDatabase.Driver("neo4j://<HOST>:<BOLTPORT>", 
                    AuthTokens.Basic("<USERNAME>", "<PASSWORD>"));

    var cypherQuery =
      @"
      MATCH (u:User {userId:$userId})-[:LISTENED_TO]->(seed:Track)
            <-[:LISTENED_TO]-(peer:User)-[peerListen:LISTENED_TO]->(rec:Track)
      WHERE peer <> u
        AND rec.name IS NOT NULL
        AND NOT EXISTS { MATCH (u)-[:LISTENED_TO]->(rec) }
      WITH peer, rec, count(DISTINCT seed) AS commonTracks,
           max(peerListen.playcount) AS peerPlays
      WITH rec, sum(commonTracks) AS score,
           count(DISTINCT peer) AS similarListeners,
           sum(peerPlays) AS supportingPlays
      RETURN rec.name + ' - ' + coalesce(rec.artist, 'Artista desconhecido') AS recommendation
      ORDER BY score DESC, similarListeners DESC, supportingPlays DESC
      LIMIT 20
      ";

    var session = driver.AsyncSession(o => o.WithDatabase("neo4j"));
    var result = await session.ReadTransactionAsync(async tx => {
      var r = await tx.RunAsync(cypherQuery, 
              new { userId="b80344d063b5ccb3212f76538f3d9e43d87dca9e"});
      return await r.ToListAsync();
    });

    await session?.CloseAsync();
    foreach (var row in result)
      Console.WriteLine(row["recommendation"].As<string>());
	  
    }
  }
}