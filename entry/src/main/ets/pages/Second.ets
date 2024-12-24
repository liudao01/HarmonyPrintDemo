import router from '@ohos.router';
import usb from '@ohos.usb';
import promptAction from '@ohos.promptAction';
import { PrinterInstance } from './PrinterInstance';
import { getUsbPrinter, stringToUint8Array, USBPort } from './USBPort';

@Entry
@Component
struct Second {
  @State message: string = '鸿蒙USB连接打印测试功能';
  @State connecd: boolean = false;
  @State textAreaContent: string = '';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Button() {
          Text('Back')
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({
          top: 20
        })
        .onClick(() => {
          console.info(`Succeeded in clicking the 'Back' button.`)
          try {
            // 返回第一页
            router.back()
            console.info('Succeeded in returning to the first page.')
          } catch (err) {
            // @ts-ignore
            let code = (err as BusinessError).code;
            // @ts-ignore
            let message = (err as BusinessError).message;
            console.error(`Failed to return to the first page.Code is ${code}, message is ${message}`)
          }
        })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('5%') // 返回按钮绑定onClick事件，点击按钮时返回到第一页

        // Button() {
        //   Text('打印机测试')
        //     .fontSize(30)
        //     .fontWeight(FontWeight.Bold)
        // }
        // .type(ButtonType.Capsule)
        // .margin({
        //   top: 20
        // })
        // .backgroundColor('#0D9FFB')
        // .width('40%')
        // .height('5%')
        // // 跳转按钮绑定onClick事件，点击时跳转到第二页
        // .onClick(async () => {
        //   //1.创建一个 USB 打印机实例
        //   let usbDevice: usb.USBDevice = usb.getDevices()[0];
        //   let usbPrinter = PrinterInstance.getPrinterInstance(usbDevice);
        //   // let mUsbPrinter: USBPort = <USBPort> <unknown> usbPrinter;
        //   //连接打印机
        //   // await usbPrinter.openConnection;
        //   //  console.log("连接结果1111:"); // 这里的result应该是一个boolean值
        //   (await usbPrinter).openConnection().then(
        //     result => {
        //       console.log("连接结果222:", result); // 这里的result应该是一个boolean值
        //       // this.selectedDevice = usbPrinter.
        //     }
        //   ).catch(
        //     error => {
        //       console.error("连接失败:", error);
        //     }
        //   );

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

        // })

        // Text(this.message)
        //   .fontSize(20)
        //   .fontWeight(FontWeight.Bold)
        TextArea({ placeholder: "请输入内容" })
          .width('90%')
          .height('15%')
          .margin(10)

          .onChange((value: string) => {
            this.textAreaContent = value;
          })
        Button(this.connecd ===true ? "已连接" : "点击连接", { type: ButtonType.Normal })
          .onClick(async () => {
            if (this.connecd ===true) {
              // let devicepipe: usb.USBDevicePipe = usb.connectDevice(this.selectedDevice);
              // let interfaces: usb.USBInterface = this.selectedDevice.configs[0].interfaces[0];
              let usbDevice: usb.USBDevice = usb.getDevices()[0];
              let usbPrinter = PrinterInstance.getPrinterInstance(usbDevice);
              (await usbPrinter).closeConnection();
              this.connecd = false;
              return;
            }
            let usbDevice: usb.USBDevice = usb.getDevices()[0];
            let usbPrinter = PrinterInstance.getPrinterInstance(usbDevice);

            //连接打印机
            await usbPrinter.openConnection().then(
              result => {
                console.log("连接结果2222:", result); // 这里的result应该是一个boolean值
                // this.selectedDevice = usbPrinter.
                this.connecd = result;
              }
            ).catch(
              error => {
                console.error("连接失败:", error);
              }
            );
            console.log("连接结果3333:"); // 这里的result应该是一个boolean值
          }).margin(10).width('90%')

        Button("打印内容", { type: ButtonType.Normal }).onClick(async () => {
          if (this.connecd === false) {
            promptAction.showToast({ message: "请检查USB打印机是否接入" })
            return;
          }
          promptAction.showToast({ message: "开始打印，请稍后......" })
          // let devicepipe: usb.USBDevicePipe = usb.connectDevice(this.selectedDevice);
          let usbDevice: usb.USBDevice = usb.getDevices()[0];
          let usbPrinter = PrinterInstance.getPrinterInstance(usbDevice);
          let buffer = stringToUint8Array(this.textAreaContent);
          usbPrinter.writeUint8ArrayDataToPrinter(buffer);
          // let writeLength = usbPrinter.writeDataToPrinter(buffer);
          // let writeLength = await bulkTransfer(devicepipe, outEndPoint!, buffer, 5000);
          // console.log("writeLength:" + writeLength);
          promptAction.showToast({ message: "小票打印完成" })
        }).margin(10).width('90%')
        Button("打印模板小票", { type: ButtonType.Normal }).onClick(async () => {

          let usbDevice: usb.USBDevice | null = getUsbPrinter();
          if (usbDevice === null) {
            promptAction.showToast({ message: "请检查USB打印机是否接入" })
            return;
          }
          promptAction.showToast({ message: "开始打印，请稍后......" })
          //写数据
          console.log("printNote 开始打印:");
          // let buffer = printNote();
          // let writeLength = await bulkTransfer(devicepipe, outEndPoint!, buffer, 5000);
          // console.log("printNote  writeLength 打印小票:" + writeLength);

          // usbPrint(usbDevice);
          // promptAction.showToast({ message: "小票打印完成" })
        }).margin(10).width('90%')
        Button("打印图片", { type: ButtonType.Normal }).onClick(async () => {

          let usbDevice: usb.USBDevice | null = getUsbPrinter();
          if (usbDevice === null) {
            promptAction.showToast({ message: "请检查USB打印机是否接入" })
            return;
          }
          // let devicepipe: usb.USBDevicePipe = usb.connectDevice(this.selectedDevice);
          // let interfaces: usb.USBInterface = this.selectedDevice.configs[0].interfaces[0];
          promptAction.showToast({ message: "开始打印，请稍后......" })
          //图片
          console.log("getImageBuffer 开始打印图片:");

        }).margin(10).width('90%')
      }


      .width('100%')

    }
    .height('100%')
  }
}