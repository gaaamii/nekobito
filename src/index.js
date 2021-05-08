import "regenerator-runtime";
import "./styles/main.css";
import "./styles/themes/dark.css";
import "./styles/themes/white.css";
import registerServiceWorker from "./registerServiceWorker";
import runElmApp from "./runElmApp";

runElmApp();

// TODO: Use elm/browser to implement this
window.onload = function () {
  requestAnimationFrame(() => {
    document.getElementsByTagName("textarea")[0].focus();
  });
};

// Enable Service Worker to run as a PWA app
registerServiceWorker();
