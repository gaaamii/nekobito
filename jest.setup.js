const fs = require('fs').promises;
const { execSync } = require('child_process')

const HTML_FILENAME = execSync("find build/index.html | head -1").toString().trim()
if (!HTML_FILENAME) {
  throw "HTML file is empty. Please build by npm run build before running test."
}

const JS_FILENAME = execSync("find build/*.js | head -1").toString().trim() // "build/index.xxx.js"
if (!JS_FILENAME) {
  throw "JS file is empty. Please build by npm run build before running test."
}

async function runElmApp() {
  // reset all DOM
  document.getElementsByTagName('body')[0].innerHTML = ''; 

  // load from file
  const htmlString = await fs.readFile(HTML_FILENAME, 'utf-8')
  const jsString = await fs.readFile(JS_FILENAME, 'utf-8')

  // parse DOM and append to body
  const dom = new DOMParser().parseFromString(htmlString, 'text/html')
  const root = dom.querySelector('#root')
  document.body.appendChild(root)

  // eval js
  eval(jsString)

  // return DOM
  return root
}

global.beforeEach(async () => {
  await runElmApp()
})