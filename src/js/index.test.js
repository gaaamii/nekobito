import { findByRole } from '@testing-library/dom'
import '@testing-library/jest-dom'
const { execSync } = require('child_process')
const fs = require('fs').promises;

const HTML_FILENAME = execSync("find build/index.html | head -1").toString().trim()
if (!HTML_FILENAME) {
  throw "HTML file is empty. Please build by npm run build before running test."
}

const JS_FILENAME = execSync("find build/*.js | head -1").toString().trim() // "build/index.xxx.js"
if (!JS_FILENAME) {
  throw "JS file is empty. Please build by npm run build before running test."
}

async function runElmApp() {
  const htmlString = await fs.readFile(HTML_FILENAME, 'utf-8')
  const jsString = await fs.readFile(JS_FILENAME, 'utf-8')
  const dom = new DOMParser().parseFromString(htmlString, 'text/html')
  const root = dom.querySelector('#root')
  document.body.appendChild(root)
  eval(jsString)
  return root
}

test('Show textarea', async () => {
  const container = await runElmApp()

  const textarea = await findByRole(container, 'textbox')
  expect(textarea).toHaveAttribute("placeholder", "# Markdown text here")
})
