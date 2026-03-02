import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

ColumnLayout {
  id: tooltip

  property string totalActive: "0"
  property string total: "0"
  property bool isActive: false
  property bool isUpdating: false

  Connections {
    target: cmdSource
    function onSigIsUpdating(status) {
      tooltip.isUpdating = status
    }
    function onSigIsActive(active) {
      tooltip.isActive = active
    }
    function onSigCountAll(count) {
      tooltip.total = count
    }
    function onSigCountActive(count) {
      tooltip.totalActive = count
    }
  }

  ColumnLayout {
    id: mainLayout;
    Layout.topMargin: Kirigami.Units.gridUnit / 2
    Layout.leftMargin: Kirigami.Units.gridUnit / 2
    Layout.bottomMargin: Kirigami.Units.gridUnit / 2
    Layout.rightMargin: Kirigami.Units.gridUnit / 2

    PlasmaExtras.Heading {
      id: tooltipMaintext
      level: 3
      elide: Text.ElideRight
      text: tooltip.isUpdating ? "Updating..." : tooltip.isActive ? "Docker is running" : "Docker is not running"
    }

    RowLayout {
      RowLayout {
        PlasmaComponents3.Label {
          text: "Active:"
          opacity: 1
        }
        PlasmaComponents3.Label {
          text: totalActive
          opacity: .7
        }
      }
      Item { Layout.fillWidth: true }
      RowLayout {
        PlasmaComponents3.Label {
          text: "Overall:"
          opacity: 1
        }
        PlasmaComponents3.Label {
          text: total
          opacity: .7
        }
      }
    }
  }
}
