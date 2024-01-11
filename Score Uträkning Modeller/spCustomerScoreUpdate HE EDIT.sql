/****** Object:  StoredProcedure [dbo].[spCustomerScoreUpdate]    Script Date: 19.05.2022 10:29:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spCustomerScoreUpdate]
@Day date='1900-01-01'
as BEGIN
IF @Day='1900-01-01'
	select @Day=MAX(SnapshotDate) from nystart.Loanportfolio

IF OBJECT_ID('tempdb..#base') is not null
	DROP TABLE #base
select LP.AccountNumber,
	   LP.SnapshotDate,
	   LP.MOB,
	   DelinquencyStatusCode,
	   Floor(DATEDIFF(month,A.BirthDate,SnapshotDate)/12) as Age,
	   case when A2.UCScore is null then A.UCScore
			when A2.UCScore is not null then
				case when A2.UCScore<A.UCScore then A2.UCScore else A.UCScore end
		end as UCScore,
	   A.UCScore as UCScoreMain,
	   A2.UCScore as UCScoreCoapp,
	   A.MaritalStatus,
	   A.HasCoapp,
	   case when MOB<=2 then 'N'
		    when DelinquencyStatusCode>=2 then 'B'
			else 'E'
	   end as CustomerType
into #base   
from nystart.LoanPortfolio LP
left join nystart.Applications A
on LP.AccountNumber=A.AccountNumber 
   and A.IsMainApplicant=1
   and a.DisbursedDate=LP.DisbursedDate
left join nystart.Applications A2
on LP.AccountNumber=A2.AccountNumber 
   and A2.IsMainApplicant=0 
   and A2.ApplicantNo=2
   and a2.DisbursedDate=LP.DisbursedDate
where SnapshotDate=@Day
and IsOpen=1;
IF OBJECT_ID('tempdb..#sc') is not null
	DROP TABLE #sc;

with deli as (
select LP.AccountNumber,MAX(LP.DelinquencyStatusCode) as MaxDeli
from nystart.LoanPortfolio LP
join #base b on LP.AccountNumber=b.AccountNumber
where LP.SnapshotDate between DATEADD(YEAR,-1,@Day) and dateadd(DAY,-1,@Day)
group by LP.AccountNumber),
logit as (
/*HE EDIT. New coefficients for the application score logit model.
Less punishment(premium) for being young(old)*/
select b.*,
	   md.MaxDeli,
	   case when CustomerType='N' then 
				-4.2059 								--  -3.6474 /*old values*/
				+ case when UCScore<10 then 0
					   when UCScore<30 then 0.9958 		--  1.3702
					   when UCScore<50 then 1.2435 		--  1.5266
					   else 1.6464 						--  1.8648
				  end
				+ case when MaritalStatus in ('MARRIED','PARTNER') then 0
					   else 0.3482 						-- 0.3859
				  end
				+ case when Age<25 then 0
					   when Age<39 then -0.2473 		-- -1.1267
					   else -0.7944 					-- -2.0455
				  end
		/*No chages to customer score here*/
			when CustomerType='E' then 
				-3.272
				+ case when DelinquencyStatusCode=0 then 0
					   else 2.07171
				  end
				+ case when MaxDeli=0 then 0
					   when MaxDeli=1 then 0.23903
					   when MaxDeli in (2,3) then 0.76202
					   when MaxDeli=4 then 1.76491
					   else 5.33848
				  end
				+ case when HasCoapp=0 then 0
					   else -0.92341
				  end
			end as logit
			
from #base b 
left join deli md 
on md.AccountNumber=b.AccountNumber
),
scored as (
select *,
		/*changes from score above goes into the "logit"-variable. 
		Changes to late payers PD*/
	   case when CustomerType in ('E','N') then exp(logit)/(1+exp(logit))*100 
			when CustomerType ='B' and DelinquencyStatusCode=2 then 63.41  		-- 41.7
			when CustomerType ='B' and DelinquencyStatusCode=3 then 92.65  		-- 64.5
			when CustomerType ='B' and DelinquencyStatusCode>3 then 100.0
			else null 
	   end as Score
from logit),
score as (
select s.*,
	   case when CustomerType='N' and Score<2.0 then 'N1'
			when CustomerType='N' and Score<5.0 then 'N2'
			when CustomerType='N' and Score>=5.0 then 'N3'
			when CustomerType='E' and Score<2 then 'E3'
			when CustomerType='E' and Score<8 then 'E4'
			when CustomerType='E' and Score>=8 then 'E5'
			when CustomerType='B' and DelinquencyStatusCode=2 then 'E6'
			when CustomerType='B' and DelinquencyStatusCode=3 then 'E7'
			when CustomerType='B' and DelinquencyStatusCode>3 then 'E8'
		end as RiskClass


from scored s)
select AccountNumber,
	   SnapshotDate,
	   case when RiskClass in ('N1','N2','N3','E3','E4') then 1
			when RiskClass in ('E5','E6','E7') then 2
			when RiskClass='E8' then 3
	   end as Stage,
	   RiskClass,
	   Score
into #sc
from score
delete from nystart.CustomerScore where SnapshotDate=@Day
insert into nystart.CustomerScore
select * from #sc
END
