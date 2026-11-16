LOAD CSV WITH HEADERS FROM 'file:///listening_history.csv' AS row
CALL {
  WITH row
  WITH row
  WHERE row.track_id IS NOT NULL AND row.track_id <> ''
    AND row.user_id IS NOT NULL AND row.user_id <> ''
  MERGE (user:User {userId: row.user_id})
  MERGE (track:Track {trackId: row.track_id})
  MERGE (user)-[listening:LISTENED_TO]->(track)
  SET listening.playcount = CASE
    WHEN row.playcount = '' THEN null
    ELSE toInteger(row.playcount)
  END
} IN TRANSACTIONS OF 10000 ROWS;
