import router from '@ohos.router';
import usb from '@ohos.usb';
import promptAction from '@ohos.promptAction';
import { PrinterInstance } from './PrinterInstance';
import { cutPaper, getUsbPrinter, printNote, pushArray, stringToUint8Array, USBPort } from './USBPort';
import resourceManager from '@ohos.resourceManager';
import image from '@ohos.multimedia.image';
import util from '@ohos.util'; // 需要使用util模块函数对文件编码

let PaperWidth = 576;

// function pushArray(numberArray: number[]) {
//
//   let uint8Array = new Uint8Array(numberArray.length);
//   for (let i = 0; i < numberArray.length; i++) {
//     uint8Array[i] = numberArray[i] as number as Uint8Array[number];
//   }
//   return uint8Array;
//
// }

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

        TextArea({ placeholder: "请输入内容" })
          .width('90%')
          .height('15%')
          .margin(10)

          .onChange((value: string) => {
            this.textAreaContent = value;
          })
        Button(this.connecd === true ? "已连接" : "点击连接", { type: ButtonType.Normal })
          .onClick(async () => {
            if (this.connecd === true) {
              let usbPrinter = PrinterInstance.getPrinterInstance("usb");
              (await usbPrinter).closeConnection();
              this.connecd = false;
              return;
            }

            let usbPrinter = PrinterInstance.getPrinterInstance("usb");
            // usbPrinter.
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
          let usbPrinter = PrinterInstance.getPrinterInstance("usb");
          let buffer = stringToUint8Array(this.textAreaContent);
          usbPrinter.writeUint8ArrayDataToPrinter(buffer);

        }).margin(10).width('90%')
        Button("打印模板小票", { type: ButtonType.Normal }).onClick(async () => {
          if (this.connecd === false) {
            promptAction.showToast({ message: "请检查USB打印机是否接入" })
            return;
          }
          let buffer = await printNote();
          let usbPrinter = PrinterInstance.getPrinterInstance("usb");

          usbPrinter.writeUint8ArrayDataToPrinter(buffer);
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

          if (this.connecd === false) {
            promptAction.showToast({ message: "请检查USB打印机是否接入" })
            return;
          }
          let usbPrinter = PrinterInstance.getPrinterInstance("usb");
          // let devicepipe: usb.USBDevicePipe = usb.connectDevice(this.selectedDevice);
          // let interfaces: usb.USBInterface = this.selectedDevice.configs[0].interfaces[0];
          promptAction.showToast({ message: "开始打印，请稍后......" })
          //图片
          console.log("getImageBuffer 开始打印图片 请稍后:");
          let imgBuffer: Uint8Array | null = await getImageBuffer();
          if (imgBuffer !== null) {
            console.log("getImageBuffer 开始打印:");
            let usbPrinter = PrinterInstance.getPrinterInstance("usb");
            usbPrinter.writeUint8ArrayDataToPrinter(imgBuffer);
          } else {
            console.log("getImageBuffer 数据为空:");
          }

        }).margin(10).width('90%')
        Button("切刀", { type: ButtonType.Normal }).onClick(async () => {
          if (this.connecd === true) {
            // //关闭与打印机的连接
            let data: number[] | null = cutPaper(66, 50)
            if (data !== null) {
              console.log("cutPaper 开始打印 data :" + JSON.stringify(data));
              let usbPrinter = PrinterInstance.getPrinterInstance("usb");

              usbPrinter.writeUint8ArrayDataToPrinter(pushArray(data));
            } else {
              console.log("getImageBuffer 数据为空:");
            }
          } else {
            promptAction.showToast({ message: "当前USB打印机未接入" })
          }

        }).margin(10).width('90%')
        Button("关闭连接", { type: ButtonType.Normal }).onClick(async () => {
          if (this.connecd === true) {
            // //关闭与打印机的连接
            let usbPrinter = PrinterInstance.getPrinterInstance("usb");
            (await usbPrinter).closeConnection();
            this.connecd = false;
          } else {
            promptAction.showToast({ message: "当前USB打印机未接入" })
          }

        }).margin(10).width('90%')
      }
      .width('100%')
    }
    .height('100%')
  }
}

function getImageBuffer(): Uint8Array | PromiseLike<Uint8Array> {
  throw new Error('Function not implemented.');
}
