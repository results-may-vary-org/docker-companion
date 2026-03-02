import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Templates as T

import org.kde.kquickcontrolsaddons as KQuickControlsAddons
import org.kde.coreaddons as KCoreAddons
import org.kde.kcmutils as KCMUtils

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.plasmoid

PlasmaExtras.ExpandableListItem {
  id: dockerItem

  required property var model
  required index

  property string startOneDocker: plasmoid.configuration.startOneCommand
  property string stopOneDocker: plasmoid.configuration.stopOneCommand

  property var iconMapping: {
    "ID": "username-copy",
    "Image": "kpackagekit-updates",
    "Status": "dialog-information",
    "State": model.isRunning ? "media-playback-start" : "media-playback-stop",
    "Size": "transform-scale",
    "Volumes": "disk-quota",
    "Networks": "network-wired-activated",
    "Ports": "kdeconnect-tray"
  }

  KQuickControlsAddons.Clipboard {
    id: clipboard
  }

  function copy(text) {
    clipboard.content = text
  }

  // header
  icon: iconMapping.State
  allowStyledText: true
  title: "<font color='"+(model.isRunning ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor)+"'>"+model.name+"</font>"
  subtitle: model.id

  isBusy: mainWindow.expanded && full.isUpdating

  // btn next to header
  defaultActionButtonAction: Action {
    id: stateChangeButton
    enabled: true
    icon.name: model.isRunning ? "media-playback-stop" : "media-playback-start"
    text: model.isRunning ? i18n("Stop") : i18n("Start")
    onTriggered: model.isRunning ? cmdSource.exec(`${stopOneDocker} ${model.id}`) : cmdSource.exec(`${startOneDocker} ${model.id}`)
  }
  showDefaultActionButtonWhenBusy: false

  // list of btn for infos
  contextualActions: [
    Action {
      text: `ID: ${model.id}`
      icon.name: iconMapping["ID"]
      onTriggered: copy(model.id)
    },
    Action {
      text: `Image: ${model.image}`
      icon.name: iconMapping["Image"]
      onTriggered: copy(model.image)
    },
    Action {
      text: `Status: ${model.status}`
      icon.name: iconMapping["Status"]
      onTriggered: copy(model.status)
    },
    Action {
      text: `Size: ${model.size}`
      icon.name: iconMapping["Size"]
      onTriggered: copy(model.size)
    },
    Action {
      text: `Local vlm: ${model.localVolumes}`
      icon.name: iconMapping["Volumes"]
      onTriggered: copy(model.localVolumes)
    },
    Action {
      text: `Networks: ${model.networks}`
      icon.name: iconMapping["Networks"]
      onTriggered: copy(model.networks)
    },
    Action {
      text: `Ports: ${model.ports}`
      icon.name: iconMapping["Ports"]
      onTriggered: copy(model.ports)
    }
  ]

  // separator
  Rectangle {
    id: headerSeparator
    anchors.bottom: parent.bottom
    width: parent.width
    height: 1
    color: Kirigami.Theme.textColor
    opacity: 0.25
    visible: true
  }
}
