import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
         name: i18nc("@title", "Command")
         icon: "applications-development-relative"
         source: "config/configCommand.qml"
    }
    ConfigCategory {
        name: i18nc("@title", "Display")
        icon: "computer-relative"
        source: "config/configDisplay.qml"
    }
}
