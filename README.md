# flutter_upyun

>  纯Dart代码，调用又拍云Form API上传文件

### 说明：

- upyun_utils

  又拍云签名工具类,依赖 intl: any 格式化时间

- upyun_http

  基于Dio网络框架上传

## 调用方式：


`

    UHttp.upload("/topic", imageFile, successCallBack: (data) {
        Toast.show("上传成功");
    }, errorCallBack: (error) {
      Toast.show(error);
    });

`

/topic  表示服务下面创建的文件夹目录，文件将会上传到该目录，当为 / 时，默认上传到服务的根目录

