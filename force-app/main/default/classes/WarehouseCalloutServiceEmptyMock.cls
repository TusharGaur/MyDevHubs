@isTest
global class WarehouseCalloutServiceEmptyMock implements HttpCalloutMock {
    // implement http mock callout for empty response scenario
    global static HttpResponse respond(HttpRequest request) {
        System.assertEquals('https://th-superbadge-apex.herokuapp.com/equipment', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());

        // Create a fake empty response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[]'); // Empty JSON array
        response.setStatusCode(200);
        return response;
    }
}