select laf.degenerate_application_id,ssn,kids_number,housing_cost
from loan_application_fact laf
join loan_application_dim lad
on laf.loan_application_key=lad.loan_application_key
join applicant_dim ad on ad.applicant_key=laf.applicant_key
