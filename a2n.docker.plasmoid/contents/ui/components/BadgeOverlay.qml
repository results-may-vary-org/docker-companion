/*
    Extended BadgeOverlay
    Modes:
      - default   → original KDE behavior
      - wrapText  → fixed width, multi-line
      - widthFit  → expand width to text
*/

import QtQuick
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Rectangle {
    id: root

    property alias text: label.text
    property Item icon

    property bool wrapText: false
    property bool widthFit: false

    onWrapTextChanged: if (wrapText) widthFit = false
    onWidthFitChanged: if (widthFit) wrapText = false

    // -------------------------
    // Padding logic (same as KDE)
    // -------------------------

    border.width: 1

    FontMetrics {
        id: fontMetrics
        font: label.font
    }

    readonly property real totalVerticalPadding: border.width * 4
    readonly property real totalHorizontalPadding:
        Math.max(totalVerticalPadding,
                 Math.min(fontMetrics.descent, radius) * 2)

    // -------------------------
    // Label (self-sizing!)
    // -------------------------

    PlasmaComponents3.Label {
        id: label

        minimumPixelSize: 9
        textFormat: Text.PlainText

        wrapMode: wrapText ? Text.WrapAnywhere : Text.NoWrap

        font.pixelSize: wrapText
            ? minimumPixelSize
            : Math.max(minimumPixelSize,
                       root.height - totalVerticalPadding)

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        anchors.centerIn: parent
        anchors.fill: parent
    }

    // -------------------------
    // Geometry
    // -------------------------

    implicitWidth: label.implicitWidth + totalHorizontalPadding
    implicitHeight: wrapText
        ? label.contentHeight + totalVerticalPadding
        : label.minimumPixelSize + totalVerticalPadding

    width: {
        // MODE 1 — Expand to text width
        if (widthFit)
            return implicitWidth

        // MODE 2 — Wrap inside icon width
        if (wrapText)
            return icon ? icon.width : implicitWidth

        // MODE 3 — Default KDE behavior
        return icon
            ? Math.min(icon.width,
                       Math.max(height, implicitWidth))
            : Math.max(height, implicitWidth)
    }

    height: {
        // Wrap: dynamic height based on wrapped text
        if (wrapText)
            return implicitHeight

        // widthFit: use original KDE height calculation
        if (widthFit)
            return icon
                ? Math.min(icon.height,
                           Math.max(Math.round(icon.height / 4)
                                    + totalVerticalPadding,
                                    implicitHeight))
                : implicitHeight

        // Default KDE behavior
        return icon
            ? Math.min(icon.height,
                       Math.max(Math.round(icon.height / 4)
                                + totalVerticalPadding,
                                implicitHeight))
            : implicitHeight
    }

    // -------------------------
    // Visual style (unchanged KDE look)
    // -------------------------

    color: Qt.alpha(Kirigami.Theme.backgroundColor, 0.9)
    radius: Math.min(Kirigami.Units.cornerRadius, height / 2)
    border.color: Qt.alpha(Kirigami.Theme.textColor,
                           Kirigami.Theme.frameContrast)
}
