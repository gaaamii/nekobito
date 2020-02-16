export default class FileHandleManager {
  constructor() {}

  get fileHandle() {
    return this._fileHandle;
  }

  set fileHandle(fileHandle) {
    this.writer = null;
    this._fileHandle = fileHandle;
  }

  getFile() {
    return this._fileHandle.getFile();
  }

  async writeFile(contents) {
    this.writer = await this.fileHandle.createWriter();
    await this.writer.write(0, contents);
    await this.writer.close();
  }
}
