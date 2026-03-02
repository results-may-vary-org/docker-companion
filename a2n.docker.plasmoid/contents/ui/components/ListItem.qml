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

  property string startOneDocker: plasmoid.configuration.startOneCommand
  property string stopOneDocker: plasmoid.configuration.stopOneCommand

  property var iconMapping: {
    "ID": "username-copy",
    "Image": "kpackagekit-updates",
    "Status": "dialog-information",
    "State": isRunning ? "media-playback-start" : "media-playback-stop",
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
  icon: isRunning ? "media-playback-start" : "media-playback-stop"
  allowStyledText: true
  title: "<font color='"+(isRunning ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor)+"'>"+name+"</font>"
  subtitle: id

  // btn next to header
  defaultActionButtonAction: Action {
    id: stateChangeButton
    enabled: true
    icon.name: isRunning ? "media-playback-stop" : "media-playback-start"
    text: isRunning ? i18n("Stop") : i18n("Start")
    onTriggered: isRunning ? cmdSource.exec(`${stopOneDocker} ${id}`) : cmdSource.exec(`${startOneDocker} ${id}`)
  }
  showDefaultActionButtonWhenBusy: false

  // list of btn for infos
  contextualActions: [
    Action {
      text: `ID: ${id}`
      icon.name: iconMapping["ID"]
      onTriggered: copy(id)
    },
    Action {
      text: `Image: ${image}`
      icon.name: iconMapping["Image"]
      onTriggered: copy(image)
    },
    Action {
      text: `Status: ${status}`
      icon.name: iconMapping["Status"]
      onTriggered: copy(status)
    },
    Action {
      text: `Size: ${size}`
      icon.name: iconMapping["Size"]
      onTriggered: copy(size)
    },
    Action {
      text: `Local vlm: ${localVolumes}`
      icon.name: iconMapping["Volumes"]
      onTriggered: copy(localVolumes)
    },
    Action {
      text: `Networks: ${networks}`
      icon.name: iconMapping["Networks"]
      onTriggered: copy(networks)
    },
    Action {
      text: `Ports: ${ports}`
      icon.name: iconMapping["Ports"]
      onTriggered: copy(ports)
    }
  ]

}
