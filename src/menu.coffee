t = require "../lib/view.tFactory"
#ipcMain = require('electron').ipcMain

module.exports =
  [
    {
    label: t.menu.folders.label
    submenu:
      [
        {label: t.menu.folders.addFolder
        click: (item, win) ->
          win.send "addFolder"},
        {label: t.menu.folders.reloadFolders
        accelerator: 'CmdOrCtrl+Shift+R'
        click: (item, win) ->
          win.send "reloadFolders"},
        {label: t.menu.folders.commitAll
        accelerator: 'CmdOrCtrl+Shift+A'
        click: (item, win) ->
          win.send "commitAll"}
      ]
    }
    {
    label: 'Edit'
    submenu:
      [
        label: 'Settings'
        command: 'settings'
      ]
    }
  ]
