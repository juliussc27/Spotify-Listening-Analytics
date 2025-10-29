create table streaming_history (
endTime TIMESTAMP,
artistName VARCHAR(200),
trackName VARCHAR(200),
msPlayed INT);

select * from streaming_history;
insert into streaming_history (endTime, artistName, trackName, msPlayed)
select * from streaminghistory_music_0;
insert into streaming_history (endTime, artistName, trackName, msPlayed)
select * from streaminghistory_music_1;
insert into streaming_history (endTime, artistName, trackName, msPlayed)
select * from streaminghistory_music_2;
insert into streaming_history (endTime, artistName, trackName, msPlayed)
select * from streaminghistory_music_3;

select * from streaming_history;

#Top and Bottom Listened Songs
(select * from streaming_history
order by endTime asc
limit 1)
union 
(select * from streaming_history
order by endTime desc
limit 1)
;

#Top 10 Artists of the Year, by Minutes Played
select artistName, sum(msPlayed) / 60000 AS minsPlayed
from streaming_history
group by artistName
order by totalMinutes desc
limit 10;

#Top 10 Tracks of the Year, by Minutes Played
select artistName, trackName, sum(msPlayed) / 60000 AS minsPlayed
from streaming_history
group by trackName, artistName
order by totalMinutes desc
limit 10;

#Top 10 Tracks of the Year, by Times Listened
select artistName, trackName, count(trackName) from streaming_history
group by trackName, artistName
order by count(trackName) desc;

#No. of Distinct Tracks Listened To
select count(distinct(trackName)) as distTracks 
from streaming_history;

#No. of Distinct Artists Listened To
select count(distinct(artistName)) as distArtists 
from streaming_history;

#Monthly Listening Time
select date_format(endTime, '%y-%m') as month, sum(msPlayed) / 3600000 as hrsPlayed
from streaming_history
group by month
order by month;

#Listening Time by Day of the Week
select date_format(endTime, '%W') as day_of_week, sum(msPlayed) / 60000 AS minsPlayed
from streaming_history
group by day_of_week
order by day_of_week;

#Listening Times at Different Times of the Day
select date_format(endTime, '%H') as hours, sum(msPlayed) / 60000 AS minsPlayed
from streaming_history
group by hours
order by minsPlayed desc;

#Average Hourly Listening Time
select date_format(endTime, '%H') as hours, sum(msPlayed) / 60000 AS avgMinsPlayed,
round(
(sum(msPlayed) / 60000) 
/ (select sum(msPlayed) / 60000 from streaming_history)
* 100, 2
) as percentage_of_total
from streaming_history
group by hours
order by percentage_of_total desc;

#Cumulative Total Over Time
select date(endTime) as dayDate, sum(msPlayed) / 60000 as minutes_today, 
sum(sum(msPlayed) / 60000) over (order by date(endTime)) as running_minutes_total
from streaming_history
group by dayDate
order by dayDate;

#Month-by-Month Comparison
with monthly as(
    select date_format(endTime, '%y-%m') as month, sum(msPlayed) / 60000 as minsPlayed
    from streaming_history
    group by month)
select month, minsPlayed,
lag(minsPlayed) over (order by month) as previous_month,
(minsPlayed - lag(minsPlayed) over (order by month))
/ nullif(lag(minsPlayed) over (order by month), 0) as monthly_change
from monthly
order by month;

#Concentration Metric of Top 10 Tracks
with ranked as (
    select trackName, sum(msPlayed) / 60000 as minsPlayed,
    row_number() over (order by sum(msPlayed) desc) as rnk
    from streaming_history
    group by trackName)
select sum(case when rnk <= 10 then minsPlayed end)
/ sum(minsPlayed) * 100 as top10_percent
from ranked;
    
#Concentration Metic on Top 10 Tracks Individually
with ranked as (
    select trackName, sum(msPlayed) / 60000 as minsPlayed,
    row_number() over (order by sum(msPlayed) desc) as rnk
    from streaming_history
    group by trackName)
select trackName, minsPlayed,
round(minsPlayed * 100 / (select sum(minsPlayed) from ranked), 2) as percent_of_total
from ranked
where rnk <= 10
order by minsPlayed desc;

select date_format(endTime, '%Y-%m-%d') as day, sum(msPlayed) / 60000 as minsPlayed
from streaming_history
group by day
order by day;