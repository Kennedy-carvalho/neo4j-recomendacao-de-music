# pip3 install neo4j-driver
# python3 example.py

from neo4j import GraphDatabase, basic_auth

driver = GraphDatabase.driver(
  "neo4j://<HOST>:<BOLTPORT>",
  auth=basic_auth("<USERNAME>", "<PASSWORD>"))

cypher_query = '''
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
'''

with driver.session(database="neo4j") as session:
  results = session.read_transaction(
    lambda tx: tx.run(cypher_query,
                      userId="b80344d063b5ccb3212f76538f3d9e43d87dca9e").data())
  for record in results:
    print(record['recommendation'])

driver.close()
