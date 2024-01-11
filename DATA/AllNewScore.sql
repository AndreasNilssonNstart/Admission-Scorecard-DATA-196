SELECT  distinct --TOP (1000)

      [AccountNumber]
,ReceivedDate
      ,[PDScoreNew]
  FROM [Reporting-db].[nystart].[Applications] where 
  
   PDScoreNew is not null and 
   ReceivedDate >= '2023-11-01'
  
