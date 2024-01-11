

WITH



Application_ AS (
SELECT U.[applicationid] --TOP (1000) 
      --,U.[reference]
      --,U.[ssn]
      --,U.[degenerate_check_id]
      --,U.[applicant_key]
      ,U.[create_date]
      ,U.[reasoncodes]
      ,U.[sysdecgrpstd]
      ,U.[systemdecstd]
      ,U.[reasondescriptions] 
      ,U.[reasoncode1]
      ,U.[reasondescription1]
      ,U.[reasoncode2]
      ,U.[reasondescription2]
      ,U.[reasoncode3]
      ,U.[reasondescription3]
      ,U.[reasoncode4]
      ,U.[reasondescription4]
      ,U.[reasoncode5]
      ,U.[reasondescription5]
      ,U.[calculatedriskscore]
      ,U.[calculatedpricesensivityindex]
      ,U.[debttoincomeratio]
      ,U.[kalpvalue]
      ,U.[approvedloanamount]
      ,U.[approvedloanterm]
      ,U.[interestrate]
      ,U.[interestrategroup]
      ,U.[setupfee]
      ,U.[pdscorenewcustomer]
      ,U.[scoreversionnewcustomer]

        ,A.BrokerName
        ,A.SalesChannel
    

FROM [Reporting-db].[nystart].[UCS1] as U

LEFT JOIN [Reporting-db].[nystart].[Applications] as A
    ON U.applicationid = A.ApplicationID

WHERE create_date > '2023-08-01' AND A.SalesChannel != 'WEB')  -- sysdecgrpstd = 'AP'   AND  

--U.applicationid = '8855502' )-- If needed, you can uncomment and use '8700588' instead


select * from Application_