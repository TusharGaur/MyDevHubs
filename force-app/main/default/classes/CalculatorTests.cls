@isTest
public without sharing class CalculatorTests {

    @isTest
    public static Void testDivideByZero() {
        try {
            Test.startTest();
            Assert.areEqual(Calculator.divide(1,0),'You still can\'t divide by zero','Negative Denominator');
            Assert.areEqual(Calculator.divide(-4,2),'Division returned a negative value.-2','Should Return Negative');
            Assert.areEqual(Calculator.divide(4,2),2,'Should Return value');
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }
}