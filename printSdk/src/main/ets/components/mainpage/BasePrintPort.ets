 interface BasePrinterPort{
   open(): Promise<boolean>
   close():void
   write(data:number[]):Promise<number>
   writeUint8Array(data: Uint8Array):Promise<number>
   read(data:number[]):number
}
//导出接口
 export {BasePrinterPort}