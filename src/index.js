import './styles/main.css';
import './styles/themes/dark.css';
import './styles/themes/white.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var storedState = localStorage.getItem('elm-editor-save');
var startingState = storedState ? JSON.parse(storedState) : null;
var node = document.getElementById('root');
var app = Main.embed(node, startingState);
app.ports.setStorage.subscribe(function(state) {
  localStorage.setItem('elm-editor-save', JSON.stringify(state));
});

window.onload = function() {
  requestAnimationFrame(() => {
    document.getElementsByTagName("textarea")[0].focus();
  });
}

registerServiceWorker();
