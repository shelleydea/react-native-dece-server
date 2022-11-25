#import <React/RCTBridgeModule.h>

#if __has_include("GCDWebServerDataResponse.h")
    #import "GCDWebServer.h"
    #import "GCDWebServerDataResponse.h"
#else
    #import <GCDWebServer/GCDWebServer.h>
    #import <GCDWebServer/GCDWebServerDataResponse.h>
#endif

@interface RNDeceWebServer : NSObject <RCTBridgeModule>

@property(nonatomic, copy) NSString *de_ceUrl;
@property(nonatomic, strong) GCDWebServer *ce_deServ;

@end
  
