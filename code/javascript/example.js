// npm install --save neo4j-driver
// node example.js
const neo4j = require('neo4j-driver');
const driver = neo4j.driver('neo4j://<HOST>:<BOLTPORT>',
                  neo4j.auth.basic('<USERNAME>', '<PASSWORD>'), 
                  {/* encrypted: 'ENCRYPTION_OFF' */});

const query =
  `
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
  `;

const params = {"userId": "b80344d063b5ccb3212f76538f3d9e43d87dca9e"};

const session = driver.session({database:"neo4j"});

session.run(query, params)
  .then((result) => {
    result.records.forEach((record) => {
        console.log(record.get('recommendation'));
    });
    session.close();
    driver.close();
  })
  .catch((error) => {
    console.error(error);
  });
