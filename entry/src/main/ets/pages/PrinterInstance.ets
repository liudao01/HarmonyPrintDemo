import usb from '@ohos.usb';
import { USBPort } from './USBPort'
import { BluetoothPort } from './BluetoothPort'
import { BasePrinterPort } from './BasePrintPort'

class PrinterInstance {
  private static mPrinter: PrinterInstance | null = null;
  private myPrinterPort: BasePrinterPort;

  private constructor(portType: usb.USBDevice | string) {
    if (typeof portType === 'string') {
      console.log('创建一个蓝牙打印机' + typeof portType);
      this.myPrinterPort = new BluetoothPort(portType);
    } else {
      console.log('创建一个usb打印机' + typeof portType);
      this.myPrinterPort = new USBPort(portType);
    }
  }

  // public static async getPrinterInstance(portType:usb.USBDevice|string): Promise<PrinterInstance> {
  //   console.log("getPrinterInstance start...");
  //   let lock: utils.locks.AsyncLock = utils.locks.AsyncLock.request('SingletonClass');
  //   return await lock.lockAsync(() => {
  //     console.log("getPrinterInstance in...");
  //
  //     if (!PrinterInstance.mPrinter) {
  //       console.log("new ...");
  //       PrinterInstance.mPrinter = new PrinterInstance(portType);
  //     }else {
  //       console.log("already has a instance ...");
  //     }
  //     return PrinterInstance.mPrinter;
  //   }, ArkTSUtils.locks.AsyncLockMode.EXCLUSIVE);
  // }
  //


  public static getPrinterInstance(portType: usb.USBDevice | string): PrinterInstance {
    console.log("getPrinterInstance start...");
    if (PrinterInstance.mPrinter === null) {
      console.log("new ...");
      PrinterInstance.mPrinter = new PrinterInstance(portType);
    } else {
      console.log("already has a instance ...");
    }
    return PrinterInstance.mPrinter;

  }

  public openConnection(): Promise<boolean> {
    return this.myPrinterPort.open();
  }

  public closeConnection(): void {
    return this.myPrinterPort.close();
  }

  public writeDataToPrinter(data: number[]): Promise<number> {
    return this.myPrinterPort.write(new Array());
  }


  public writeUint8ArrayDataToPrinter(data: Uint8Array): Promise<number> {
    return this.myPrinterPort.writeUint8Array(data);
  }

  public readDataFromPrinter(data: number[]): number {
    return this.myPrinterPort.read(new Array());
  }
}

//导出类
export { PrinterInstance }