import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.notification
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import "../Utils.js" as Utils

PlasmoidItem {
    id: main

    property var cfg: plasmoid.configuration
    property bool showNotification: cfg.useNotif
    property bool dockerEnable: false
    property string error: ""
    property string statusMessage: ""
    property string statusIcon: ""
    property string notifTitle: ""
    property string notifText: ""
    property var delayCallback: function() {}
    property int progressBar: 0 // Experimental: Reference to the progress bar

    signal pop()
    signal startProgressBar() // Experimental: Signal to start progress bar
    signal stopProgressBar() // Experimental: Signal to stop progress bar

    switchWidth: Kirigami.Units.gridUnit * 5
    switchHeight: Kirigami.Units.gridUnit * 5
    Plasmoid.status: (containerModel.count || error !== "") ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    toolTipMainText: i18n("Rdockr")
    toolTipSubText: statusMessage
    Component.onCompleted: () => {
        Utils.notificationInstall();
        if (cfg.fetchOnStart) {
        startupTimer.start();
        }
    }

    ListModel {
        id: containerModel
    }

    DockerCommand {
        id: dockerCommand
    }

    Notification {
        id: notif
        componentName: "rdockr"
        eventId: "sound"
        iconName: "rdockr-icon"
        title: notifTitle
        text: notifText
    }

    Timer {
        id: timer
        interval: cfg.pollApiInterval * 1000
        repeat: true
        running: true
        onTriggered: {
            Utils.commands["statDocker"].run();
        }
    }

    Timer {
        id: startupTimer
        interval: 2000
        onTriggered: {
            Utils.initState();
        }
        running: false
        repeat: false
    }

    Timer {
        id: delayTimer
        interval: 1500
        repeat: false
        onTriggered: {
            if (delayCallback) {
                delayCallback();
            }
        }
    }

    function delayTimerCallback(callback) {
        delayCallback = callback;
        delayTimer.start();
    }

    // Experimental: Kill progress bar
    function killProgressBar() {
        stopProgressBar();
    }

    Timer {
        id: fetchTimer
        interval: cfg.fetchContainerInterval * 1000
        repeat: true
        running: dockerEnable
        onTriggered: {
            if (dockerEnable) {
                dockerCommand.fetchContainers.get()
                if (cfg.showProgressBar) {
                    startProgressBar() // Experimental: Emit the signal to start progress bar
                }
            } else {
                stopProgressBar()
            }
        }
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            id: dockerAction
            text: i18n("Start Docker Engine")
            icon.name: "rdockr-start"
            property string command: "startDocker"
            onTriggered: {
                if (command === "startDocker") {
                    Utils.commands["startDocker"].run();
                } else if (command === "stopDocker") {
                    Utils.commands["stopDocker"].run();
                }
            }
        }
    ]

    compactRepresentation: CompactRepresentation {}

    fullRepresentation: PlasmaExtras.Representation {
        id: dialogItem

        Layout.minimumWidth: Kirigami.Units.gridUnit * 24
        Layout.minimumHeight: Kirigami.Units.gridUnit * 24
        Layout.maximumWidth: Kirigami.Units.gridUnit * 80
        Layout.maximumHeight: Kirigami.Units.gridUnit * 40
        collapseMarginsHint: true

        header: stack.currentItem.header

        Component {
            id: footerComponent
            PlasmaExtras.PlasmoidHeading {
                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignBottom
                        source: statusIcon
                        opacity: 0.7
                    }

                    QQC2.Label {
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: statusMessage
                        opacity: 0.7
                    }
                }
            }
        }

        footer: cfg.showStatusBar ? footerComponent.createObject(parent) : null

        QQC2.StackView {
            id: stack
            anchors.fill: parent
            initialItem: ContainerPage {
            }
            Connections {
                target: main
                function onPop() {
                    stack.pop();
                }
            }
        }
    }
}
