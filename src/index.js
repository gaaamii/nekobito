import './styles/main.css';
import './styles/themes/dark.css';
import './styles/themes/white.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var storedState = localStorage.getItem('elm-editor-save');
var startingState = storedState ? JSON.parse(storedState) : null;
var node = document.getElementById('root');
var app = Elm.Main.init({ node: node, flags: startingState});
app.ports.setStorage.subscribe(function(state) {
  localStorage.setItem('elm-editor-save', JSON.stringify(state));
});

app.ports.syncSetting.subscribe(async function(str) {
  const opts = { type: 'openDirectory' };
  const fileHandle = await window.chooseFileSystemEntries(opts);
  const entries = await fileHandle.getEntries();
  window.app = { fileHandles: [] };
  for await (const entry of entries) {
    const kind = entry.isFile ? 'File' : 'Directory';
    console.log(kind, entry.name);
    console.log(entry);
    if (entry.isFile) {
      window.app.fileHandles.push(entry);
    }
  }

  console.info(window.app.fileHandles)
});

const onAfterInitialRender = () => {
  document.getElementsByTagName("textarea")[0].focus();
  // hide sync button if Native Filesystem API is unavailable.
  const syncBtn = document.getElementById("syncBtn");
  if (syncBtn && !window.chooseFileSystemEntries) {
    syncBtn.style.display = 'none';
  }
}

window.onload = function() {
  requestAnimationFrame(onAfterInitialRender);
}

registerServiceWorker();
