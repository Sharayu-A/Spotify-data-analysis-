-- ********   SPOTIFY PROJECT   ********


-- made database -- problem with ' operator while importing -- some time duration 0 
-- likes comments not in whole no -- sql server connection problem
-- SHOW VARIABLES LIKE 'secure_file_priv'; problem with file location while importing 

use spotifyproject;

-- Create table
DROP TABLE IF EXISTS spotify;

CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);



SHOW VARIABLES LIKE 'secure_file_priv';


LOAD DATA INFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\spotify_dataset.csv'
INTO TABLE spotify 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;  -- if your CSV has a header row

select * from spotify;

RENAME TABLE spotify2 TO spotify;

-- distinct artist 
select count(distinct artist) from spotify;

select distinct Album from spotify;

select max(duration_min) from spotify;

select min(duration_min) from spotify;    -- not possible 0 time 

select * from spotify where Duration_min  = 0;

DELETE from spotify 
where Duration_min=0;


-- ------------------------------------------------------------------------------------------------

/* Easy Level
Retrieve the names of all tracks that have more than 1 billion streams.
List all albums along with their respective artists.
Get the total number of comments for tracks where licensed = TRUE.
Find all tracks that belong to the album type single.
Count the total number of tracks by each artist. */

-- -------------------------------------------------------------------------------------------------

select track from spotify 
where Stream >= 1000000000; 

select count(track) from spotify 
where Stream >= 1000000000 ;

select count(distinct Album) from spotify;

select distinct album , artist  from spotify;

select comments from spotify
 where Licensed = 'true';
 
select sum(comments)
from spotify
where Licensed = 'true';


select track from spotify 
where Album_type='single';  -- ilike

-- select distinct track , artist  from spotify
-- group by artist ;

select 
      artist,                   -- 1
      count(*) as total_songs   -- 2
from spotify
 group by Artist
 order by 2 desc;
 
 
 -- select * from spotify where artist = '' ;
 -- -------------------------------------------------------------------------------
/* Medium Level

Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.*/
 
 -- ---------------------------------------------------------------------------
 select * from spotify;
 
select 
      album,                                   -- 1
      avg(Danceability) as avg_dancibility     -- 2
from spotify 
group by 1 
order by 2;

select 
     track,
     max(energy)
from spotify
group by 1
order by 2 desc 
limit 5

select 
    track,
     sum(likes) as tatal_likes,
    sum(views) as total_view
from spotify 
where official_video = 'true' 
group by 1
order by 3 desc ;

select 
     track,
     sum(views) as toatl_views_by_album
from spotify 
group by 1
order by 2 desc;



select * from 
-- make it sub query so it can be used as a seprate temp table
(select 
     track,
     coalesce(SUM(CASE WHEN most_playedon = 'youtube' THEN stream END ),0) as streamed_on_yt ,
     coalesce(SUM(CASE WHEN most_playedon = 'spotify' THEN stream END ),0) as streamed_on_spotify
from spotify
group by 1 ) as t1
where streamed_on_yt < streamed_on_spotify and streamed_on_yt <> 0;


/* Advanced Level
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC
Find tracks where the energy-to-liveness ratio is greater than 1.2.
Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

-- Find the top 3 most-viewed tracks for each artist using window functions.
USE spotifyproject;

select * from spotify2 ;

-- SQL requires that every column in the SELECT clause must be: Either in the GROUP BY list, or  An aggregate function (SUM(), COUNT(), etc.).


-- each artist and total view for each track
-- track with highest view for each artist (we need top)
-- dense rank 
-- cte and filder rank <=3
/* with ranking_artist
as
(select 
      artist,
      track,
      SUM(views) as total_views,
      dense_rank() over(partition by artist order by sum(view) desc ) as rnk
from spotify
group by 1 , 2 
order by 1, 3 desc ; ) 
select * from ranking_artist
WHERE rank <=3 ;*/


WITH ranking_artist AS (
    SELECT 
        artist,
        track,
        SUM(views) AS total_views,
        DENSE_RANK() OVER (PARTITION BY artist ORDER BY SUM(views) DESC) AS rnk
    FROM spotify
    GROUP BY artist, track
)
SELECT *
FROM ranking_artist
WHERE rnk <= 3
ORDER BY artist, total_views DESC;




-- Write a query to find tracks where the liveness score is above the average.

select avg(liveness) from spotify ; -- 0.19

select * from spotify 
where liveness > 0.19 ;

select 
    track,
    artist,
    liveness
 from spotify 
where liveness > ( select avg(liveness) from spotify );


-- Use a WITH clause to calculate the difference between the highest and lowest 
-- energy values for tracks in each album.

WITH cte
as
(select 
    album,
    max(energy) as highest_energy,
    min(energy) as lowest_energy
from spotify
group by 1
)
select 
    album,
    highest_energy - lowest_energy as energy_diff
from cte
order by 2 desc




