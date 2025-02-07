CREATE TABLE netflix (
	show_id VARCHAR(7) PRIMARY KEY,     -- Unique identifier for each title.
	type VARCHAR(10),                   -- Specifies whether the title is a "Movie" or a "TV Show."
	title VARCHAR(200),                 -- Name of the movie or TV show.
	director VARCHAR(300),              -- Name(s) of the director(s), if available.
	casting VARCHAR(1000),              -- List of main actors in the title.
	country VARCHAR(200),               -- Country where the title was produced.
	date_added DATE,                    -- Date when the title was added to Netflix.
	release_year INT,                   -- Year the title was originally released.
	rating VARCHAR(10),                 -- Content rating (e.g., PG-13, TV-MA).
	duration VARCHAR(10),               -- Duration of the movie or number of seasons for TV shows.
	listed_in VARCHAR (100),            -- Categories/genres the title belongs to.
	description VARCHAR(600)            -- Brief synopsis of the title.
);