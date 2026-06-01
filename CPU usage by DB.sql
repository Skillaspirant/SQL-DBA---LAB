

--Get CPU utilization by database (Query 1) (CPU Usage by Database)
WITH DB_CPU_Stats
AS
(SELECT pa.DatabaseID, DB_Name(pa.DatabaseID) AS [Database Name],
sum(qs.total_worker_time/1000) as [cpu_time_ms]
from sys.dm_exec_query_stats as qs with (nolock)
CROSS APPLY (SELECT CONVERT (int, value) AS [DatabaseID]
FROM sys.dm_exec_plan_attributes(qs.plan_handle)
WHERE attribute = N'dbid') AS pa
GROUP BY DatabaseID)
SELECT ROW_NUMBER()OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPU Rank], 
[Database Name], [CPU_Time_Ms] AS [CPU Time (ms)],
CAST ([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL (5, 2)) AS [CPU Percent]
FROM DB_CPU_Stats
WHERE DatabaseID <> 32767 -- ResourceDB
AND NOT [Database Name] IS NULL
ORDER BY [CPU Rank] OPTION (RECOMPILE);
-- Helps determine which database is using the most CPU resources on the instance
-- Note: This only reflects CPU usage from the currently cached query plans