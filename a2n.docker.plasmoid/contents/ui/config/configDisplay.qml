import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

Kirigami.ScrollablePage {

    id: displayConfigPage

    property alias cfg_separateResult: separateResult.checked
    property alias cfg_separator: separator.text

    property alias cfg_mainDot: mainDot.checked
    property alias cfg_mainDotColor: mainDotColor.color
    property alias cfg_mainDotUseCustomColor: mainDotUseCustomColor.checked
    property alias cfg_mainDotPosition: mainDotPosition.currentIndex

    property alias cfg_iconColor: iconColor.color
    property alias cfg_iconUseCustomColor: iconUseCustomColor.checked

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
                Kirigami.FormData.label: "Icon"
            }
        }

        Kirigami.FormLayout {
            RowLayout {
                Kirigami.FormData.label: "Custom icon color: "
                visible: true
                Controls.CheckBox {
                    id: iconUseCustomColor
                    checked: false
                }

                KQuickControls.ColorButton {
                    id: iconColor
                    enabled: iconUseCustomColor.checked
                }
            }

        }

        Kirigami.FormLayout {
            wideMode: false

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: "Display"
            }
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            text: "The dot is shown only if the result of the count command is superior to 0."
            visible: true
        }

        Kirigami.FormLayout {
            Controls.CheckBox {
                id: mainDot
                Kirigami.FormData.label: "Show a dot in place of the label: "
                checked: false
                onCheckedChanged: if (checked) separateResult.checked = false
            }

            RowLayout {
                Kirigami.FormData.label: "Custom main dot options: "
                visible: mainDot.checked

                Controls.CheckBox {
                    id: mainDotUseCustomColor
                    checked: false
                    enabled: !separateResult.checked
                }

                KQuickControls.ColorButton {
                    id: mainDotColor
                    enabled: mainDotUseCustomColor.checked
                }

                Controls.ComboBox {
                    id: mainDotPosition
                    model: ["Top Right", "Top Left", "Bottom Right", "Bottom Left"]
                    onActivated: cfg_mainDotPosition = index
                }
            }
        }

        Kirigami.FormLayout {
            wideMode: false

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: "Label display"
            }
        }

        Kirigami.FormLayout {
            Controls.CheckBox {
                id: separateResult
                Kirigami.FormData.label: "Show started and stopped count: "
                checked: false
                onCheckedChanged: if (checked) mainDot.checked = false
            }

            Controls.TextField {
                id: separator
                Kirigami.FormData.label: "Separator: "
                visible: separateResult.checked
            }
        }



    }

}
