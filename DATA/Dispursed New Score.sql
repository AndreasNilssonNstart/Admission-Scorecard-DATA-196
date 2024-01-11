WITH maxScore AS (
    SELECT 
        applicationid,
        MAX(create_date) AS maxdate,
        NewPDScore
    FROM [Reporting-db].[nystart].[UCS1]
    WHERE 
        (NewPDScore IS NOT NULL OR NewPDScore <> 'None')  
        AND create_date >= '2023-11-01' AND applicationid <>'None' 
    GROUP BY applicationid, NewPDScore
)


SELECT 
      a.[AccountNumber]
      ,a.DisbursedDate

      ,u.[NewPDScore]
      

  FROM [Reporting-db].[nystart].[Applications] as a 

    left join maxScore as u on a.applicationid = u.applicationid
  

  where a.Disbursed = 1 and a.ReceivedDate >= '2023-11-01' 

  and u.NewPDScore is not null  ;
  
