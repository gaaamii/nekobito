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

//
// ports
//
app.ports.setStorage.subscribe((state) => {
  localStorage.setItem('elm-editor-save', JSON.stringify(state));
});

app.ports.writeFile.subscribe(async (contents) => {
  await fileHandleManager.writeFile(contents);
  app.ports.fileWritten.send(true);
});

app.ports.openFile.subscribe(async () => {
  fileHandleManager.fileHandle = await window.chooseFileSystemEntries();
  const file = await fileHandleManager.getFile();
  const text = await file.text();
  const { name, lastModified } = file
  app.ports.fileLoaded.send({
    name,
    lastModified,
    text,
  });
  document.title = `${name} - Nekobito`
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
