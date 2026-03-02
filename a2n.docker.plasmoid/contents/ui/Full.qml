import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import org.kde.plasma.plasmoid
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

import "components" as Components

PlasmaExtras.Representation {
  id: full

  focus: true
  anchors.fill: parent
  Layout.minimumHeight: 200
  Layout.minimumWidth: 200
  Layout.maximumWidth: 400

  property string list: ""
  property var usage: []
  property string totalActive: "0"
  property string total: "0"
  property bool isActive: false
  property bool isUpdating: false
  property bool onError: false
  property string errorMessage: ""

  Connections {
    target: cmdSource

    function onSigIsUpdating(status) {
      full.isUpdating = status
    }

    function onSigIsActive(active) {
      full.isActive = active
      if (!active) dockerListModel.clear() // clear the list on exit
    }

    function onSigCountAll(count) {
      full.total = count
    }

    function onSigCountActive(count) {
      full.totalActive = count
    }

    function onSigList(list) {
      full.list = list
      injectList(list)
    }

    function onSigUsage(usage) {
      updateUsageOnly(usage)
    }

    function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
      if (stderr !== '') {
        full.onError = true
        full.errorMessage = stderr
      } else {
        full.onError = false
        full.errorMessage = ""
      }
    }
  }

  // !isActive force refresh when we open the full view
  function refresh() {
    if (!isActive) main.checkIsActive()
  }

  function injectList(list) {
    // do nothing if no list, 'cause we show nothing
    if (!list) return

    const lines = list.split("\n")
    const datas = []
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      if (line.trim() !== "") {
        try {
          const containerData = JSON.parse(line)
          const usageIndex = full.usage.findIndex(el => el.ID === containerData.ID)
          const usage = usageIndex >= 0 ? full.usage[usageIndex] : null
          datas.push({
            "name": containerData.Names || "unknown",
            "id": containerData.ID || "unknown",
            "status": containerData.Status || "unknown",
            "state": containerData.State || "unknown",
            "isRunning": containerData.State === "running",
            "image": containerData.Image || "unknown",
            "localVolumes": containerData.LocalVolumes || "unknown",
            "networks": containerData.Networks || "unknown",
            "ports": containerData.Ports || "unknown",
            "size": containerData.Size || "unknown",
            "mem": usage ? usage.MemPerc : "",
            "cpu": usage ? usage.CPUPerc : "",
            "blockio": usage ? usage.BlockIO : "",
            "memU": usage ? usage.MemUsage : "",
            "netio": usage ? usage.NetIO : "",
            "pid": usage ? usage.PIDs : ""
          })
        } catch (error) {
          console.log("Error parsing JSON line:", error)
        }
      }
    }
    datas.sort((a, b) => {
      if (a.isRunning !== b.isRunning) {
        return b.isRunning - a.isRunning
      }
      return a.name.localeCompare(b.name)
    })

    // first load: nothing to diff
    if (dockerListModel.count === 0) {
      dockerListModel.append(datas)
      return
    }

    // remove stale items (backward to avoid index shifting)
    for (let i = dockerListModel.count - 1; i >= 0; i--) {
      if (!datas.find(d => d.id === dockerListModel.get(i).id)) {
        dockerListModel.remove(i)
      }
    }

    // update existing items in-place, insert new ones
    for (let i = 0; i < datas.length; i++) {
      let modelIndex = -1
      for (let j = 0; j < dockerListModel.count; j++) {
        if (dockerListModel.get(j).id === datas[i].id) {
          modelIndex = j
          break
        }
      }
      if (modelIndex >= 0) {
        dockerListModel.set(modelIndex, datas[i])
      } else {
        dockerListModel.insert(i, datas[i])
      }
    }

    // re-sort using move() — preserves delegates
    for (let i = 0; i < datas.length; i++) {
      for (let j = 0; j < dockerListModel.count; j++) {
        if (dockerListModel.get(j).id === datas[i].id) {
          if (j !== i) dockerListModel.move(j, i, 1)
          break
        }
      }
    }
  }

  // only update the relevant data on the list
  function updateUsageOnly(usage) {
    if (!usage || dockerListModel.count === 0) return
    const usageDatas = []
    const lines = usage.split("\n")
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      if (line !== "") {
        try {
          usageDatas.push(JSON.parse(line))
        } catch(e) {
          console.log("Error parsing usage JSON:", e)
        }
      }
    }
    full.usage = usageDatas
    for (let i = 0; i < dockerListModel.count; i++) {
      const itemId = dockerListModel.get(i).id
      const usageIndex = usageDatas.findIndex(el => el.ID === itemId)
      const usage = usageIndex >= 0 ? usageDatas[usageIndex] : ""
      dockerListModel.setProperty(i, "mem", usage ? usage.MemPerc : "")
      dockerListModel.setProperty(i, "cpu", usage ? usage.CPUPerc : "")
      dockerListModel.setProperty(i, "blockio", usage ? usage.BlockIO : "")
      dockerListModel.setProperty(i, "memU", usage ? usage.MemUsage : "")
      dockerListModel.setProperty(i, "netio", usage ? usage.NetIO : "")
      dockerListModel.setProperty(i, "pid", usage ? usage.PIDs : "")
    }
  }

  ListModel { id: dockerListModel }

  // topbar
  RowLayout {
    id: header
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    width: parent.width

    RowLayout {
      Layout.alignment: Qt.AlignLeft
      spacing: 0

      Controls.Label {
        height: Kirigami.Units.iconSizes.medium
        text: 'Active ' + full.totalActive + ' - Overall ' + full.total
      }
    }

    RowLayout {
      Layout.alignment: Qt.AlignRight
      spacing: 0

      PlasmaComponents.BusyIndicator {
        id: busyIndicatorCheckUpdatesIcon
        visible: isUpdating
      }

      PlasmaComponents.ToolButton {
        height: Kirigami.Units.iconSizes.medium
        icon.name: "media-playback-start"
        display: PlasmaComponents.AbstractButton.IconOnly
        text: i18n("Start Docker service")
        visible: !isActive && !isUpdating
        onClicked: cmdSource.exec(main.cmdStartDocker)
        PlasmaComponents.ToolTip {
          text: parent.text
        }
      }

      PlasmaComponents.ToolButton {
        height: Kirigami.Units.iconSizes.medium
        icon.name: "media-playback-stop"
        display: PlasmaComponents.AbstractButton.IconOnly
        text: i18n("Stop Docker service")
        visible: isActive && !isUpdating
        onClicked: cmdSource.exec(main.cmdStopDocker)
        PlasmaComponents.ToolTip {
          text: parent.text
        }
      }

      PlasmaComponents.ToolButton {
        id: checkUpdatesIcon
        height: Kirigami.Units.iconSizes.medium
        icon.name: "view-refresh-symbolic"
        display: PlasmaComponents.AbstractButton.IconOnly
        text: i18n("Refresh list")
        visible: !isUpdating
        onClicked: main.checkIsActive()
        PlasmaComponents.ToolTip {
          text: parent.text
        }
      }
    }
  }

  // separator
  Rectangle {
    id: headerSeparator
    anchors.top: header.bottom
    width: parent.width
    height: 1
    color: Kirigami.Theme.textColor
    opacity: 0.25
    visible: true
  }

  // page view for the list
  PlasmaComponents.ScrollView {
    id: scrollView
    visible: !isUpdating && !onError
    anchors.top: headerSeparator.bottom
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    contentItem: ListView {
      id: packageView
      anchors.fill: parent
      focus: true
      currentIndex: -1
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      highlight: PlasmaExtras.Highlight {}
      highlightMoveDuration: Kirigami.Units.shortDuration
      highlightResizeDuration: Kirigami.Units.shortDuration
      model: dockerListModel
      delegate: Components.DockerListItem {}
      Keys.onDownPressed: event => {
        scrollView.incrementCurrentIndex();
        scrollView.currentItem.forceActiveFocus();
      }
      Keys.onUpPressed: event => {
        if (scrollView.currentIndex === 0) {
          scrollView.currentIndex = -1;
        } else {
          event.accepted = false;
        }
      }
    }
  }

  PlasmaExtras.PlaceholderMessage {
    id: upToDateLabel
    text: i18n("Docker is not running !")
    anchors.centerIn: parent
    visible: !isActive && !onError
  }

  // if an error happened
  Controls.Label {
    id: errorLabel
    width: parent.width
    text: i18n("Hu ho something is wrong\n" + errorMessage)
    anchors.centerIn: parent
    visible: onError
    wrapMode: Text.Wrap
  }

  // loading indicator
  PlasmaComponents.BusyIndicator {
    id: busyIndicator
    anchors.centerIn: parent
    visible: isUpdating  && !onError
  }

  Component.onCompleted: {
    refresh()
  }
}
