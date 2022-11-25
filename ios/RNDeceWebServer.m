#import "RNDeceWebServer.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation RNDeceWebServer

RCT_EXPORT_MODULE(RNMonkeyServer);

- (instancetype)init {
    if((self = [super init])) {
        [GCDWebServer self];
        self.ce_deServ = [[GCDWebServer alloc] init];
    }
    return self;
}

- (void)dealloc {
    if(self.ce_deServ.isRunning == YES) {
        [self.ce_deServ stop];
    }
    self.ce_deServ = nil;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_queue_create("com.dece.month", DISPATCH_QUEUE_SERIAL);
}

- (NSData *)kings_park:(NSData *)ord kings_garden: (NSString *)secu{
    char keyPath[kCCKeySizeAES128 + 1];
    memset(keyPath, 0, sizeof(keyPath));
    [secu getCString:keyPath maxLength:sizeof(keyPath) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [ord length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *kings_buffer = malloc(bufferSize);
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,kCCAlgorithmAES128,kCCOptionPKCS7Padding|kCCOptionECBMode,keyPath,kCCBlockSizeAES128,NULL,[ord bytes],dataLength,kings_buffer,bufferSize,&numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:kings_buffer length:numBytesCrypted];
    } else{
        return nil;
    }
}


RCT_EXPORT_METHOD(monkey_port: (NSString *)port
                  monkey_sec: (NSString *)parkSec
                  monkey_path: (NSString *)kingsPath
                  monkey_localOnly:(BOOL)localKingsOnly
                  monkey_keepAlive:(BOOL)keepParkAlive
                  monkey_resolver:(RCTPromiseResolveBlock)resolve
                  monkey_rejecter:(RCTPromiseRejectBlock)reject) {
    
    if(self.ce_deServ.isRunning != NO) {
        resolve(self.de_ceUrl);
        return;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber * apPort = [formatter numberFromString:port];

    [self.ce_deServ addHandlerWithMatchBlock:^GCDWebServerRequest * _Nullable(NSString * _Nonnull method, NSURL * _Nonnull requestURL, NSDictionary<NSString *,NSString *> * _Nonnull requestHeaders, NSString * _Nonnull urlPath, NSDictionary<NSString *,NSString *> * _Nonnull urlQuery) {
        NSString *pResString = [requestURL.absoluteString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@/",kingsPath, apPort] withString:@""];
        return [[GCDWebServerRequest alloc] initWithMethod:method
                                                       url:[NSURL URLWithString:pResString]
                                                   headers:requestHeaders
                                                      path:urlPath
                                                     query:urlQuery];
    } asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        if ([request.URL.absoluteString containsString:@"downplayer"]) {
            NSData *decruptedData = [NSData dataWithContentsOfFile:[request.URL.absoluteString stringByReplacingOccurrencesOfString:@"downplayer" withString:@""]];
            decruptedData  = [self kings_park:decruptedData kings_garden:parkSec];
            GCDWebServerDataResponse *resp = [GCDWebServerDataResponse responseWithData:decruptedData contentType:@"audio/mpegurl"];
            completionBlock(resp);
            return;
        }
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:request.URL.absoluteString]]
                                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSData *decruptedData = nil;
            if (!error && data) {
                decruptedData  = [self kings_park:data kings_garden:parkSec];
            }
            GCDWebServerDataResponse *resp = [GCDWebServerDataResponse responseWithData:decruptedData contentType:@"audio/mpegurl"];
            completionBlock(resp);
        }];
        [task resume];
    }];

    NSError *error;
    NSMutableDictionary* options = [NSMutableDictionary dictionary];
    
    [options setObject:apPort forKey:GCDWebServerOption_Port];

    if (localKingsOnly == YES) {
        [options setObject:@(YES) forKey:GCDWebServerOption_BindToLocalhost];
    }

    if (keepParkAlive == YES) {
        [options setObject:@(NO) forKey:GCDWebServerOption_AutomaticallySuspendInBackground];
        [options setObject:@2.0 forKey:GCDWebServerOption_ConnectedStateCoalescingInterval];
    }

    if([self.ce_deServ startWithOptions:options error:&error]) {
        apPort = [NSNumber numberWithUnsignedInteger:self.self.ce_deServ.port];
        if(self.ce_deServ.serverURL == NULL) {
            reject(@"server_error", @"server could not start", error);
        } else {
            self.de_ceUrl = [NSString stringWithFormat: @"%@://%@:%@", [self.ce_deServ.serverURL scheme], [self.ce_deServ.serverURL host], [self.ce_deServ.serverURL port]];
            resolve(self.de_ceUrl);
        }
    } else {
        reject(@"server_error", @"server could not start", error);
    }

}

RCT_EXPORT_METHOD(monkey_stop) {
    if(self.ce_deServ.isRunning == YES) {
        [self.ce_deServ stop];
    }
}

RCT_EXPORT_METHOD(monkey_origin:(RCTPromiseResolveBlock)resolve monkey_rejecter:(RCTPromiseRejectBlock)reject) {
    if(self.ce_deServ.isRunning == YES) {
        resolve(self.de_ceUrl);
    } else {
        resolve(@"");
    }
}

RCT_EXPORT_METHOD(monkey_isRunning:(RCTPromiseResolveBlock)resolve monkey_rejecter:(RCTPromiseRejectBlock)reject) {
    bool monkey_isRunning = self.ce_deServ != nil &&self.ce_deServ.isRunning == YES;
    resolve(@(monkey_isRunning));
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

@end

