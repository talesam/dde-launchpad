// SPDX-FileCopyrightText: 2023 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.15
import QtQml.Models 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import org.deepin.dtk 1.0

import org.deepin.launchpad 1.0

ApplicationWindow {
    id: root

    width: 780
    height: 600
    visible: LauncherController.visible
    flags: {
        if (LauncherController.currentFrame === "WindowedFrame") {
            return (Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint | Qt.Tool)
        } else {
            return Qt.Tool
        }
    }
    DWindow.enabled: true
    DWindow.enableBlurWindow: true
    DWindow.enableSystemMove: false

    onVisibleChanged: {
        updateWindowVisibilityAndPosition()
    }

    function launchApp(desktopId) {
        if (isDebugInstance) {
            DTK.sendSystemMessage("dde-launchpad (debug)",
                                  "clicked " + desktopId + " but won't attempt to launch it cause it's debug mode",
                                  "dialog-warning")
        } else {
            DesktopIntegration.launchByDesktopId(desktopId);
            LauncherController.visible = false
        }
    }

    function showContextMenu(obj, model, folderIcons, isFavoriteItem, hideFavoriteMenu) {
        if (folderIcons) return
        const component = Qt.createComponent(Qt.resolvedUrl("./AppItemMenu.qml"))
        const menu = component.createObject(obj, {
            appItem: model,
            isFavoriteItem: isFavoriteItem,
            hideFavoriteMenu: hideFavoriteMenu
        });
        // menu.closed.connect(function() { /**/ });
        menu.popup();
    }

    function updateWindowVisibilityAndPosition() {
        if (!root.visible) return;

        if (LauncherController.currentFrame === "WindowedFrame") {
//            root.visibility = Window.Windowed
            let width = 780
            let height = 600
            let x = 0
            let y = 0

            let dockGeometry = DesktopIntegration.dockGeometry
            if (dockGeometry.width > 0 && dockGeometry.height > 0) {
                console.log(114514, dockGeometry)
                switch (DesktopIntegration.dockPosition) {
                case Qt.DownArrow:
                    x = dockGeometry.left
                    y = (dockGeometry.top >= 0 ? dockGeometry.top : (Screen.height - dockGeometry.height)) - height
                    break
                case Qt.LeftArrow:
                    x = dockGeometry.width
                    y = (dockGeometry.top >= 0 ? dockGeometry.top : 0)
                    break
                case Qt.TopArrow:
                    x = dockGeometry.left
                    y = dockGeometry.height
                    break
                case Qt.RightArrow:
                    x = (dockGeometry.left >= 0 ? dockGeometry.left : (Screen.width - dockGeometry.width)) - width
                    y = dockGeometry.top
                    break
                }
            }

            root.setGeometry(x, y, width, height)
        } else {
//            root.visibility = Window.FullScreen
            root.setGeometry(Screen.virtualX, Screen.virtualY, Screen.width, Screen.height)
        }
    }

    Connections {
        target: DesktopIntegration
        onDockPositionChanged: {
            updateWindowVisibilityAndPosition()
        }
    }

    Loader {
        id: frameLoader
        anchors.fill: parent
        source: LauncherController.currentFrame + ".qml"
        onSourceChanged: {
            updateWindowVisibilityAndPosition();
        }

        Label {
            visible: isDebugInstance
            z: 999

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: "/ / Under Construction / /"

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(1, 1, 0, 0.5)
            }
        }
    }
}
