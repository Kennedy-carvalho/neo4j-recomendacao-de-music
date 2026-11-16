CREATE CONSTRAINT user_id_unique IF NOT EXISTS
FOR (user:User) REQUIRE user.userId IS UNIQUE;

CREATE CONSTRAINT track_id_unique IF NOT EXISTS
FOR (track:Track) REQUIRE track.trackId IS UNIQUE;

CREATE CONSTRAINT artist_name_unique IF NOT EXISTS
FOR (artist:Artist) REQUIRE artist.name IS UNIQUE;

CREATE CONSTRAINT genre_name_unique IF NOT EXISTS
FOR (genre:Genre) REQUIRE genre.name IS UNIQUE;

CREATE CONSTRAINT tag_name_unique IF NOT EXISTS
FOR (tag:Tag) REQUIRE tag.name IS UNIQUE;
