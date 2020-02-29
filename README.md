# Nekobito
![](https://github.com/gaaamii/nekobito/workflows/Run%20Tests/badge.svg)

Nekobito is a browser-based markdown editor.

![screenshot of Nekobito](https://raw.githubusercontent.com/gaaamii/nekobito/master/nekobito_screen.png)

## Usage
* Open https://nekobito.netlify.com
* Write markdown.

## Features

###  Markdown Preview
You can see a preview of markdown text written in textarea.

### PWA Support
If you use Google Chrome, you can install Nekobito as a progressive web app.

### [Experimental] Save text in your local file
Nekobito is providing features to edit your local file. But it is experimental because Nekobito uses [Native File System API](https://wicg.github.io/native-file-system/) for it. You have to use the browser which supports the API, and enable the API, to edit local files on Nekobito.

## Development

### Install node modules
```
npm i
```

### Start dev server

```
npm run start
```

### Build
```
npm run build
```
