# BullKit

BullKit is a simple API wrapper for interacting with the [CampBX API](https://campbx.com/api.php).

##Requirements

BullKit requires ARC and iOS5.

##Installation

Import BullKit.h and BullKit.m into your Objective-C project. Cocoapods support is on the way.

##Usage

BullKit requests are designed for one-time use. To make a request first create an instance of BullKit:

    BullKit *bk = [[BullKit alloc] initWithDelegate:self];


You may have noticed that "self" is passed as the delegate above. You should implement the "BullKitDelegate"
protocol, which includes the following methods:

    - (void)bkRequestSucceeded:(BullKit *)bkRequest {
        NSLog(@"HTTP Status Code: %d", [bkRequest responseStatusCode]);
        NSLog(@"Response String: %@", [bkRequest responseString]);
    }

    - (void)bkRequestFailed:(NSError *)error {
        NSLog(@"Response Error: %@", error);
    }

Fetching data is as simple as calling the exposed methods in the header file.

###Canceling Requests

You can cancel an in-progress request by passing the "cancel" message:

    [bk cancel];


### Controlling Timeout

BullKit defaults to a 10 second timeout. You can change that (globally) to 30 seconds like so:

    [BullKit setTimeout:30];
