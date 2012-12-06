import QtQuick 1.1
import QtMultimediaKit 1.1

Video {
    id:       video
    fillMode: Video.PreserveAspectFit
    volume:   1.0

    signal playerStarted()
    signal playerPlaying()
    signal playerStopped()

    function playVideo(src) {
        source = "../../../video/" + src;

        play();
    }

    function stopVideo() {
        stop();
    }

    onStarted: {
        playerStarted();
    }

    onPositionChanged: {
        if (position > 0) {
            playerPlaying();
        }
    }

    onStopped: {
        playerStopped();
    }
}
