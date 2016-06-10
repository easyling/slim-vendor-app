# slim_vendor_app

Complete test enviroment to test SlimView integration with 3rd party vendor emulation.

The project consists of 3 main parts:
 1. Server
 2. Client
 3. Test

## Server

The server is the back-end code to server the `client`. It is responsible to processing XLIFFs,
serving the client with appropriate data on them, keeping track of OAuth authorization token.

It is written in Dart and uses ForceMVC. In concepts, it is very similar to Spring Framework.

## Client

The UI codebase that's got two main responsibilities:
 1. emulate minimal functionality of a CAT tool
 2. integrate SlimView into itself and communicate with it

The client uses the high level API implementation of SlimView - Slimlib.

## Test

On top of the server and client parts come the tests. These tests are primarily aimed to checking
SlimView functionality and NOT the client's or server's. For more information on the tests, read: [Test Readme](test/readme.md)
