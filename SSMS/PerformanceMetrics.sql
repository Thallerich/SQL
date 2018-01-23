/*=============================================
  File: SQL_Server_2014_metrics.sql
 
  Author: Thomas LaRock, http://thomaslarock.com/contact-me/
  http://thomaslarock.com/2014/06/performance-metrics-for-sql-server-2014/
 
  Summary: Here is my list of metrics that I find myself frequently using for 
troubleshooting SQL Server performance issues. They help me get insight quickly 
into some of the deep recesses of SQL Server so that I can easily corroborate 
with some standard Perfmon counters and DMVs in order to troubleshoot issues 
for customers and clients. You should incorporate these into whatever monitoring 
solution you are using for trend analysis. By looking at these metrics in the 
first few minutes of troubleshooting they will help you save time.
 
These queries are are meant to serve as a guide only; just because I say "100" 
and your system shows "101" doesn’t mean the sky is falling. Baseline and trend 
analysis is key here. Monitor frequently, look for spikes, and above all Don’t Panic.
 
  Date: June 5th, 2014
 
  SQL Server Versions: SQL2012, SQL2014
 
  You may alter this code for your own purposes. You may republish
  altered code as long as you give due credit. 
 
  THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY
  OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
  LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR
  FITNESS FOR A PARTICULAR PURPOSE.
 
=============================================*/
 
/* =============================================
 
Signal Waits 
 
The value you want returned here is for no more than 20-25% of your total waits to be signal waits. If you are consistently seeing numbers greater than 20% then you are having internal CPU pressure. You can remedy the situation by reducing the number of sessions (not always likely), increasing the number of available CPUs (also not likely), or reducing the amount of time the queries need to execute (often very likely, and sometimes easily done).
=============================================*/
 
SELECT (100.0 * SUM(signal_wait_time_ms)/SUM (wait_time_ms)) AS [SignalWaitPct]
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT',
'BROKER_TO_FLUSH', 'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT',
'DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT',
'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
'BROKER_RECEIVE_WAITFOR', 'ONDEMAND_TASK_QUEUE', 'DBMIRROR_EVENTS_QUEUE',
'DBMIRRORING_CMD', 'BROKER_TRANSMITTER', 'SQLTRACE_WAIT_ENTRIES',
'SLEEP_BPOOL_FLUSH', 'SP_SERVER_DIAGNOSTICS_SLEEP', 'HADR_FILESTREAM_IOMGR_IOCOMPLETION')
AND wait_time_ms <> 0
 
 
 
/*============================================= 
 
SQL compilation percentage 
 
The recommended percentage for compilations should be roughly 10% of the total number of batch requests.
*/
 
SELECT 1.0*cntr_value /
(SELECT 1.0*cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Batch Requests/sec')
AS [SQLCompilationPct]
FROM sys.dm_os_performance_counters
WHERE counter_name = 'SQL Compilations/sec'
 
/*
SQL re-compilations should be roughly 1% of the total number of batch requests.
*/
 
SELECT 1.0*cntr_value /
(SELECT 1.0*cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Batch Requests/sec')
AS [SQLReCompilationPct]
FROM sys.dm_os_performance_counters
WHERE counter_name = 'SQL Re-Compilations/sec'
 
 
/*=============================================*/
 
 
 
/*=============================================
 
Page lookups percentage
 
What I want to see here is a value that is less than 100 on average, but it really depends upon the nature of your instance. Measure over a period of time and look for spikes.
=============================================*/
 
SELECT 1.0*cntr_value /
(SELECT 1.0*cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Batch Requests/sec') 
AS [PageLookupPct]
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page lookups/sec'
 
 
 
/*=============================================
 
Page splits percentage
 
Monitoring for just the number of page splits by itself isn't very reliable, as the counter includes any new page allocations as well as page splits due to fragmentation. So I like to compare the number of page splits to the number of batch requests. The number I look for here is roughly 20 page splits/sec for every 100 batch requests.
=============================================*/
 
SELECT 1.0*cntr_value /
(SELECT 1.0*cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Batch Requests/sec') 
AS [PageSplitPct]
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Page splits/sec'
 
 
 
/*=============================================
 
Average task counts
 
High Avg Task Counts (>10) are often caused by blocking/deadlocking or other resource contention
High Avg Runnable Task Counts (>1) are a good sign of CPU pressure
High Avg Pending DiskIO Counts (>1) are a sign of disk pressure
=============================================*/
 
SELECT AVG(current_tasks_count) AS [Avg Task Count],
AVG(runnable_tasks_count) AS [Avg Runnable Task Count],
AVG(pending_disk_io_count) AS [Avg Pending DiskIO Count]
FROM sys.dm_os_schedulers WITH (NOLOCK)
WHERE scheduler_id < 255 OPTION (RECOMPILE)
 
 
 
/*=============================================
 
Buffer pool I/O rate
 
I usually look for rates around 20MB/sec as a baseline. If there is a spike upward from there then you are 
having memory pressure (pressure that might otherwise fail to be seen if you only examine the page life expectancy counter).
=============================================*/
 
SELECT (1.0*cntr_value/128) /
(SELECT 1.0*cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name like '%Buffer Manager%'
AND lower(counter_name) = 'Page life expectancy')
AS [BufferPoolRate]
FROM sys.dm_os_performance_counters
WHERE object_name like '%Buffer Manager%'
AND counter_name = 'database pages'
 
 
 
/*=============================================
 
Memory grants pending
 
This counter helps me understand if I am seeing internal memory pressure. Ideally this value should be as close to 0 as possible.
Sustained periods of non-zero values are worth investigating.
=============================================*/
 
SELECT cntr_value 
AS [MemGrantPending]                                                                                                       
FROM sys.dm_os_performance_counters 
WHERE counter_name = 'Memory Grants Pending'