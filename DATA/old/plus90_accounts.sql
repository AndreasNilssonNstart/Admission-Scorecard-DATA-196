SELECT 
      [AccountNumber]
      
FROM [Reporting-db].[nystart].[LoanPortfolioMonthly]
WHERE Ever90 = 1 
      AND [SnapshotDate] < DATEADD(MONTH, -12, GETDATE())

group BY AccountNumber;



