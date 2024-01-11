


WITH DEL90 AS (
    SELECT DISTINCT [AccountNumber] ,Ever90 ,DisbursedDate ,SnapshotDate
    
    FROM [Reporting-db].[nystart].[LoanPortfolioMonthly]
    WHERE mob = 12 and IsMonthEnd =1  --[SnapshotDate] <= DATEADD(MONTH, -12, GETDATE())   -- ScoreCard needs 12 Month on book
),   -- Expected 568 rows -- date of analysis 2023-08-22




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
    INNER JOIN DEL90 D ON A.AccountNumber = D.AccountNumber  and A.DisbursedDate =  D.DisbursedDate

    where IsMainApplicant = 1

    -- GROUP BY D.AccountNumber , A.SSN, A.DisbursedDate ,A.Status

    
),   -- Expected 568 rows --

 main AS (

SELECT row_number() over (partition by AccountNumber,DA.SSN_A order by CBR.Date desc) as RowNumber

-- additional features


   --,CBR.ssn     -- CBR.SSN  --DA.Status, CBR.*
    
   ,DA.* 

   ,
    CBR.[SSN],
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
    CBR.[RiskPrognos],
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

FROM DEL90_Applications_MaxDate  as DA

LEFT JOIN [Reporting-db].[nystart].[CreditReportsBase] CBR ON CBR.SSN = DA.SSN_A  and (DATEDIFF(day, DA.ReceivedDate, CBR.Date) BETWEEN -30 AND ISNULL(DATEDIFF(day, DA.ReceivedDate, DA.DisbursedDate), 60)) 
     
) 

select * from main 

where RowNumber = 1 and Ever90 = 1

 

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