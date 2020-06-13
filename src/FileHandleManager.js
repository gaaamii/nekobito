export default class FileHandleManager {
  constructor() {}

  get fileHandle() {
    return this._fileHandle;
  }

  set fileHandle(fileHandle) {
    this._fileHandle = fileHandle;
  }

  getFile() {
    return this._fileHandle.getFile();
  }

  async writeFile(contents) {
    if (this.fileHandle) {
      const writable = await this.fileHandle.createWritable();
      await writable.write(contents);
      await writable.close();
    }
  }
}
