TEMPLATE = app
TARGET = pocketpiglet

QT += quick quickcontrols2 sql multimedia sensors purchasing
CONFIG += c++14

DEFINES += QT_DEPRECATED_WARNINGS QT_NO_CAST_FROM_ASCII QT_NO_CAST_TO_ASCII WEBRTC_POSIX

SOURCES += \
    src/main.cpp \
    src/speechrecorder.cpp \
    webrtc/common_audio/signal_processing/complex_bit_reverse.c \
    webrtc/common_audio/signal_processing/complex_fft.c \
    webrtc/common_audio/signal_processing/cross_correlation.c \
    webrtc/common_audio/signal_processing/division_operations.c \
    webrtc/common_audio/signal_processing/downsample_fast.c \
    webrtc/common_audio/signal_processing/energy.c \
    webrtc/common_audio/signal_processing/get_scaling_square.c \
    webrtc/common_audio/signal_processing/min_max_operations.c \
    webrtc/common_audio/signal_processing/real_fft.c \
    webrtc/common_audio/signal_processing/resample_48khz.c \
    webrtc/common_audio/signal_processing/resample_by_2_internal.c \
    webrtc/common_audio/signal_processing/resample_fractional.c \
    webrtc/common_audio/signal_processing/spl_init.c \
    webrtc/common_audio/signal_processing/vector_scaling_operations.c \
    webrtc/common_audio/vad/vad_core.c \
    webrtc/common_audio/vad/vad_filterbank.c \
    webrtc/common_audio/vad/vad_gmm.c \
    webrtc/common_audio/vad/vad_sp.c \
    webrtc/common_audio/vad/webrtc_vad.c

OBJECTIVE_SOURCES += \
    src/storehelper.mm

HEADERS += \
    src/speechrecorder.h \
    src/storehelper.h \
    webrtc/typedefs.h \
    webrtc/common_audio/signal_processing/complex_fft_tables.h \
    webrtc/common_audio/signal_processing/resample_by_2_internal.h \
    webrtc/common_audio/signal_processing/include/real_fft.h \
    webrtc/common_audio/signal_processing/include/signal_processing_library.h \
    webrtc/common_audio/signal_processing/include/spl_inl.h \
    webrtc/common_audio/vad/vad_core.h \
    webrtc/common_audio/vad/vad_filterbank.h \
    webrtc/common_audio/vad/vad_gmm.h \
    webrtc/common_audio/vad/vad_sp.h \
    webrtc/common_audio/vad/include/webrtc_vad.h \
    webrtc/system_wrappers/interface/cpu_features_wrapper.h

RESOURCES += \
    qml.qrc \
    resources.qrc \
    translations.qrc

TRANSLATIONS += \
    translations/pocketpiglet_de.ts \
    translations/pocketpiglet_fr.ts \
    translations/pocketpiglet_ru.ts \
    translations/pocketpiglet_zh.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

ios {
    CONFIG += qtquickcompiler

    INCLUDEPATH += $$PWD/ios/frameworks
    DEPENDPATH += $$PWD/ios/frameworks

    LIBS += -F $$PWD/ios/frameworks \
            -framework StoreKit

    QMAKE_APPLE_DEVICE_ARCHS = arm64
    QMAKE_INFO_PLIST = ios/Info.plist
}
