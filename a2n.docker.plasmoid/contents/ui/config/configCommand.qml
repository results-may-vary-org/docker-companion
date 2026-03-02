import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.ScrollablePage {

  id: commandConfigPage

  property alias cfg_updateInterval: updateIntervalSpin.value
  property alias cfg_checkActiveCommand: checkActiveCommandInput.text
  property alias cfg_countActiveCommand: countActiveCommandInput.text
  property alias cfg_countAllCommand: countAllCommandInput.text
  property alias cfg_listCommand: listCommandInput.text
  property alias cfg_startCommand: startCommandInput.text
  property alias cfg_stopServiceCommand: stopServiceCommandInput.text
  property alias cfg_stopSocketCommand: stopSocketCommandInput.text
  property alias cfg_startOneCommand: startOneCommandInput.text
  property alias cfg_stopOneCommand: stopOneCommandInput.text

  ColumnLayout {
    anchors {
      left: parent.left
      top: parent.top
      right: parent.right
    }

    Kirigami.FormLayout {
      wideMode: false
      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "General"
      }
    }

    Kirigami.FormLayout {
      Controls.SpinBox {
        id: updateIntervalSpin
        Kirigami.FormData.label: "Update every: "
        from: 1
        to: 60
        editable: true
        textFromValue: (value) => value + " second(s)"
        valueFromText: (text) => parseInt(text)
      }
    }

    Kirigami.FormLayout {
      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Check & count"
      }
    }

    Kirigami.FormLayout {
      Controls.TextField {
        id: checkActiveCommandInput
        Kirigami.FormData.label: "Check if docker is running command: "
      }
      Controls.TextField {
        id: countActiveCommandInput
        Kirigami.FormData.label: "Count active containers command: "
      }
      Controls.TextField {
        id: countAllCommandInput
        Kirigami.FormData.label: "Count all containers command: "
      }
      Controls.TextField {
        id: listCommandInput
        Kirigami.FormData.label: "List containers command: "
      }
    }

    Kirigami.FormLayout {
      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Docker control"
      }
    }

    Kirigami.FormLayout {
      Controls.TextField {
        id: startOneCommandInput
        Kirigami.FormData.label: "Start one docker command: "
      }
      Controls.TextField {
        id: stopOneCommandInput
        Kirigami.FormData.label: "Stop one docker command: "
      }
    }

    Kirigami.FormLayout {
      Kirigami.Separator {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: "Service control"
      }
    }

    Kirigami.FormLayout {
      Controls.TextField {
        id: startCommandInput
        Kirigami.FormData.label: "Start Docker service command: "
      }
      Controls.TextField {
        id: stopServiceCommandInput
        Kirigami.FormData.label: "Stop Docker service command: "
      }
      Controls.TextField {
        id: stopSocketCommandInput
        Kirigami.FormData.label: "Stop Docker socket command: "
      }
    }
  }
}
