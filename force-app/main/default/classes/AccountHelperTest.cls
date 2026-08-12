@IsTest
public class AccountHelperTest {
    
    @IsTest
    static void testGreetingWithName() {
        // Arrange: create a fake Account record
        Account acc = new Account(Name = 'Acme Corp');
        
        // Act: call the method
        String result = AccountHelper.getGreeting(acc);
        
        // Assert: verify the output
        System.assertEquals('Hello, Acme Corp!', result);
    }
    
    @IsTest
    static void testGreetingWithoutName() {
        // Arrange: create an Account with no name
        Account acc = new Account();
        
        // Act
        String result = AccountHelper.getGreeting(acc);
        
        // Assert
        System.assertEquals('Hello, Salesforce!', result);
    }
    
    @IsTest
    static void testGreetingNullAccount() {
        // Act
        String result = AccountHelper.getGreeting(null);
        
        // Assert
        System.assertEquals('Hello, Salesforce!', result);
    }
}