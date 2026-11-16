LOAD CSV WITH HEADERS FROM 'file:///music_info.csv' AS row
CALL {
  WITH row
  WITH row
  WHERE row.track_id IS NOT NULL AND row.track_id <> ''
  MERGE (track:Track {trackId: row.track_id})
  SET track.name = CASE WHEN row.name = '' THEN null ELSE row.name END,
      track.artist = CASE WHEN row.artist = '' THEN null ELSE row.artist END,
      track.spotifyId = CASE WHEN row.spotify_id = '' THEN null ELSE row.spotify_id END,
      track.previewUrl = CASE WHEN row.spotify_preview_url = '' THEN null ELSE row.spotify_preview_url END,
      track.genre = CASE WHEN row.genre = '' THEN null ELSE row.genre END,
      track.year = CASE WHEN row.year = '' THEN null ELSE toInteger(row.year) END,
      track.durationMs = CASE WHEN row.duration_ms = '' THEN null ELSE toInteger(row.duration_ms) END,
      track.danceability = CASE WHEN row.danceability = '' THEN null ELSE toFloat(row.danceability) END,
      track.energy = CASE WHEN row.energy = '' THEN null ELSE toFloat(row.energy) END,
      track.musicalKey = CASE WHEN row.key = '' THEN null ELSE toInteger(row.key) END,
      track.loudness = CASE WHEN row.loudness = '' THEN null ELSE toFloat(row.loudness) END,
      track.mode = CASE WHEN row.mode = '' THEN null ELSE toInteger(row.mode) END,
      track.speechiness = CASE WHEN row.speechiness = '' THEN null ELSE toFloat(row.speechiness) END,
      track.acousticness = CASE WHEN row.acousticness = '' THEN null ELSE toFloat(row.acousticness) END,
      track.instrumentalness = CASE WHEN row.instrumentalness = '' THEN null ELSE toFloat(row.instrumentalness) END,
      track.liveness = CASE WHEN row.liveness = '' THEN null ELSE toFloat(row.liveness) END,
      track.valence = CASE WHEN row.valence = '' THEN null ELSE toFloat(row.valence) END,
      track.tempo = CASE WHEN row.tempo = '' THEN null ELSE toFloat(row.tempo) END,
      track.timeSignature = CASE WHEN row.time_signature = '' THEN null ELSE toInteger(row.time_signature) END
  FOREACH (_ IN CASE WHEN row.artist IS NULL OR trim(row.artist) = '' THEN [] ELSE [1] END |
    MERGE (artist:Artist {name: trim(row.artist)})
    MERGE (track)-[:PERFORMED_BY]->(artist)
  )
  FOREACH (_ IN CASE WHEN row.genre IS NULL OR trim(row.genre) = '' THEN [] ELSE [1] END |
    MERGE (genre:Genre {name: trim(row.genre)})
    MERGE (track)-[:IN_GENRE]->(genre)
  )
  WITH track, row
  UNWIND CASE
    WHEN row.tags IS NULL OR trim(row.tags) = '' THEN []
    ELSE split(row.tags, ',')
  END AS rawTag
  WITH track, trim(rawTag) AS tagName
  WHERE tagName <> ''
  MERGE (tag:Tag {name: tagName})
  MERGE (track)-[:HAS_TAG]->(tag)
} IN TRANSACTIONS OF 1000 ROWS;
