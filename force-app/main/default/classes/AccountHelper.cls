public class AccountHelper {
    // Method to return a greeting for an Account
    public static String getGreeting(Account acc) {
        if (acc == null || String.isBlank(acc.Name)) {
            return 'Hello, Salesforce!';
        }
        return 'Hello, ' + acc.Name + '!';
    }
}