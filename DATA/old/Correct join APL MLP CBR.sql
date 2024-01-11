


WITH DEL90 AS (
    SELECT DISTINCT [AccountNumber] ,Ever90 ,DisbursedDate ,SnapshotDate
    
    FROM [Reporting-db].[nystart].[LoanPortfolioMonthly]
    WHERE mob = 12 and IsMonthEnd =1  --[SnapshotDate] <= DATEADD(MONTH, -12, GETDATE())   -- ScoreCard needs 12 Month on book
),   -- Expected 568 rows -- date of analysis 2023-08-22




DEL90_Applications_MaxDate AS (
    SELECT 
        D.AccountNumber,
        Ever90,
        A.SSN,
        A.DisbursedDate,
        A.Status, 
        ReceivedDate
    FROM 
        [Reporting-db].[nystart].[Applications] as A
    INNER JOIN DEL90 D ON A.AccountNumber = D.AccountNumber  and A.DisbursedDate =  D.DisbursedDate

    where IsMainApplicant = 1

    -- GROUP BY D.AccountNumber , A.SSN, A.DisbursedDate ,A.Status

    
),   -- Expected 568 rows --

 alla AS (

SELECT row_number() over (partition by AccountNumber,DA.SSN order by CBR.Date desc) as RowNumber

-- additional features


   ,CBR.ssn     -- CBR.SSN  --DA.Status, CBR.*


FROM DEL90_Applications_MaxDate  as DA


LEFT JOIN [Reporting-db].[nystart].[CreditReportsBase] CBR ON CBR.SSN = DA.SSN  and (DATEDIFF(day, DA.ReceivedDate, CBR.Date) BETWEEN -30 AND ISNULL(DATEDIFF(day, DA.ReceivedDate, DA.DisbursedDate), 60)) 



where  DA.Ever90 = 1  

) 

select * from alla 

where RowNumber = 1

 --and DA.Status != 'DISBURSED'--     and DA.Status = 'DISBURSED'   -- this is 



  --  IF we take         where (DATEDIFF(day, DA.ReceivedDate, CBR.Date) BETWEEN -30 AND ISNULL(DATEDIFF(day, DA.ReceivedDate, DA.DisbursedDate), 60)) 
    -- Statement abouve we go from condition commented out we have 547
    -- With the logic we have 525







/*    


1. EVER ONLY WORKS

2. EVER and DISPURSED looses many accounts so something funny with dispursed column




WITH DEL90 AS (
    SELECT DISTINCT [AccountNumber] ,Ever90
    
    FROM [Reporting-db].[nystart].[LoanPortfolioMonthly]
    WHERE [SnapshotDate] < DATEADD(MONTH, -12, GETDATE())   -- ScoreCard needs 12 Month on book
),   -- Expected 1000 rows --




DEL90_Applications_MaxDate AS (
    SELECT 
        D.AccountNumber,
        max(D.Ever90) as Ever90,
        A.SSN,
        A.DisbursedDate,
        A.Status, 
        MAX(A.ReceivedDate) as MaxDate
    FROM 
        [Reporting-db].[nystart].[Applications] as A
    INNER JOIN DEL90 D ON A.AccountNumber = D.AccountNumber 

    --where A.Status = 'DISBURSED'

    GROUP BY D.AccountNumber , A.SSN, A.DisbursedDate ,A.Status

    
)   -- Expected 998 rows --

SELECT  CBR.*


FROM DEL90_Applications_MaxDate  as DA


LEFT JOIN [Reporting-db].[nystart].[CreditReportsBase] CBR ON CBR.SSN = DA.SSN AND CBR.Date = DA.MaxDate

where (DATEDIFF(day, DA.MaxDate, CBR.Date) BETWEEN -30 AND ISNULL(DATEDIFF(day, DA.MaxDate, DA.DisbursedDate), 60)) 

and DA.Ever90 = 1 --     and DA.Status = 'DISBURSED'   -- this is 


*/