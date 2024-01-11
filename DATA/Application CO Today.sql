WITH


snn_score_both AS (
    SELECT

    
        A.AccountNumber,


        A.ApplicationID,
        A.[SSN] ,--as SSN_A,
        A.[IsMainApplicant],
        --A.[ApplicantNo],
        A.ApplicationScore,
        A.[HasCoapp],      

        A.[ReceivedDate],
        A.[DisbursedDate],
        A.[Amount],
        --A.[UCScore],
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
        A.[TotalUnsecuredLoans],

       -- CBR.[SSN],
    CBR.[jsonID],
    CBR.[Date],
    CBR.[import_key],
    CBR.[SSN2],
    CBR.[CountyCode],
    CBR.[MunicipalityCode],
    CBR.[PostalCode],
    CBR.[GuardianAppointed],
    CBR.[BlockCode],
    CBR.[BlockCodeDate],
    CBR.[CivilStatus],
    CBR.[CivilStatusDate],
    CBR.[TimeOnAddress],
    CBR.[AddressType],
    CBR.[Country],
    CBR.[RiskPrognos] as UCScore,
    CBR.[IncomeYear],
    CBR.[ActiveBusinessIncome],
    CBR.[PassiveBusinessIncome],
    CBR.[EmploymentIncome],
    CBR.[CapitalIncome],
    CBR.[CapitalDeficit],
    CBR.[GeneralDeductions],
    CBR.[ActiveBusinessDeficit],
    CBR.[TotalIncome],
    CBR.[IncomeYear2],
    CBR.[ActiveBusinessIncome2],
    CBR.[PassiveBusinessIncome2],
    CBR.[EmploymentIncome2],
    
    CBR.[CapitalIncome2],
    CBR.[CapitalDeficit2],
    CBR.[GeneralDeductions2],
    CBR.[ActiveBusinessDeficit2],
    CBR.[TotalIncome2],
    CBR.[IncomeBeforeTax],
    CBR.[IncomeBeforeTaxPrev],
    CBR.[IncomeFromCapital],
    CBR.[DeficitFromCapital],
    CBR.[IncomeFromOwnBusiness],
    CBR.[PaymentRemarksNo],
    CBR.[PaymentRemarksAmount],
    CBR.[LastPaymentRemarkDate],
    CBR.[KFMPublicClaimsAmount],
    CBR.[KFMPrivateClaimsAmount],
    CBR.[KFMTotalAmount],
    CBR.[KFMPublicClaimsNo],
    CBR.[KFMPrivateClaimsNo],
    CBR.[HouseTaxValue],
    CBR.[HouseOwnershipPct],
    CBR.[HouseOwnershipStatus],
    CBR.[HouseOwnershipNo],
    CBR.[Inquiries12M],
    CBR.[BusinessInquiries],
    CBR.[CreditCardsUtilizationRatio],
    CBR.[HasMortgageLoan],
    CBR.[HasCard],
    CBR.[HasUnsecuredLoan],
    CBR.[HasInstallmentLoan],
    CBR.[IndebtednessRatio],
    CBR.[AvgIndebtednessRatio12M],
    CBR.[ActiveCreditAccounts],
    CBR.[NewUnsecuredLoans12M],
    CBR.[NewInstallmentLoans12M],
    CBR.[NewCreditAccounts12M],
    CBR.[NewMortgageLoans12M],
    CBR.[TotalNewExMortgage12M],
    CBR.[VolumeChange12MExMortgage],
    CBR.[VolumeChange12MUnsecuredLoans],
    CBR.[VolumeChange12MInstallmentLoans],
    CBR.[VolumeChange12MCreditAccounts],
    CBR.[VolumeChange12MMortgageLoans],
    CBR.[AvgUtilizationRatio12M],
    CBR.[VolumeUsed],
    CBR.[NumberOfAccounts],
    CBR.[NumberOfLenders],
    CBR.[ApprovedCreditVolume],
    CBR.[InstallmentLoansVolume],
    CBR.[CreditAccountsVolume],
    CBR.[UnsecuredLoansVolume],
    CBR.[MortgageLoansHouseVolume],
    CBR.[MortgageLoansApartmentVolume],
    CBR.[NumberOfCredits],
    CBR.[NumberOfCreditors],
    CBR.[ApprovedCardsLimit],
    CBR.[NumberOfCreditCards],
    CBR.[NumberOfBlancoLoans],
    CBR.[SharedVolumeExMortgage],
    CBR.[SharedVolume],
    CBR.[NumberOfUnsecuredLoans],
    CBR.[SharedVolumeUnsecuredLoans],
    CBR.[NumberOfInstallmentLoans],
    CBR.[SharedVolumeInstallmentLoans],
    CBR.[NumberOfCreditAccounts],
    CBR.[SharedVolumeCrerditAccounts],
    CBR.[UtilizationRatio],
    CBR.[CreditAccountOverdraft],
    CBR.[NumberOfMortgageLoans],
    CBR.[SharedVolumeMortgageLoans],
    CBR.[SharedVolumeCreditCards]




    FROM [Reporting-db].[nystart].[Applications] as A
    INNER JOIN [Reporting-db].[nystart].[CreditReportsBase] CBR ON CBR.SSN = A.SSN
    WHERE
         A.HasCoapp = 1   and
        
         A.ReceivedDate >= '2022-08-01'        --and  A.[Status] = 'REJECTED'
        AND (DATEDIFF(day, A.ReceivedDate, CBR.Date) BETWEEN -30 AND ISNULL(DATEDIFF(day, A.ReceivedDate, A.DisbursedDate), 60))
),

min_per_acc AS (
    SELECT 
        AccountNumber, 
        min(UCScore) as MinUCScore
    FROM snn_score_both  
    GROUP BY AccountNumber
),

numbered_scores AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER(PARTITION BY s.AccountNumber ORDER BY s.UCScore DESC) AS RowNum
    FROM snn_score_both s
    INNER JOIN min_per_acc m ON m.AccountNumber = s.AccountNumber AND m.MinUCScore = s.UCScore

    
),

prevDone as (
SELECT 

*

FROM numbered_scores 

WHERE RowNum = 1
),

UCS1 AS (


SELECT U.[applicationid] as U_applicationid--TOP (1000) 
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
      ,U.[NewPDScore]

    ,A.*




FROM prevDone as A

LEFT JOIN  [Reporting-db].[nystart].[UCS1] as U

    ON U.applicationid = A.ApplicationID

WHERE create_date >= '2022-08-01' --AND A.SalesChannel != 'WEB'   

   --   and RowNumber = 1 
      -- sysdecgrpstd = 'AP'   AND  
)
,
max_time as (select U_applicationid , max(create_date) as max_time  from UCS1  group by U_applicationid) 



select u.* from UCS1 as u inner join  max_time as mt on u.U_applicationid = mt.U_applicationid and mt.max_time = u.create_date

--where u.AccountNumber = '7990617' 










--