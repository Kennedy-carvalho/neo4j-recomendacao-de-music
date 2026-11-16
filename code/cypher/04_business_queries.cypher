// Set this parameter before running the personalized recommendation query.
:param userId => 'b80344d063b5ccb3212f76538f3d9e43d87dca9e';

// Collaborative filtering: find tracks enjoyed by peers with overlapping listening history.
MATCH (user:User {userId: $userId})-[:LISTENED_TO]->(seed:Track)
      <-[:LISTENED_TO]-(peer:User)-[peerListen:LISTENED_TO]->(recommended:Track)
WHERE peer <> user
  AND recommended.name IS NOT NULL
  AND NOT EXISTS { MATCH (user)-[:LISTENED_TO]->(recommended) }
WITH peer, recommended, count(DISTINCT seed) AS commonTracks,
     max(peerListen.playcount) AS peerPlays
WITH recommended, sum(commonTracks) AS score,
     count(DISTINCT peer) AS similarListeners,
     sum(peerPlays) AS supportingPlays
RETURN recommended.name + ' - ' +
       coalesce(recommended.artist, 'Artista desconhecido') AS recommendation,
       score, similarListeners, supportingPlays
ORDER BY score DESC, similarListeners DESC, supportingPlays DESC
LIMIT 20;

// Content-based filtering: recommend tracks sharing tags with a selected track.
MATCH (source:Track {trackId: 'TRIOREW128F424EAF0'})-[:HAS_TAG]->(tag:Tag)
      <-[:HAS_TAG]-(recommended:Track)
WHERE recommended <> source AND recommended.name IS NOT NULL
WITH recommended, count(DISTINCT tag) AS commonTags
RETURN recommended.name AS track, recommended.artist AS artist,
       commonTags
ORDER BY commonTags DESC, track
LIMIT 20;

// Business question: most played tracks and number of distinct listeners.
MATCH (user:User)-[listening:LISTENED_TO]->(track:Track)
WHERE track.name IS NOT NULL
WITH track, sum(coalesce(listening.playcount, 0)) AS totalPlays,
     count(DISTINCT user) AS listeners
RETURN track.name AS track, track.artist AS artist,
       totalPlays, listeners
ORDER BY totalPlays DESC
LIMIT 20;
