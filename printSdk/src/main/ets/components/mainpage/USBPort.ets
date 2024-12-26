import { BasePrinterPort } from './BasePrintPort'
// import usb from '@ohos.usb';
import promptAction from '@ohos.promptAction'
import systemDateTime from '@ohos.systemDateTime';
// 导入USB接口api包。
import usb from '@ohos.usbManager';
import contact from '@ohos.contact';
import image from '@ohos.multimedia.image';

import resourceManager from '@ohos.resourceManager';

// import { util } from '@kit.ArkTS';

//*******************************************USB相关操作************************************************

export function getUsbPrinter(): usb.USBDevice | null {
  let usbDevice: usb.USBDevice | null = null;
  let devicesList: Array<usb.USBDevice> = usb.getDevices();
  if (devicesList.length === 0) {
    console.log(`device list is empty`);
    return null;
  }
  console.log("deviceList.length:" + devicesList.length);
  for (let device of devicesList) {
    if (isUsbPrinter(device)) {
      usbDevice = device;
      break;
    }
  }
  if (usbDevice === null) {
    console.log("there is no usb printer")
    return null;
  }
  console.log(usbDevice.name + ",vid:" + usbDevice.vendorId + ",pid:" + usbDevice.productId);
  return usbDevice;
}

async function usbPrint(usbDevice: usb.USBDevice): Promise<void> {
  let hasRight = await getUsbRight(usbDevice.name);
  console.log("hasRight:" + hasRight);
  if (!hasRight) {
    console.log("fail to get usb device request");
    return;
  }
  let devicepipe: usb.USBDevicePipe = usb.connectDevice(usbDevice);
  let interfaces: usb.USBInterface = usbDevice.configs[0].interfaces[0];

  let ret: number = usb.claimInterface(devicepipe, interfaces, true);
  console.log(`claimInterface = ${ret}`)
  if (ret !== 0) {
    console.log("fail to claimInterface");
    return;
  }
  let endPointsArr: usb.USBEndpoint[] = interfaces.endpoints;
  let outEndPoint: usb.USBEndpoint;
  let inEndPoint: usb.USBEndpoint;
  for (let ep of endPointsArr) {
    if (ep.type === 2) {
      if (ep.direction === 0) {
        outEndPoint = ep;
      } else if (ep.direction === 0x80) {
        inEndPoint = ep;
      }
    }
  }
  //写数据
  // let buffer = printNote();
  // let writeLength = await bulkTransfer(devicepipe, outEndPoint!, buffer, 5000);
  // console.log("writeLength:" + writeLength);
  //
  // let imgBuffer: Uint8Array | null = await getImageBuffer();
  // if (imgBuffer !== null) {
  //   let imgWriteLength = await bulkTransfer(devicepipe, outEndPoint!, imgBuffer, 10000);
  //   console.log("imgWriteLength:" + imgWriteLength);
  // }


  //关闭端口
  let releaseInterfaceResult = usb.releaseInterface(devicepipe, interfaces);
  console.log("releaseInterfaceResult:" + releaseInterfaceResult);
  let closePipeResult = usb.closePipe(devicepipe);
  console.log("closePipeResult:" + closePipeResult);
  // outEndPoint = null;
  // inEndPoint = null;
  // interfaces = null;
  // devicepipe = null;
  // usbDevice = null;
}

async function getUsbRight(usbName: string | null) {
  const result: boolean = await usb.requestRight(usbName);
  console.log("getUsbRight result:" + result);
  return result;
}

// async function read(devicepipe: usb.USBDevicePipe, statusEndpoint: usb.USBEndpoint, queryCommand: Uint8Array): Promise<void> {
//   // 读取
//   let writeLength = await bulkTransfer(devicepipe, statusEndpoint, queryCommand, 5000);
//   console.log("查询命令发送长度: " + writeLength);
// }
async function bulkTransfer(devicepipe: usb.USBDevicePipe, endPoint: usb.USBEndpoint, buffer: Uint8Array,
                            timeout?: number) {
  const result: number = await usb.bulkTransfer(devicepipe, endPoint, buffer, timeout);
  console.log("bulkTransfer result:" + result);
  return result;
}

async function receivePrinterStatus(devicepipe: usb.USBDevicePipe, statusEndpoint: usb.USBEndpoint): Promise<void> {
  // 假设接收状态数据的缓冲区大小，这个大小可能需要根据打印机返回数据的实际情况调整
  let buffer = new Uint8Array(1024);
  console.log("开始: ");
  let readLength = await bulkTransfer(devicepipe, statusEndpoint, buffer, 5000);
  console.log("接收状态信息长度: " + readLength);
  // 根据打印机文档解析状态信息
  if (readLength > 0) {
    // 这里只是示例，实际解析需要根据打印机的状态返回格式
    let statusData = buffer.slice(0, readLength);
    console.log("接收到的状态数据: " + statusData);
    // 假设状态数据的第一个字节表示打印机状态
    // let printerStatus = statusData[0];
    // if (printerStatus === 0) {
    //   console.log("打印机正常");
    // } else if (printerStatus === 1) {
    //   console.log("打印机缺纸");
    // } else {
    //   console.log("打印机状态未知");
    // }
  }
}

function getUsbPrinters(): Array<usb.USBDevice> | null {
  let usbDevice: usb.USBDevice | null = null;
  let devicesList: Array<usb.USBDevice> = usb.getDevices();
  if (devicesList.length === 0) {
    console.log(`device list is empty`);
    return null;
  }
  console.log("deviceList.length:" + devicesList.length);
  return devicesList;
}

function isUsbPrinter(device: usb.USBDevice): boolean {
  console.log("vid:" + device.vendorId + ",pid:" + device.productId);
  let vendorId = device.vendorId;
  let productId = device.productId;
  if ((0x0483 === vendorId && 0x5720 === productId) || (0x067B === vendorId && 0x2305 === productId) ||
    (0x0483 === vendorId && 0x5723 === productId) || (0x0483 === vendorId && 0x5724 === productId) ||
    (0x0484 === vendorId && 0x5724 === productId)) {
    return true;
  } else {
    return false;
  }
}

let outEndPoint: usb.USBEndpoint | null;
let inEndPoint: usb.USBEndpoint | null;
let devicepipe: usb.USBDevicePipe | null;
let interfaces: usb.USBInterface | null;

async function usbConnect(usbDevice: usb.USBDevice): Promise<boolean> {
  let hasRight = await getUsbRight(usbDevice.name);
  console.log("hasRight:" + hasRight);
  if (!hasRight) {
    console.log("fail to get usb device request");
    return false;
  }
  devicepipe = usb.connectDevice(usbDevice);
  interfaces = usbDevice.configs[0].interfaces[0];

  let ret: number = usb.claimInterface(devicepipe, interfaces, true);
  console.log(`claimInterface = ${ret}`)
  if (ret !== 0) {
    console.log("fail to claimInterface");
    return false;
  }
  let endPointsArr: usb.USBEndpoint[] = interfaces.endpoints;
  // let outEndPoint: usb.USBEndpoint;
  // let inEndPoint: usb.USBEndpoint;
  for (let ep of endPointsArr) {
    if (ep.type === 2) {
      if (ep.direction === 0) {
        outEndPoint = ep;
      } else if (ep.direction === 0x80) {
        inEndPoint = ep;
        console.error("开始复制inEndPoint :" + JSON.stringify(inEndPoint));
      }
    }
  }
}

//断开连接
async function usbDisconnect(devicepipe: usb.USBDevicePipe, interfaces: usb.USBInterface): Promise<void> {
  // 释放接口
  let releaseInterfaceResult = usb.releaseInterface(devicepipe, interfaces);
  console.log("releaseInterfaceResult:" + releaseInterfaceResult);
  // 关闭设备管道
  let closePipeResult = usb.closePipe(devicepipe);
  console.log("closePipeResult:" + closePipeResult);
}

class SheetInfoClass {
  title: string;
  action: () => void;
  // 新增点击回调属性
  onDeviceSelected: ((device: usb.USBDevice) => void) | null = null;

  constructor(device: usb.USBDevice) {
    this.title = `${device.name} ${device.productName} \n` || `USB设备\n`;
    this.action = async () => {
      if (isUsbPrinter(device)) {
        if (this.onDeviceSelected) {
          this.onDeviceSelected(device);
        }

      } else {
        // Index.instance.connect = false;
        promptAction.showToast({
          message: ` ${device.name}设备不可用`
        });
      }
    };
  }
}

let selectedDevice: usb.USBDevice | null = null;

export function getDevice() {
  return selectedDevice;
}

async function openUsb(): Promise<boolean> {
  console.log('openUsb');
  console.log('this.selectedDevice');
  return new Promise<boolean>((resolve, reject) => {
    if (selectedDevice !== null) {
      // let devicepipe: usb.USBDevicePipe = usb.connectDevice(this.selectedDevice);
      // let interfaces: usb.USBInterface = this.selectedDevice.configs[0].interfaces[0];
      usbDisconnect(devicepipe, interfaces).then(() => {
        promptAction.showToast({
          message: '已断开连接'
        });
        selectedDevice = null;
      }).catch((error) => {
        console.error("断开连接出现错误:", error);
        promptAction.showToast({
          message: '断开连接失败'
        });
      });
      return true;
    }
    let usbDevices: Array<usb.USBDevice> | null = getUsbPrinters();
    console.log('usbDevices.length' + usbDevices.length);
    if (usbDevices != null) {
      console.log(`usbDevices ${usbDevices.length}`);
      let sheetsData: Array<SheetInfoClass> = usbDevices.map((device) => {
        let sheetInfo = new SheetInfoClass(device);
        console.log('创建');
        //函数赋值
        // 函数赋值：设备选择回调
        sheetInfo.onDeviceSelected = async (device) => {
          selectedDevice = device;
          // 在这里添加连接设备的逻辑
          try {
            console.log('选择设备开始连接');
            await usbConnect(device);
            if (inEndPoint && outEndPoint) {
              selectedDevice = device;
              // promptAction.showToast({
              //   message: `选择了 ${device.name}`
              // });
              console.log(`设备连接成功,选择了 ${device.name}`);
              resolve(true);
            } else {
              promptAction.showToast({
                message: `连接 ${device.name}失败`
              });
              reject(false);
            }
          } catch (error) {
            promptAction.showToast({
              message: `连接 ${device.name}失败`
            });
            reject(false);
          }
        };

        return sheetInfo;
      });
      // 显示 ActionSheet，并等待用户操作
      ActionSheet.show({
        title: '提示',
        message: 'USB列表',
        autoCancel: false,
        alignment: DialogAlignment.Bottom,
        confirm: {
          value: '取消',
          action: () => {
            promptAction.showToast({
              message: '选择取消'
            });
            reject(false);
          }
        },
        sheets: sheetsData
      });
    } else {
      promptAction.showToast({
        message: '未检测到USB设备'
      });
      return false;
    }
  });
}

class USBPort implements BasePrinterPort {
  constructor(portType: string) {
    console.log('USBPort Constructor');
  }

  async open(): Promise<boolean> {

    // usbConnect()
    const result = await openUsb();
    console.log('open USB Printer success' + result);
    return result;
    console.log('open USB Printer success');
    // return true;
  }

  close(): void {
    console.log('close USB Printer');

    usbDisconnect(devicepipe, interfaces).then(() => {
      promptAction.showToast({
        message: '已断开连接'
      });
      selectedDevice = null;
    }).catch((error) => {
      console.error("断开连接出现错误:", error);
      promptAction.showToast({
        message: '断开连接失败'
      });
    });
  }

  pushArray(arr: number[]) {
    return new Uint8Array(arr);
  }

  async writeUint8Array(data: Uint8Array): Promise<number> {
    console.log('success to write Data to USB Printer');
    let writeLength = await bulkTransfer(devicepipe, outEndPoint!, data, 5000);
    return writeLength;
  }

  async write(data: number[]): Promise<number> {
    console.log('write data ' + JSON.stringify(data));
    let buffer = this.pushArray(data)
    console.log('pushArray ' + JSON.stringify(buffer));
    let writeLength = await bulkTransfer(devicepipe, outEndPoint!, buffer, 5000);
    console.log('success to write Data to USB Printer writeLength ' + writeLength);
    return writeLength;
  }

  read(data: number[]): number {
    console.log('success to read Data from USB Printer');
    //
    // async function bulkTransfer(devicepipe: usb.USBDevicePipe, endPoint: usb.USBEndpoint, buffer: Uint8Array,
    //                             timeout?: number) {
    //   const result: number = await usb.bulkTransfer(devicepipe, endPoint, buffer, timeout);
    //   console.log("bulkTransfer result:" + result);
    //   return result;
    // }

    return 0;
  }
}

//导出类
export { USBPort };