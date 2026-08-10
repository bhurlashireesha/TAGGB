@IsTest
public class SmokeTests {
    @IsTest
    static void basicOrgHealthCheck() {
        // Call the utility method
        Boolean result = OrgHealthCheck.isOrgHealthy();
        System.assertEquals(true, result, 'Org health check should return true');
    }
}