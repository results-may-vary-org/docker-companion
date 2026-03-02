import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
  id: main

  property int intervalConfig: plasmoid.configuration.updateInterval
  property bool dockerIsActive: false
  property string cmdIsActive: plasmoid.configuration.checkActiveCommand
  property string cmdListActiveDocker: plasmoid.configuration.countActiveCommand
  property string cmdListAllDocker: plasmoid.configuration.countAllCommand
  property string cmdListDocker: plasmoid.configuration.listCommand
  property string cmdStartDocker: plasmoid.configuration.startCommand
  property string cmdStopDocker: plasmoid.configuration.stopServiceCommand
  property string cmdStopSocket: plasmoid.configuration.stopSocketCommand // call when stdout of stopdocker is catch
  property string startOneDocker: plasmoid.configuration.startOneCommand
  property string stopOneDocker: plasmoid.configuration.stopOneCommand

  QtObject {
    id: done
    property bool countAll: false
    property bool countActive: false
    property bool list: false
  }

  function checkIsActive() {
    cmdSource.exec(cmdIsActive)
  }

  // the brain of the widget
  Plasma5Support.DataSource {
    id: cmdSource
    engine: "executable"
    connectedSources: []

    onNewData: function (sourceName, data) {
      const exitCode = data["exit code"];
      const exitStatus = data["exit status"]
      const stdout = data["stdout"]
      const stderr = data["stderr"]
      exited(sourceName, exitCode, exitStatus, stdout, stderr)
      disconnectSource(sourceName)
    }

    onSourceConnected: function (source) {
      sigIsUpdating(true)
      connected(source)
    }

    onExited: function (cmd, exitCode, exitStatus, stdout, stderr) {
      if (cmd === cmdIsActive) {
        let response = stdout.replace(/\n/g, '')

        main.dockerIsActive = response === "active"
        sigIsActive(main.dockerIsActive)

        if (main.dockerIsActive) {
          cmdSource.exec(cmdListActiveDocker)
          cmdSource.exec(cmdListAllDocker)
          cmdSource.exec(cmdListDocker)
        }
      }

      if (main.dockerIsActive && cmd === cmdListAllDocker) {
        sigCountAll(stdout.replace(/\n/g, ''))
        done.countAll = true
      }

      if (main.dockerIsActive && cmd === cmdListActiveDocker) {
        sigCountActive(stdout.replace(/\n/g, ''))
        done.countActive = true
      }

      if (main.dockerIsActive && cmd === cmdListDocker) {
        sigList(stdout)
        done.list = true
      }

      if (cmd === cmdStopDocker) {
        // stderr is mostly alway a warning for the socket
        cmdSource.exec(cmdStopSocket)
      }

      // in any other case than refresh action we refresh the list
      if (cmd !== cmdListActiveDocker && cmd !== cmdListAllDocker && cmd !== cmdListDocker) {
        main.checkIsActive()
      }

      if (done.list && done.countAll && done.countActive) {
        done.list = false
        done.countActive = false
        done.countAll = false
      }

      sigIsUpdating(false)
    }

    // execute the given cmd
    function exec(cmd: string) {
      if (!cmd) return
      connectSource(cmd)
    }

    signal sigIsUpdating(bool status)
    signal sigIsActive(bool active)
    signal sigCountAll(string count)
    signal sigCountActive(string count)
    signal sigList(string list)
    signal connected(string source)
    signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
  }

  // execute function count each updateInterval minute
  Timer {
    id: timer
    interval: intervalConfig * 1000 // intervalConfig is in second
    running: true
    repeat: true
    triggeredOnStart: true // trigger on start for a first check
    onTriggered: main.checkIsActive()
  }

  Plasmoid.status: main.dockerIsActive ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus

  // map the UI
  compactRepresentation: Compact {}
  fullRepresentation: Full {}

  // map the context menu
  Plasmoid.contextualActions: [
    PlasmaCore.Action {
      text: i18n("Refresh")
      icon.name: "view-refresh-symbolic"
      onTriggered: main.checkIsActive()
    },
    PlasmaCore.Action {
      text: i18n("Start Docker")
      icon.name: "media-playback-start"
      enabled: !main.dockerIsActive
      onTriggered: cmdSource.exec(cmdStartDocker)
    },
    PlasmaCore.Action {
      text: i18n("Stop Docker")
      icon.name: "media-playback-stop"
      enabled: main.dockerIsActive
      onTriggered: cmdSource.exec(cmdStopDocker)
    }
  ]

  // load the tooltip
  toolTipItem: Loader {
    id: tooltipLoader
    Layout.minimumWidth: item ? item.implicitWidth : 0
    Layout.maximumWidth: item ? item.implicitWidth : 0
    Layout.minimumHeight: item ? item.implicitHeight : 0
    Layout.maximumHeight: item ? item.implicitHeight : 0
    source: "Tooltip.qml"
  }

  Component.onCompleted: {}
}
