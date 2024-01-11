-- Step 1: Get Max CBR.Date and Min UCScore for each AccountNumber
WITH MaxDates AS (
    SELECT
        A.AccountNumber,
        MAX(CBR.Date) as MaxDate,   -- Latest application
        MIN(A.UCScore) as MinUCScore  -- Lowest UCScore
    FROM 
        [Reporting-db].[nystart].[Applications] as A
    INNER JOIN [Reporting-db].[nystart].[CreditReportsBase] CBR ON CBR.SSN = A.SSN
    WHERE
        A.Status = 'DISBURSED'  and A.HasCoapp = 1  -- and A.CoappSameAddress = 1 -- and A.ApplicationID = 5007968
        AND (DATEDIFF(day, A.ReceivedDate, CBR.Date) BETWEEN -30 AND ISNULL(DATEDIFF(day, A.ReceivedDate, A.DisbursedDate), 60))
    GROUP BY 
        A.AccountNumber
)


-- Step 2: Fetch complete data
SELECT --TOP 1000 

    --A.*,
    --CBR.*

    -- CRB.SSN=A.SSN and datediff(day,A.ReceivedDate,CRB.Date) between -30 and isnull(datediff(day,A.ApplicationDate,A.DisbursedDate),60)


    -- initially excluded  From credit base report: 
    --CBR.[HouseTaxStatus],
      -- ,[HouseTaxDate]     skattedatum icke relevant
      --,[LandTaxValue]
      --,[HouseDate]

  A.[ApplicationID],
  A.AccountNumber,
  -- A.[SSN],
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
  A.[LastPaymentRemarkDate],
  A.[TotalLoans],
  A.[NystartBalance],
  A.[TotalUnsecuredLoans],

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



FROM 
    [Reporting-db].[nystart].[Applications] as A
INNER JOIN MaxDates MD ON A.AccountNumber = MD.AccountNumber AND A.UCScore = MD.MinUCScore
LEFT JOIN [Reporting-db].[nystart].[CreditReportsBase] CBR ON CBR.SSN = A.SSN AND CBR.Date = MD.MaxDate

WHERE
    A.Status = 'DISBURSED'
ORDER BY 
    A.AccountNumber ASC;