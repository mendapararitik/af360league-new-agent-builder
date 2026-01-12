public class PortfolioValueCalculator {
 
    // Get total portfolio value
    @InvocableMethod(
        label='Calculate Total Portfolio Value'
        description='Returns sum of financial account loan amounts. Optionally filter by status and account type.'
    )
    public static List<ValueResult> calculatePortfolioValue(List<InputRequest> requests) {

        String status = 'Active';
        String accountType;

        if (requests != null && !requests.isEmpty() && requests[0] != null) {
            InputRequest input = requests[0];
 
            if (String.isNotBlank(input.status)) {
                status = input.status;
            }
 
            if (String.isNotBlank(input.accountType)) {
                accountType = input.accountType;
            }
        }
 
        String query = 'SELECT Id, Original_Loan_Amount__c ' +
                       'FROM FinancialAccount ' +
                       'WHERE Status = :status';
 
        if (String.isNotBlank(accountType)) {
            query += ' AND FinancialAccountType = :accountType';
        }
 
        List<FinancialAccount> accounts = Database.query(query);
 
        // Calculate total
        Decimal totalValue = 0;
        for (FinancialAccount account : accounts) {
            if (account.Original_Loan_Amount__c != null) {
                totalValue += account.Original_Loan_Amount__c;
            }
        }
 
        ValueResult result = new ValueResult();
        result.totalValue = totalValue;
 
        return new List<ValueResult>{ result };
    }

    public class InputRequest {
 
        @InvocableVariable(
            label='Status'
            description='Optional: Filter by status (e.g., Active, Closed). Defaults to Active.'
        )
        public String status;
 
        @InvocableVariable(
            label='Account Type'
            description='Optional: Financial Account Type (e.g., Mortgage, Loan).'
        )
        public String accountType;
    }

    public class ValueResult {
 
        @InvocableVariable(
            label='Total Portfolio Value'
            description='Sum of loan amounts matching the filters'
        )
        public Decimal totalValue;
    }
}
 
