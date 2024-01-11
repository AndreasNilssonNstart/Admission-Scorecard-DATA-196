-- Step 1: Get Max CBR.Date and Min UCScore for each AccountNumber

    
    
    
    -- DENNA FINNS MEN FÅR INTE MED just denna DATA I MIN SISTA 
    
    -- SELECT

    -- * 


    -- FROM [Reporting-db].[nystart].[CreditReportsBase] 
    
    -- where SSN = '6E699A2C109E3248B0CE67A9FFBEA9F4C92F6F1472BF00EDBC580469F137B6FD2CE14B49CF292C286828114E83970E19B069704B6A20F9E37E5E211D0D48E970'





WITH
-- SELECT
 MAXSCORE AS (


SELECT
    A.SSN,
    A.AccountNumber
    -- MAX(CBR.Date) as MaxDate,   -- Latest application (uncomment if needed)
    ,MAX(CBR.RiskPrognos) as MaxUCScore  -- HIGHEST RiskPrognos score
FROM 
    [Reporting-db].[nystart].[Applications] as A
INNER JOIN [Reporting-db].[nystart].[CreditReportsBase] CBR ON CBR.SSN = A.SSN
WHERE
    -- A.Status = 'DISBURSED' (uncomment if needed)
    A.HasCoapp = 1  
    AND (DATEDIFF(day, A.ReceivedDate, CBR.Date) BETWEEN -30 AND ISNULL(DATEDIFF(day, A.ReceivedDate, A.DisbursedDate), 60))
   
    --AND A.ApplicationID = 5005806


GROUP BY A.SSN ,A.AccountNumber


        
),

DEL90 AS (
    SELECT DISTINCT AccountNumber, Ever90, DisbursedDate
    FROM [Reporting-db].[nystart].[LoanPortfolioMonthly]
    WHERE mob = 12 AND IsMonthEnd = 1
),

DEL90_Applications_MaxDate AS (
    SELECT 
        D.AccountNumber,
        D.Ever90,

        A.[SSN] as SSN_A,
        A.[IsMainApplicant],
        --A.[ApplicantNo],
        A.[HasCoapp],      

        A.[ReceivedDate],
        A.[DisbursedDate],
        A.[Amount],
        A.[UCScore],
        A.[PaymentRemarks],
        A.[CreditOfficer],
        A.[SalesChannel],
        A.[Product],
        A.[Migrated],
        A.[BrokerName],
        A.[OriginalSalesChannel],
        A.[BirthDate],
        A.[Bookingtype],
        A.[MaritalStatus],
        A.[EmploymentType],
        A.[HousingType],
        A.[MonthlySalary],   
        A.[Referer],
        A.[Campaign],
        A.[SourceMedium],
        A.[Keyword],
        A.[NystartChannel],
        A.[PNReceivedDate],
        A.[NumberOfApplicants],
        A.[Gender],
        A.[CoappSameAddress],
        A.[Kronofogden],
        A.[CreditCardsNo],
        A.[InstallmentLoansNo],
        A.[UnsecuredLoansNo],
        A.[LastPaymentRemarkDate] as LastPaymentRemarkDate1,
        A.[TotalLoans],
        A.[NystartBalance],
        A.[TotalUnsecuredLoans]
    FROM 
        [Reporting-db].[nystart].[Applications] as A
    INNER JOIN DEL90 D ON A.AccountNumber = D.AccountNumber AND A.DisbursedDate = D.DisbursedDate
    WHERE A.IsMainApplicant = 0
),

CO AS (
    SELECT 
        ROW_NUMBER() OVER (PARTITION BY DA.AccountNumber, DA.UCScore ORDER BY CBR.Date DESC) as RowNumber,
        DA.*, 
        CBR.*
    FROM DEL90_Applications_MaxDate as DA

    

    LEFT JOIN [Reporting-db].[nystart].[CreditReportsBase] CBR ON CBR.SSN = DA.SSN_A  
    AND (DATEDIFF(day, DA.ReceivedDate, CBR.Date) BETWEEN -30 AND ISNULL(DATEDIFF(day, DA.ReceivedDate, DA.DisbursedDate), 60)) 
) 

SELECT *    

--distinct c.AccountNumber

FROM CO as c

inner JOIN MAXSCORE MS ON c.SSN = MS.SSN  AND c.UCScore = MS.MAXUCScore

WHERE RowNumber = 1 AND Ever90 = 1 ;
