'use strict';
const electron = require('electron');
const app = electron.app;
const Tray = electron.Tray;
const Menu = electron.Menu;

// report crashes to the Electron project
require('crash-reporter').start();

// adds debug features like hotkeys for triggering dev tools and reload
require('electron-debug')();

// prevent window being garbage collected
let mainWindow;

function onClosed() {
	// dereference the window
	// for multiple windows store them in an array
	mainWindow = null;
}

function createMainWindow() {
	const win = new electron.BrowserWindow({
		width: 1700,
		height: 900
	});

	//require("coffee-script").register();
	win.loadURL(`file://${__dirname}/views/main.html`);
	win.on('closed', onClosed);

	return win;
}

app.on('window-all-closed', () => {
	if (process.platform !== 'darwin') {
		app.quit();
	}
});

app.on('activate', () => {
	if (!mainWindow) {
		mainWindow = createMainWindow();
	}
});

var appIcon = null;
app.on('ready', () => {
	var appIcon = new Tray('./dev/logo_24.png');
	var contextMenu = Menu.buildFromTemplate([
    { label: 'Show window' },
		{ label: 'Settings'},
    { label: 'About Flux-Capacitor'},

  ]);
  appIcon.setToolTip('This is my application.');
  appIcon.setContextMenu(contextMenu);
	mainWindow = createMainWindow();

});
