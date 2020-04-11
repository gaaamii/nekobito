import './styles/main.css';
import './styles/themes/dark.css';
import './styles/themes/white.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import FileHandleManager from './FileHandleManager';

const storedState = localStorage.getItem('elm-editor-save');
const startingState = storedState ? JSON.parse(storedState) : null;
const node = document.getElementById('root');
const app = Elm.Main.init({ node: node, flags: startingState});
const fileHandleManager = new FileHandleManager()

const appState = {
  filename: '',
  hasUnsavedChange: false,
}

const setDocumentTitle = () => {
  const { filename, hasUnsavedChange } = appState;
  document.title = `${hasUnsavedChange ? '* ': ''}${filename ? `${filename} - ` : ''}Nekobito`;
}

const handleLoadFile = (file) => {
  appState.filename = file.name;
  appState.hasUnsavedChange = false;
  setDocumentTitle();
}

//
// ports
//
app.ports.setStorage.subscribe((state) => {
  localStorage.setItem('elm-editor-save', JSON.stringify(state));
});

// update file
app.ports.writeFile.subscribe(async (contents) => {
  if (!fileHandleManager.fileHandle) {
    fileHandleManager.fileHandle = await window.chooseFileSystemEntries();
  }
  await fileHandleManager.writeFile(contents);
  const file = await fileHandleManager.getFile();
  handleLoadFile(file);
  app.ports.fileWritten.send(true);
});

// open file
app.ports.openFile.subscribe(async () => {
  const opts = {
    accepts: [{
      extensions: ['md'],
    }],
  };
  fileHandleManager.fileHandle = await window.chooseFileSystemEntries(opts);
  const file = await fileHandleManager.getFile();
  const text = await file.text();
  const { name, lastModified } = file

  handleLoadFile(file);
  app.ports.fileLoaded.send({
    name,
    lastModified,
    text,
  });
});

// new file
app.ports.newFile.subscribe(async () => {
  const opts = {
    type: 'saveFile',
    accepts: [{
      extensions: ['md'],
    }],
  };
  fileHandleManager.fileHandle = await window.chooseFileSystemEntries(opts);
  const file = await fileHandleManager.getFile();

  handleLoadFile(file);

  const { name, lastModified } = file
  app.ports.fileBuilt.send({
    name,
    lastModified,
    text: ''
  });
});

app.ports.changeText.subscribe(() => {
  appState.hasUnsavedChange = true;
  setDocumentTitle();
});

// save as a new file
app.ports.saveFile.subscribe(async (text) => {
  const opts = {
    type: 'saveFile',
    accepts: [{
      extensions: ['md'],
    }],
  };
  fileHandleManager.fileHandle = await window.chooseFileSystemEntries(opts);
  const file = await fileHandleManager.getFile();
  await fileHandleManager.writeFile(text);

  handleLoadFile(file);
  const { name, lastModified } =  file
  app.ports.fileBuilt.send({
    name,
    lastModified,
    text,
  });
});

app.ports.changeText.subscribe(() => {
  appState.hasUnsavedChange = true;
  setDocumentTitle();
});

//
// window lifecycle
//
const onAfterInitialRender = () => {
  document.getElementsByTagName("textarea")[0].focus();
  // hide sync button if Native Filesystem API is unavailable.
  const syncBtn = document.getElementById("openFileButton");
  if (syncBtn && !window.chooseFileSystemEntries) {
    syncBtn.style.display = 'none';
  }
}

window.onload = function() {
  requestAnimationFrame(onAfterInitialRender);
}

//
// service worker setup
//
registerServiceWorker();
