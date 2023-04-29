import FileHandleManager from "./FileHandleManager";
import { Elm } from "../elm/Main.elm";

const runElmApp = () => {
  const storedState = localStorage.getItem("elm-editor-save");
  const startingState = storedState ? JSON.parse(storedState) : null;
  const node = document.getElementById("root");
  const app = Elm.Main.init({ node: node, flags: startingState });
  const fileHandleManager = new FileHandleManager();

  const appState = {
    filename: "",
    hasUnsavedChange: false,
  };

  const setDocumentTitle = () => {
    const { filename, hasUnsavedChange } = appState;
    document.title = `${hasUnsavedChange ? "* " : ""}${
      filename ? `${filename} - ` : ""
    }Nekobito`;
  };

  const handleLoadFile = (file) => {
    appState.filename = file.name;
    appState.hasUnsavedChange = false;
    setDocumentTitle();
  };

  //
  // ports
  //
  app.ports.setStorage.subscribe((state) => {
    localStorage.setItem("elm-editor-save", JSON.stringify(state));
  });

  // update file
  app.ports.writeFile.subscribe(async (contents) => {
    const file = await fileHandleManager.updateFile(contents);
    handleLoadFile(file);
    app.ports.fileWritten.send(true);
  });

  // open file
  app.ports.openFile.subscribe(async () => {
    const file = await fileHandleManager.openFile();
    const { name, lastModified } = file;
    const text = await file.text();

    handleLoadFile(file);
    app.ports.fileLoaded.send({
      name,
      lastModified,
      text,
    });
  });

  // new file
  app.ports.newFile.subscribe(async () => {
    const file = await fileHandleManager.newFile();
    handleLoadFile(file);

    const { name, lastModified } = file;
    app.ports.fileBuilt.send({
      name,
      lastModified,
      text: "",
    });
  });

  app.ports.changeText.subscribe(() => {
    appState.hasUnsavedChange = true;
    setDocumentTitle();
  });

  // create a new file
  app.ports.saveFile.subscribe(async (text) => {
    const file = await fileHandleManager.createFile(text);
    handleLoadFile(file);
    const { name, lastModified } = file;
    app.ports.fileBuilt.send({
      name,
      lastModified,
      text,
    });
  });
};

export default runElmApp;
