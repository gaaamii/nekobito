const PICKER_OPTIONS = {
  types: [
    {
      accept: {
        'text/markdown': ['.md'],
        'text/plain': ['.txt'],
      }
    }
  ]
}

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

  async openFile() {
    const [fileHandle] = await window.showOpenFilePicker(PICKER_OPTIONS);
    this.fileHandle = fileHandle
    const file = await this.getFile();
    return file
  }

  async createFile(text) {
    const fileHandle = await window.showSaveFilePicker(PICKER_OPTIONS);
    this.fileHandle = fileHandle;
    const file = await this.getFile();
    await this.writeFile(text);
    return file
  }

  async updateFile(contents) {
    if (!this.fileHandle) {
      const fileHandle = await window.showSaveFilePicker();
      this.fileHandle = fileHandle;
    }
    await this.writeFile(contents);
    const file = await this.getFile();
    return file
  }

  async newFile() {
    const fileHandle = await window.showSaveFilePicker(PICKER_OPTIONS);
    this.fileHandle = fileHandle;
    const file = await this.getFile();
    return file
  }

  async writeFile(contents) {
    if (this.fileHandle) {
      const writable = await this.fileHandle.createWritable();
      await writable.write(contents);
      await writable.close();
    }
  }
}
