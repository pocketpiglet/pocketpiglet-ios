TEMPLATE = app
TARGET = pocketpiglet

QT += quick quickcontrols2 sql multimedia sensors purchasing
CONFIG += c++17 resources_big

DEFINES += QT_DEPRECATED_WARNINGS QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII WEBRTC_POSIX

INCLUDEPATH += \
    3rdparty/webrtc/common_audio/vad/include

SOURCES += \
    3rdparty/webrtc/common_audio/signal_processing/division_operations.c \
    3rdparty/webrtc/common_audio/signal_processing/energy.c \
    3rdparty/webrtc/common_audio/signal_processing/get_scaling_square.c \
    3rdparty/webrtc/common_audio/signal_processing/resample_48khz.c \
    3rdparty/webrtc/common_audio/signal_processing/resample_by_2_internal.c \
    3rdparty/webrtc/common_audio/signal_processing/resample_fractional.c \
    3rdparty/webrtc/common_audio/vad/vad_core.c \
    3rdparty/webrtc/common_audio/vad/vad_filterbank.c \
    3rdparty/webrtc/common_audio/vad/vad_gmm.c \
    3rdparty/webrtc/common_audio/vad/vad_sp.c \
    3rdparty/webrtc/common_audio/vad/webrtc_vad.c \
    src/main.cpp \
    src/voicerecorder.cpp

HEADERS += \
    3rdparty/webrtc/common_audio/signal_processing/dot_product_with_scale.h \
    3rdparty/webrtc/common_audio/signal_processing/resample_by_2_internal.h \
    3rdparty/webrtc/common_audio/signal_processing/include/signal_processing_library.h \
    3rdparty/webrtc/common_audio/signal_processing/include/spl_inl.h \
    3rdparty/webrtc/common_audio/vad/vad_core.h \
    3rdparty/webrtc/common_audio/vad/vad_filterbank.h \
    3rdparty/webrtc/common_audio/vad/vad_gmm.h \
    3rdparty/webrtc/common_audio/vad/vad_sp.h \
    3rdparty/webrtc/common_audio/vad/include/webrtc_vad.h \
    src/storehelper.h \
    src/voicerecorder.h

RESOURCES += \
    qml.qrc \
    resources.qrc \
    translations.qrc

TRANSLATIONS += \
    translations/pocketpiglet_de.ts \
    translations/pocketpiglet_fr.ts \
    translations/pocketpiglet_ru.ts \
    translations/pocketpiglet_zh.ts

QMAKE_CFLAGS += $$(QMAKE_CFLAGS_ENV)
QMAKE_CXXFLAGS += $$(QMAKE_CXXFLAGS_ENV)
QMAKE_LFLAGS += $$(QMAKE_LFLAGS_ENV)

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

ios {
    CONFIG += qtquickcompiler

    INCLUDEPATH += ios/frameworks
    DEPENDPATH += ios/frameworks

    OBJECTIVE_SOURCES += \
        src/storehelper.mm

    LIBS += -F $$PWD/ios/frameworks \
            -framework StoreKit

    QMAKE_OBJECTIVE_CFLAGS += $$(QMAKE_OBJECTIVE_CFLAGS_ENV)

    QMAKE_APPLE_DEVICE_ARCHS = arm64
    QMAKE_INFO_PLIST = ios/Info.plist
}
