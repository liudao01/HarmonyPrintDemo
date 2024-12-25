import {BasePrinterPort} from './BasePrintPort'
class BluetoothPort implements BasePrinterPort{
  constructor(portType:string) {
    console.log('BluetoothPort Constructor');
  }
  async open():  Promise<boolean>  {
    console.log('open BT Printer success');
    return true;
  }

  close(): void {
    console.log('close BT Printer');
  }

  async write(data: number[]): Promise<number>  {
    console.log('success to write Data to BT Printer');
    return 0;
  }

  async writeUint8Array(data: Uint8Array): Promise<number>  {
    console.log('success to write Data to BT Printer');
    return 0;
  }
  read(data: number[]): number {
    console.log('success to read Data from BT Printer');
    return 0;
  }

}
//导出类
export {BluetoothPort};