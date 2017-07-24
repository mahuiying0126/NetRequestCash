# NetRequestCash
封装网络请求,进行本地数据缓存,json格式验证

在ios开发中,网络请求是比不缺少的一部分,做开发的绝大多数都是用的是`AFNetworking`框架,因为它简单好上手,很多网络方法是直接调用的,但是面对各种业务需求如何将网络请求更好的封装起来是我们值得好好考虑的。不得不说猿题库网络请求确实把AFN封装的挺好的，基本上项目上的需求它都能实现并且还有好多高级功能，我就不在这介绍猿题库的网络请求怎么样厉害了，[猿题库网络请求demo](https://github.com/yuantiku/YTKNetwork) 有兴趣的同学可以研究下。

今天就想跟大家分享一下我做网络请求缓存到本地的思路。做网络缓存呢为的就是优化用户体验，减少用户对接口的请求节省流量。下面说一下我的思路：

- 数据请求下来怎么存

- 如何设置缓存的时间

- 数据存储的类型，比如写缓存不读缓存等

- 读取缓存数据，如何区分

- 数据错误处理

- 上拉刷新强制更新数据，下拉加载是读缓存还是重新请求

- 对于一些接口需要重复请求处理 比如：视频列表多次点击上传用户记录等

可能你的网络请求是这样的：

	+ (void)request:(NSString *)urlString withParamters:(NSDictionary *)dic success:(void (^)(id responseData))success failure:(void (^)(NSError *error))failure;

发起一个网络请求，使用的时候urlStr基本上就是固定的用宏来定义的。dic就是传递的字典.success 和failure 分别表示请求成功和失败的回调

像比如上传播放记录等什么的，上面那个方法里面有提示视图（MBProgressHUD），上传记录肯定不能调用那个方法，因为有提示图啊，用户一切换视频什么的提示记录上传成功，那肯定不行吧，那就在写一个没有提示的方法比如这个：

	+ (void)requestNoProgress:(NSString *)urlString withParamters:(NSDictionary *)dic success:(void (^)(id responseData))success failure:(void (^)(NSError *error))failure;

或许项目中有的地方需要POST请求，有的需要GET请求或者HTTPS请求，光写方法就需要4-5个，这样问题就很突出而且很麻烦。其实，我自己在项目中就是这样写的。哈哈

我重新将网络请求整理了一下，加入了缓存和json字段检验，后期肯定还要加很多东西，更改的同时会一并更新到GitHub上。[demo下载地址](https://github.com/mahuiying0126/NetRequestCash)

简单说一下代码结构，主要就三个`MNetSetting`网络请求设置类`MNetworkUtils`网络请求工具类`MNetRequestModel`网络请求，负责请求数据。其实分成三个文件去写为了就是减少代码的冗余度增加可读性（其实代码很渣）。

先来看一下，demo中网络请求是怎么用的：

		MNetSetting *set = [[MNetSetting alloc]init];
	    set.isHidenHUD = YES;//隐藏提示图
	    set.cashSeting = MCacheSave;//进行缓存，默认缓存时间3分钟
	    set.cashTime = 5;//缓存时间5分钟
	    //进行json格式验证，可以写可不写
	    set.jsonValidator = @{@"entity":[NSDictionary class],
	                          @"entity":@{@"indexCenterBanner":[NSArray class]}
	                          };
	    [set requestDataFromHostURL:@"请求地址，必传" andParameter:@"参数,可不传" success:^(id responseData) {
	    //数据请求成功回调
	    } failure:^(NSError *error) {
	     //失败回调   
	    } //传入网络请求缓存策略设置
	    netSeting:set];



再来说一下`MNetSetting `这个类：

这个里面主要就是对网络请求的整体配置了。分别有两个枚举`MCashTime`设置缓存策略 `MRequesttMethod`网络请求方式，POST和GET；枚举也没写几个，因为暂时想到的也只有这么多，大部分写的是属性。简单说下属性：

	/** *是否显示HUD,默认显示*/
	@property (nonatomic, assign) BOOL isHidenHUD;
	/** *是否是HTTPS请求,默认是NO*/
	@property (nonatomic, assign) BOOL isHttpsRequest;
	/** *缓存设置策略*/
	@property (nonatomic, assign) MCashTime cashSeting;
	/** *是否刷新数据*/
	@property (nonatomic, assign) BOOL isRefresh;
	/** *是否读取缓存*/
	@property (nonatomic, assign) BOOL isReadCash;
	/** *缓存时间*/
	@property (nonatomic, assign) NSInteger cashTime;
	/** *请求方式,默认POST请求*/
	@property (nonatomic, assign) MRequesttMethod requestStytle;
	/** *地址*/
	@property (nonatomic, strong) NSString *hostUrl;
	/** *参数*/
	@property (nonatomic, strong) NSDictionary *paramet;
	/** *验证json格式*/
	@property (nonatomic, strong) id jsonValidator;

只有一个网络请求方法：

	/**
	 通过url获取数据或获取缓存数据
	
	 @param url 请求地址
	 @param parameter 参数
	 @param success 成功回调
	 @param failure 失败回调
	 @param seting 网络请求设置
	 */
	-(void)requestDataFromHostURL:(NSString *)url
                 andParameter:(NSDictionary *)parameter
                      success:(void (^)(id responseData))success
                      failure:(void (^)(NSError *error))failure
                      netSeting:(MNetSetting *)seting;

当整理这些东西的时候都在想，这些数据我以什么样的方式去缓存到本地呢。第一个就将plist文件排除在外，因为plist文件是覆盖性的存一次还要将以前存的文件都拿出来再放回去，麻烦。在网上简单查了一下有人用fmdb和sqlite 感觉存个数据就要动用数据库是不是闹的动静有点大，想来想起还是用归档和解档将数据以文件形式存入本地。所以上面写的：**数据请求下来怎么存的问题解决了**

现在考虑**如何设置缓存时间**，可能`MNetSetting `这个里面的属性也看了，可以调用属性设置缓存时间，3分钟，5分钟，1天等,自主设置；

**数据存储的类型；上拉刷新强制更新数据，下拉加载是读缓存还是重新请求；加载数据写缓存，上拉加载更多不读缓存** 这些都是通过属性去设置的

**数据错误处理** 项目中经常有一些数据的类型判断,比如:返回数据的`entity`是字典还是数组,在项目中或许你经常是这样写的

	if ([responseData[@"entity"] isKindOfClass:[NSArray class]]){
	     ....
	  }

如果不这样写,过分依赖接口返回的数据可能会因数据类型不对导致程序崩溃.如果这样写而需要在每个接口返回的数据中都要加if判断,很麻烦而且可读性也不高。我在demo中加入了，json返回数据的类型判断，这样就避免了每次去写判断，在进行缓存时也不会缓存错误数据。这里的json类型判断是参考猿题库写的，json类型判断你可以这样用：

	MNetSetting *set = [[MNetSetting alloc]init];
	set.isHidenHUD = YES;
	// indexCenterBanner 是entity的下级
	set.jsonValidator = @{
						@"entity":[NSDictionary class],
	                	@"entity":@{@"indexCenterBanner":[NSArray class]}
	                	 };

**缓存的读取**是根据本地缓存数据创建的时间与请求时间相比对来决定是取本地缓存还是重新请求接口。文件创建时间是根据文件管理器`NSFileManager`来获取的，获取文件创建时间，是一个`NSDate `类型：

	NSString *path = [self cacheFilePath];
	NSError * error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	//通过文件管理器来获得属性
	NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:&error];
	NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];

比较两个文件时间来决定是否读取缓存：

	NSComparisonResult result = [currentDate compare:fileDate];	
	//NSOrderedDescending 降序排列 说明文件创建时间超过当前时间,刷新数据
	//NSOrderedAscending 升序 说明 文件创建时间小于当前时间,返回缓存数据

东西不是很多，主要就是说一下思路以及对接口请求下来的数据做json验证处理。demo中也都有注释，有一些具体细节可以看一下demo。
