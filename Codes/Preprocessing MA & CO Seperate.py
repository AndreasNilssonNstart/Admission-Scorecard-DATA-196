## Importing Libs
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt


import pymssql
import pandas as pd

class DataPreprocessor:

    def __init__(self, server, database, username, password):
        self.server = server
        self.database = database
        self.username = username
        self.password = password

    def _connect_to_db(self):
        self.conn = pymssql.connect(self.server, self.username, self.password, self.database)

    def _disconnect_from_db(self):
        if self.conn:
            self.conn.close()

    def fetch_data_from_sql(self, file_path):
        self._connect_to_db()
        
        with open(file_path, 'r') as f:
            sql = f.read()

        df = pd.read_sql(sql, self.conn)

        self._disconnect_from_db()

        return df

    def drop_columns(self, df, columns_to_drop):
        return df.drop(columns=columns_to_drop, errors='ignore')

    def _merge_dataframes(self, main, co):
        return pd.concat([main, co])


    def apply_transformations(self, df):
        
        df = df[~pd.isna(df.UCScore)].copy()


        df['Applicationtype'] = np.where( (df['HasCoapp'] == 0),0,
            (df['HasCoapp'] == 1) & (df['CoappSameAddress'] == 1), 1,
            np.where(
                (df['HasCoapp'] == 1) & (df['CoappSameAddress'] == 0), 2,
                np.nan  # Default value for other conditions
            )
        )


        # Ensure the 'DisbursedDate' column is of datetime64 type
        df['DisbursedDate'] = pd.to_datetime(df['DisbursedDate'])

        # Filter the DataFrame
        df = df[df['DisbursedDate'] > '2018-01-01']


        df['ReceivedDate'] = pd.to_datetime(df['ReceivedDate'])
        df = df.sort_values(by='ReceivedDate')


        for now in range(len(df['ReceivedDate'])-1):

            if df['ReceivedDate'].iloc[now] > df['ReceivedDate'].iloc[now+1]:
                print('NOT Sorted')


        ## save for later 
        #d = df['ReceivedDate'] 
        #d.to_csv('ReceivedDate.csv', index=False)


        # Get today's date without time
        today = pd.Timestamp('today').floor('D')

        df['BirthDate'] = pd.to_datetime(df['BirthDate'])

        # Compute the age based solely on years
        df['age'] = today.year -  df['BirthDate'].dt.year

        # Adjust for cases where the birthdate hasn't occurred this year yet
        df['age'] = np.where((today.month < df['BirthDate'].dt.month) | 
                            ((today.month == df['BirthDate'].dt.month) & (today.day < df['BirthDate'].dt.day)), 
                            df['age']-1, 
                            df['age'])






        credit_data_columns = [
            'PaymentRemarksNo',
            'PaymentRemarksAmount',
            "CreditCardsNo",
            "ApprovedCardsLimit",
            "CreditAccountsVolume",
            "CapitalIncome",
            "PassiveBusinessIncome2",
            "CapitalIncome2",
            "ActiveBusinessDeficit2",
            "KFMPublicClaimsAmount",
            "KFMTotalAmount",
            'KFMPrivateClaimsAmount',   # Added the missing comma here
            "KFMPublicClaimsNo",
            "KFMPrivateClaimsNo",
            "HouseTaxValue",
            "MortgageLoansHouseVolume",
            'MortgageLoansApartmentVolume',
            'AvgUtilizationRatio12M',
            'EmploymentIncome',
            'EmploymentIncome2'

            ,'Ever90'
        ]

        print(type(df.MortgageLoansHouseVolume))
               

        # Ensure the specified columns are float and fill NaN with 0
        for column in credit_data_columns:
            if column in df.columns:  # Only apply to columns that exist in the dataframe
                df[column] = df[column].astype(float).fillna(0)




        loan_columns = [
            "InstallmentLoansNo",
            "IndebtednessRatio",
            "AvgIndebtednessRatio12M",
            "InstallmentLoansVolume",
            "VolumeChange12MExMortgage",
            "VolumeChange12MUnsecuredLoans",
            "VolumeChange12MInstallmentLoans",
            "VolumeChange12MCreditAccounts",
            "VolumeChange12MMortgageLoans",
            "AvgUtilizationRatio12M",
            "CreditCardsUtilizationRatio",
            "UnsecuredLoansVolume",
            "NumberOfLenders",
            "CapitalDeficit",
            "CapitalDeficit2",
            "NewUnsecuredLoans12M",
            "NewInstallmentLoans12M",
            "NewCreditAccounts12M",
            "VolumeUsed",
            "ApprovedCreditVolume"
            ,'NumberOfBlancoLoans'
            ,'NumberOfCreditCards'
            ,'NewMortgageLoans12M'
            ,	'TotalNewExMortgage12M'

            ,  "NumberOfMortgageLoans",
            "SharedVolumeMortgageLoans",
            "SharedVolumeCreditCards",
            "NumberOfUnsecuredLoans",
            "SharedVolumeUnsecuredLoans",
            "NumberOfInstallmentLoans",
            "SharedVolumeInstallmentLoans",
            "NumberOfCreditAccounts",
            "SharedVolumeCrerditAccounts"
            ,'UnsecuredLoansNo'
            , 'IncomeDelta_1Year'
            ,'kids_number'

            ,'Inquiries12M'

        ]



        # Ensure the specified columns are float and fill NaN with -1
        for column in loan_columns:
            if column in df.columns:  # Only apply to columns that exist in the dataframe
                df[column] = df[column].astype(float).fillna(-1)


        loan_columns = [
        "CapitalDeficit_Delta_1Year","UtilizationRatio",'housing_cost']



        # Ensure the specified columns are float and fill NaN with -1
        for column in loan_columns:
            if column in df.columns:  # Only apply to columns that exist in the dataframe
                df[column] = df[column].astype(float).fillna(-100)



        inf_columns = ['CapitalDeficit_Delta_1Year',
                    'IncomeDelta_1Year',
                    'ActiveCreditAccounts']
            
        for col in inf_columns:
            if col in df.columns:
                df[col] = df[col].replace([np.inf, -np.inf], -100)


        ## the rest

        for Cname in df.columns:

            if str(df[Cname].dtype) == 'object':
                df[Cname].fillna('Unknown', inplace=True)
                df[Cname].replace('None', 'Unknown', inplace=True)


        
        df['PropertyVolume'] = np.where( (df.MortgageLoansHouseVolume > 0 ) & (df.SharedVolumeMortgageLoans > 0), df.MortgageLoansHouseVolume / 2 ,
                            np.where(df.MortgageLoansHouseVolume > 0  , df.MortgageLoansHouseVolume ,
                                        

                            np.where( ( df.MortgageLoansApartmentVolume > 0 ) & (df.SharedVolumeMortgageLoans > 0 ),    df.MortgageLoansApartmentVolume/ 2 ,
                            np.where( df.MortgageLoansApartmentVolume > 0, df.MortgageLoansApartmentVolume ,         

                                        0))))
                               


        return df

    def process_data(self, main_sql_file_path):
            
            return self.apply_transformations(self.fetch_data_from_sql(main_sql_file_path))