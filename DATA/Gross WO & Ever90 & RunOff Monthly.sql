IF OBJECT_ID('tempdb..#frozen') is not null
DROP TABLE #frozen;
with frozen as (
select AccountNumber as 'loanaccountnumber'
,MIN(case when CollectionDate<>'' then CollectionDate else null end) as CollectionDate
,MIN(case when FrozenDate <>'' then FrozenDate else null end) as FrozenDate
,MIN(case when WODate<>'' then WOdate else null end) as WODate
,MIN(case when DefaultDate<>'' then DefaultDate else null end) as DefaultDate
from [reporting-db].[nystart].[LoanPortfolio]
where 1=1
--and AccountNumber='7839954'
group by AccountNumber
),

frozen2 as (
select * 
,case when FrozenDate<='2018-01-01' then FrozenDate
when DefaultDate >='2018-01-01'then DefaultDate
when CollectionDate >='2018-01-01'then CollectionDate
when WODate >='2022-12-01'then WODate
else '' end as 'SendToCollection'

from frozen ),

MOB_PLUS_90 AS (
SELECT DISTINCT 
    m.[AccountNumber],
    m.mob,
    m.DisbursedDate,
    m.SnapshotDate,
    m.Ever90,
    m.CurrentAmount,
    m.IsOpen,

    f.SendToCollection,
    
CASE 
    WHEN SendToCollection = '1900-01-01' THEN 0
    WHEN Convert(date, f.SendToCollection) <= Convert(date, m.SnapshotDate) THEN 1
    ELSE 0 
END AS WO_flag

FROM 
    [Reporting-db].[nystart].[LoanPortfolioMonthly] AS m
LEFT JOIN 
    frozen2 AS f ON m.AccountNumber = f.loanaccountnumber

    WHERE IsMonthEnd =1 and DisbursedDate >= '2018-01-01' ),


Initall_Amount as (  Select max(CurrentAmount) as maxAmount , AccountNumber from MOB_PLUS_90 GROUP BY AccountNumber),


Collection_accounts as (  Select distinct  AccountNumber from MOB_PLUS_90  where WO_flag = 1 GROUP BY AccountNumber),


-- THIS ONE IS DONE TO ONLY TAKE THE RUN OF FROM ACTIVE ACCOUNTS SINCE THAT IS WHAT IS ABLE TO GET BACK PIT WHEN MULTIPLYING GWO % WITH THE EAD
MOB_PLUS_90_ADJUSTED as (
    
    
SELECT 
    m.*,
    CASE 
        WHEN i.maxAmount > 0 AND CAST(c.AccountNumber AS INT) > 0 THEN 0 
        ELSE i.maxAmount 
    END AS MaxAmountAdjusted, -- Renamed for clarity
    CASE 
        WHEN m.CurrentAmount > 0 AND CAST(c.AccountNumber AS INT) > 0 THEN 0 
        ELSE m.CurrentAmount 
    END AS CurrentAmountAdjusted -- Renamed for clarity

FROM MOB_PLUS_90 AS m 

    LEFT JOIN Collection_accounts AS c ON m.AccountNumber = c.AccountNumber
    
    INNER JOIN Initall_Amount AS i ON m.AccountNumber = i.AccountNumber

),


RUN_OFF as ( SELECT 
        *, 
        CASE 
            WHEN MaxAmountAdjusted IS NULL OR MaxAmountAdjusted = 0 THEN 0 
            ELSE CurrentAmountAdjusted / NULLIF(MaxAmountAdjusted, 0) 
        END AS run_off

    FROM MOB_PLUS_90_ADJUSTED  )


SELECT * from RUN_OFF order by AccountNumber ,mob