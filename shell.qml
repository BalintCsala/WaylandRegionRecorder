import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import QtQuick.Controls
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        id: window
        property var areaX1: 0
        property var areaY1: 0
        property var areaX2: 0
        property var areaY2: 0

        property var recording: false
        property var startTime: null
        property var fileName: ""
        property var region: ""

        mask: Region {
            item: window.recording ? recordButtonRect : windowRect
        }

        WlrLayershell.keyboardFocus: window.recording ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        exclusionMode: ExclusionMode.Ignore

        color: "transparent"

        Item {
            focus: true
            anchors.fill: parent
            Keys.onPressed: event => {
                if (event.key == Qt.Key_Escape) {
                    Qt.quit();
                }
            }
        }

        Rectangle {
            id: windowRect
            anchors.fill: parent
            color: "transparent"
        }

        Process {
            running: window.recording
            command: ["sh", "-c", `wf-recorder -f "$HOME/Videos/ScreenRecord/${window.fileName}" -g "${window.region}"`]
            onExited: () => {
                Qt.quit();
            }
        }

        Timer {
            interval: 10
            repeat: true
            running: window.recording
            onTriggered: () => {
                const elapsedSeconds = (new Date() - window.startTime) / 1000;
                const seconds = elapsedSeconds % 60;
                const minutes = Math.floor(elapsedSeconds / 60);
                elapsedTime.text = `${minutes.toString().padStart(2, "0")}:${seconds.toFixed(2).padStart(5, "0")}`;
            }
        }

        MouseArea {
            id: mousearea
            anchors.fill: parent

            onPressed: mouse => {
                if (window.recording || mouse.button != Qt.LeftButton)
                    return;

                window.areaX1 = mouse.x;
                window.areaY1 = mouse.y;
                window.areaX2 = mouse.x;
                window.areaY2 = mouse.y;
            }

            onPositionChanged: mouse => {
                if (window.recording)
                    return;
                window.areaX2 = mouse.x;
                window.areaY2 = mouse.y;
            }
        }

        // Background
        Shape {
            ShapePath {
                fillColor: "#7F000000"
                strokeWidth: 0

                startX: 0
                startY: 0

                PathLine {
                    x: window.width
                    y: 0
                }
                PathLine {
                    x: window.width
                    y: window.height
                }
                PathLine {
                    x: 0
                    y: window.height
                }
                PathLine {
                    x: 0
                    y: 0
                }

                PathLine {
                    x: window.areaX1 - 2
                    y: window.areaY1 - 2
                }
                PathLine {
                    x: window.areaX2 + 2
                    y: window.areaY1 - 2
                }
                PathLine {
                    x: window.areaX2 + 2
                    y: window.areaY2 + 2
                }
                PathLine {
                    x: window.areaX1 - 2
                    y: window.areaY2 + 2
                }
                PathLine {
                    x: window.areaX1 - 2
                    y: window.areaY1 - 2
                }

                PathLine {
                    x: 0
                    y: 0
                }
            }
        }

        // Border
        Shape {
            ShapePath {
                fillColor: "transparent"
                strokeColor: window.recording ? "red" : "white"
                strokeStyle: ShapePath.DashLine
                dashPattern: [1, 4]
                strokeWidth: 4

                startX: window.areaX1 - 2
                startY: window.areaY1 - 2
                PathLine {
                    x: window.areaX2 + 2
                    y: window.areaY1 - 2
                }
                PathLine {
                    x: window.areaX2 + 2
                    y: window.areaY2 + 2
                }
                PathLine {
                    x: window.areaX1 - 2
                    y: window.areaY2 + 2
                }
                PathLine {
                    x: window.areaX1 - 2
                    y: window.areaY1 - 2
                }
            }
        }

        RowLayout {
            x: Math.min(window.areaX1, window.areaX2)
            y: Math.min(window.areaY1, window.areaY2) - 50
            Button {
                width: 100
                height: 50
                text: window.recording ? "⬛Stop" : "🔴Record"
                font.pixelSize: 18
                onClicked: () => {
                    if (!window.recording) {
                        const padNum = num => {
                            return num.toString().padStart(2, "0");
                        };

                        const date = new Date();
                        window.startTime = date;
                        window.fileName = `${date.getFullYear()}-${padNum(date.getMonth() + 1)}-${padNum(date.getDate())} ${padNum(date.getHours())}-${padNum(date.getMinutes())}-${padNum(date.getSeconds())}.mp4`;

                        const minX = Math.min(window.areaX1, window.areaX2);
                        const minY = Math.min(window.areaY1, window.areaY2);
                        const maxX = Math.max(window.areaX1, window.areaX2);
                        const maxY = Math.max(window.areaY1, window.areaY2);
                        window.region = `${minX},${minY} ${maxX - minX}x${maxY - minY}`;
                    }
                    window.recording = !window.recording;
                }

                Rectangle {
                    id: recordButtonRect
                    anchors.fill: parent
                    color: "transparent"
                }
            }

            Text {
                id: elapsedTime
                color: "white"
                text: ""
                font.pixelSize: 18
            }
        }
    }
}
