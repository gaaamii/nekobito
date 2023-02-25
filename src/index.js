import "regenerator-runtime";
import "./styles/main.css";
import "./styles/themes/dark.css";
import "./styles/themes/white.css";
import registerServiceWorker from "./registerServiceWorker";
import runElmApp from "./runElmApp";

runElmApp();

// Enable Service Worker to run as a PWA app
registerServiceWorker();
