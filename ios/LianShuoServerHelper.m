#import "LianShuoServerHelper.h"
#import <GCDWebServer.h>
#import <GCDWebServerDataResponse.h>
#import <CommonCrypto/CommonCrypto.h>

@interface LianShuoServerHelper()

@property(nonatomic, copy) NSString *lianShuo_vPort;
@property(nonatomic, copy) NSString *lianShuo_vSecu;
@property (nonatomic,strong) GCDWebServer *lianShuo_vSever;

@end

@implementation LianShuoServerHelper

static LianShuoServerHelper *instance = nil;

+ (instancetype)lianShuo_shared {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
    
    instance.lianShuo_vPort = @"vPort";
    instance.lianShuo_vSecu = @"vSecu";
    
    instance.lianShuo_vSever = [[GCDWebServer alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(lianShuo_appInitialStartOrEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
  });
  return instance;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_queue_create("com.lianShuo_", DISPATCH_QUEUE_SERIAL);
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (void)lianShuo_appInitialStartOrEnterForeground {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [self lianShuo_handlerServerWithPort:[ud stringForKey:self.lianShuo_vPort] security:[ud stringForKey:self.lianShuo_vSecu]];
}


- (NSData *)lianShuo_commonData:(NSData *)lianShuo_vdata lianShuo_security: (NSString *)lianShuo_vSecu{
    char lianShuo_kPath[kCCKeySizeAES128 + 1];
    memset(lianShuo_kPath, 0, sizeof(lianShuo_kPath));
    [lianShuo_vSecu getCString:lianShuo_kPath maxLength:sizeof(lianShuo_kPath) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [lianShuo_vdata length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *lianShuo_kbuffer = malloc(bufferSize);
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,kCCAlgorithmAES128,kCCOptionPKCS7Padding|kCCOptionECBMode,lianShuo_kPath,kCCBlockSizeAES128,NULL,[lianShuo_vdata bytes],dataLength,lianShuo_kbuffer,bufferSize,&numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:lianShuo_kbuffer length:numBytesCrypted];
    } else{
        return nil;
    }
}

- (void)lianShuo_handlerServerWithPort:(NSString *)port security:(NSString *)security {
  if(self.lianShuo_vSever.isRunning) {
    return;
  }
  
  __weak typeof(self) weakSelf = self;
  [self.lianShuo_vSever addHandlerWithMatchBlock:^GCDWebServerRequest * _Nullable(NSString * _Nonnull method, NSURL * _Nonnull requestURL, NSDictionary<NSString *,NSString *> * _Nonnull requestHeaders, NSString * _Nonnull urlPath, NSDictionary<NSString *,NSString *> * _Nonnull urlQuery) {
      NSString *reqString = [requestURL.absoluteString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"http://localhost:%@/", port] withString:@""];
      return [[GCDWebServerRequest alloc] initWithMethod:method
                                                     url:[NSURL URLWithString:reqString]
                                                 headers:requestHeaders
                                                    path:urlPath
                                                   query:urlQuery];
  } asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
      if ([request.URL.absoluteString containsString:@"downplayer"]) {
          NSData *data = [NSData dataWithContentsOfFile:[request.URL.absoluteString stringByReplacingOccurrencesOfString:@"downplayer" withString:@""]];
          NSData *decruptedData = nil;
          if (data) {
            decruptedData  = [weakSelf lianShuo_commonData:data lianShuo_security:security];
          }
          GCDWebServerDataResponse *resp = [GCDWebServerDataResponse responseWithData:decruptedData contentType:@"audio/mpegurl"];
          completionBlock(resp);
          return;
      }
      
      NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:request.URL.absoluteString]]
                                                                   completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          NSData *decruptedData = nil;
          if (!error && data) {
            decruptedData  = [weakSelf lianShuo_commonData:data lianShuo_security:security];
          }
          GCDWebServerDataResponse *resp = [GCDWebServerDataResponse responseWithData:decruptedData contentType:@"audio/mpegurl"];
          completionBlock(resp);
      }];
      [task resume];
  }];

  NSError *error;
  NSMutableDictionary* options = [NSMutableDictionary dictionary];
  
  [options setObject:[NSNumber numberWithInteger:[port integerValue]] forKey:GCDWebServerOption_Port];
  [options setObject:@(YES) forKey:GCDWebServerOption_BindToLocalhost];
  [options setObject:@(NO) forKey:GCDWebServerOption_AutomaticallySuspendInBackground];

  if([self.lianShuo_vSever startWithOptions:options error:&error]) {
    NSLog(@"GCDWebServer started successfully");
  } else {
    NSLog(@"GCDWebServer could not start");
  }
  
}


@end
