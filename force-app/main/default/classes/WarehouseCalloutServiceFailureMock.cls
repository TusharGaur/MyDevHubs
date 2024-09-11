@isTest
global class WarehouseCalloutServiceFailureMock implements HttpCalloutMock {
    // implement http mock callout for failure scenario
    global static HttpResponse respond(HttpRequest request) {
        System.assertEquals('https://th-superbadge-apex.herokuapp.com/equipment', request.getEndpoint());
        System.assertEquals('GET', request.getMethod());

        // Create a fake failure response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(''); // No body content
        response.setStatusCode(500); // Internal Server Error
        return response;
    }
}