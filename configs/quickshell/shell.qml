import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.I3
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

Scope {
    id: scope
    NotificationServer {
        id: server
        bodyMarkupSupported: true 
        actionsSupported: true

        onNotification: (notification) => {
            var component = Qt.createComponent("NotificationDisplay.qml")
            if (component.status == Component.Ready) {
                var notificationDisplay = component.createObject(scope, {
                    appName: notification.appName,
                    summary: notification.summary
                });
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData
                property string fontFamily: "3270 Nerd Font"
                property int fontSize: 22
                property bool isMenuOpen: false
                property bool isHoveringAnything: false
                property bool isMusicPaused: false

                // HyprlandFocusGrab {
                //     id: focusGrab
                //     windows: [ controlCenterPopup ]
                //     active: isMenuOpen
                //
                //     onCleared: {
                //         if (isMenuOpen) {
                //             disappearAnim.start()
                //             isMenuOpen = false
                //         }
                //     }
                // }
                id: root

                color: "#000000"

                anchors {
                    bottom: true
                    left: true
                    right: true
                }
                implicitHeight: 40

                Rectangle {
                    width: 100
                    height: root.height
                    anchors.centerIn: parent
                    opacity: 0
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            isHoveringAnything = true
                            if (!isMenuOpen) {
                                isMenuOpen = true
                                controlCenter.visible = true
                                appearAnim.start()
                            }
                        }
                        onExited: {
                            isHoveringAnything = false
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8

                    Repeater {
                        model: I3.workspaces

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            property var ws: I3.workspaces.id
                            property bool isActive: I3.workspaces.active?.id === (index + 1)
                            text: modelData.name
                            color: modelData.focused ? "#57e389" : "#2a2e2b"
                            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true;  }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }
                    Item { Layout.fillWidth: true }
                }


                PopupWindow {
                    id: controlCenterPopup
                    color: "transparent"
                    visible: isMenuOpen
                    anchor.window: root
                    anchor.rect.x: parentWindow.width / 2 - width / 2
                    width: 680
                    height: 450

                    Rectangle {
                        id: controlCenter
                        width: parent.width
                        height: parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        radius: 0
                        color: "#000000"
                        opacity: 0

                        Image {
                            anchors.fill: parent
                            source: "square.png"
                            fillMode: Image.Tile
                            opacity: 0.08
                            smooth: false
                        }

                        Scanline {
                            loop: true
                        }

                        OpenAnimation {
                            isRunning: isMenuOpen
                        }

                        ParallelAnimation {
                            id: appearAnim
                            NumberAnimation {
                                target: controlCenter
                                property: "opacity"
                                from: 0
                                to: 1
                                duration: 400
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: [0.4, 0, 0.28, 1, 1, 1]
                            }
                            NumberAnimation {
                                target: controlCenter
                                property: "y"
                                from: 50
                                to: -20
                                duration: 400
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: [0.4, 0, 0.28, 1, 1, 1]
                            }
                        }

                        ParallelAnimation {
                            id: disappearAnim
                            NumberAnimation {
                                target: controlCenter
                                property: "opacity"
                                from: 1
                                to: 0
                                duration: 400
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: [0.4, 0, 0.28, 1, 1, 1]
                            }
                            NumberAnimation {
                                target: controlCenter
                                property: "y"
                                from: -20
                                to: 50
                                duration: 400
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: [0.4, 0, 0.28, 1, 1, 1]
                            }
                            onFinished: {
                                isMenuOpen = false
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                isHoveringAnything = true
                            }
                            onClicked: {
                                if (isMenuOpen) {
                                    disappearAnim.start()
                                }
                            }
                        }

                        Rectangle {
                            id: playPauseButton
                            x: 315
                            y: 400
                            width: 50
                            height: 50
                            color: "#1fe049"

                            Text {
                                anchors.centerIn: parent
                                font { family: root.fontFamily; pixelSize: 35; bold: true;  }
                                text: isMusicPaused ? "󰏤" : "󰐊"
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    parent.color = "#57e389"
                                }
                                onExited: {
                                    parent.color = "#1fe049"
                                }
                                onClicked: {
                                    if (isMusicPaused) {
                                        playProc.running = true
                                    } else {
                                        pauseProc.running = true
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: prev
                            y: 400
                            x: 157.5
                            width: 50
                            height: 50
                            color: "#36403d"

                            Text {
                                anchors.centerIn: parent
                                color: "#000000"
                                font { family: root.fontFamily; pixelSize: 35; bold: true;  }
                                text: "󰒮"
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    parent.color = "#5e6e67"
                                }
                                onExited: {
                                    parent.color = "#36403d"
                                }
                                onClicked: {
                                    prevProc.running = true
                                }
                            }
                        }


                        Rectangle {
                            id: next
                            y: 400
                            x: 472.5
                            width: 50
                            height: 50
                            color: "#36403d"

                            Text {
                                anchors.centerIn: parent
                                color: "#000000"
                                font { family: root.fontFamily; pixelSize: 35; bold: true;  }
                                text: "󰒭"
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    parent.color = "#5e6e67"
                                }
                                onExited: {
                                    parent.color = "#36403d"
                                }
                                onClicked: {
                                    nextProc.running = true
                                }
                            }
                        }
                        Rectangle {
                            id: currentSong
                            anchors.centerIn: parent
                            width: 300
                            height: 40
                            color: "#2a2e2b"
                            Text {
                                font { family: root.fontFamily; pixelSize: 14; bold: true;  }
                                id: currentSongText
                                anchors.centerIn: parent
                                color: "#000000"
                                width: parent.width - 20
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
                Process {
                    id: pauseProc
                    running: false
                    command: [ "playerctl", "pause" ]
                    stdout: StdioCollector {
                        onStreamFinished: isMusicPaused = true;
                    }
                }

                Process {
                    id: playProc
                    running: false
                    command: [ "playerctl", "play" ]
                    stdout: StdioCollector {
                        onStreamFinished: isMusicPaused = false;
                    }
                }


                Process {
                    id: nextProc
                    running: false
                    command: [ "playerctl", "next" ]
                    stdout: StdioCollector {
                        onStreamFinished: isMusicPaused = false;
                    }
                }

                Process {
                    id: prevProc
                    running: false
                    command: [ "playerctl", "previous" ]
                    stdout: StdioCollector {
                        onStreamFinished: isMusicPaused = false;
                    }
                }

                Process {
                    id: currentSongProc
                    running: false
                    command: [ "playerctl", "metadata", "--format={{artist}} - {{title}}" ]
                    stdout: StdioCollector {
                        onStreamFinished: currentSongText.text = this.text
                    }
                }
                Timer {
                    interval: 500; running: true; repeat: true
                    onTriggered: currentSongProc.running = true
                }
            }
        }
    }
}
