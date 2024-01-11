WITH DEL90 AS (
    SELECT DISTINCT AccountNumber, Ever90, DisbursedDate
    FROM [Reporting-db].[nystart].[LoanPortfolioMonthly]
    WHERE mob = 12 AND IsMonthEnd = 1
),

snn_score_both AS (
    SELECT

    
        A.AccountNumber,
        CBR.*
    FROM [Reporting-db].[nystart].[Applications] as A
    INNER JOIN [Reporting-db].[nystart].[CreditReportsBase] CBR ON CBR.SSN = A.SSN
    WHERE
        A.HasCoapp = 1  
        AND (DATEDIFF(day, A.ReceivedDate, CBR.Date) BETWEEN -30 AND ISNULL(DATEDIFF(day, A.ReceivedDate, A.DisbursedDate), 60))
),

max_per_acc AS (
    SELECT 
        AccountNumber, 
        max(RiskPrognos) as MaxUCScore
    FROM snn_score_both  
    GROUP BY AccountNumber
),

numbered_scores AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER(PARTITION BY s.AccountNumber ORDER BY s.RiskPrognos DESC) AS RowNum
    FROM snn_score_both s
    INNER JOIN max_per_acc m ON m.AccountNumber = s.AccountNumber AND m.MaxUCScore = s.RiskPrognos
)

SELECT

--distinct d.AccountNumber


    s.*


FROM numbered_scores s

inner join DEL90 as d  on d.AccountNumber = s.AccountNumber


WHERE s.RowNum = 1 and d.Ever90 = 1  --AND s.AccountNumber = 7739188
