import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var storedState = localStorage.getItem('elm-editor-save');
var startingState = storedState ? JSON.parse(storedState) : null;

var node = document.getElementById('root');
var app = Main.embed(node, startingState);
app.ports.setStorage.subscribe(function(state) {
  localStorage.setItem('elm-editor-save', JSON.stringify(state));
  console.info(state);
});

registerServiceWorker();
