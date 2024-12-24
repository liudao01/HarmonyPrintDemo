//导入页面路由模块
import router from '@ohos.router';
import usb from '@ohos.usb';
import {PrinterInstance} from './PrinterInstance';
@Entry
@Component
struct Index {
  @State message: string = '鸿蒙开发demo';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        // 添加按钮，以响应用户点击
        Button() {
          Text('打印测试功能')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({
          top: 20
        })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('5%')
        // 跳转按钮绑定onClick事件，点击时跳转到第二页
        .onClick(() => {
          console.info(`Succeeded in clicking the 'Next' button.`)
          // 跳转到第二页
          router.pushUrl({ url: 'pages/Second' }).then(() => {
            console.info('Succeeded in jumping to the second page.')
            // @ts-ignore
          }).catch((err: BusinessError) => {
            console.error(`Failed to jump to the second page.Code is ${err.code}, message is ${err.message}`)
          })
        })

        // 打印机测试
        Button() {
          Text('打印机测试')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({
          top: 20
        })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('5%')
        // 跳转按钮绑定onClick事件，点击时跳转到第二页
        .onClick(async () => {
          //1.创建一个 USB 打印机实例
          let usbDevice:usb.USBDevice= usb.getDevices()[0];
          let usbPrinter=PrinterInstance.getPrinterInstance(usbDevice);
          //连接打印机
          (await usbPrinter).openConnection().then(
            result => {
              console.log("连接结果:", result); // 这里的result应该是一个boolean值
            }
          ).catch(
            error => {
              console.error("连接失败:", error);
            }
          );

          //向打印机写入数据
          // (await usbPrinter).writeDataToPrinter(new Array());
          // //从打印机读取数据
          // (await usbPrinter).readDataFromPrinter(new Array());
          // //关闭与打印机的连接
          // (await usbPrinter).closeConnection();


          //2.创建一个 蓝牙 打印机实例
          // console.log("打印机实例化测试");
          // let btDevice:string= 'L39 Printer';
          // let btPrinter=PrinterInstance.getPrinterInstance(btDevice);
          // //连接打印机
          // btPrinter.openConnection();
          // //向打印机写入数据
          // btPrinter.writeDataToPrinter(new Array());
          // //从打印机读取数据
          // btPrinter.readDataFromPrinter(new Array());
          // //关闭与打印机的连接
          // btPrinter.closeConnection();

        })
      }
      .width('100%')
    }
    .height('100%')
  }
}