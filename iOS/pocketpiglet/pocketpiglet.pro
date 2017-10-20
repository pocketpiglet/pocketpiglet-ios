QT += quick sql multimedia sensors
CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS WEBRTC_POSIX

SOURCES += src/main.cpp \
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
    src/speechrecorder.mm

HEADERS += \
    src/speechrecorder.h \
    webrtc/common_audio/signal_processing/complex_fft_tables.h \
    webrtc/common_audio/signal_processing/include/real_fft.h \
    webrtc/common_audio/signal_processing/include/signal_processing_library.h \
    webrtc/common_audio/signal_processing/include/spl_inl.h \
    webrtc/common_audio/signal_processing/resample_by_2_internal.h \
    webrtc/common_audio/vad/include/webrtc_vad.h \
    webrtc/common_audio/vad/vad_core.h \
    webrtc/common_audio/vad/vad_filterbank.h \
    webrtc/common_audio/vad/vad_gmm.h \
    webrtc/common_audio/vad/vad_sp.h \
    webrtc/system_wrappers/interface/cpu_features_wrapper.h \
    webrtc/typedefs.h

RESOURCES += \
    qml.qrc \
    resources.qrc \
    translations.qrc

TRANSLATIONS += \
    translations/pocketpiglet_ru.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

ios {
    QMAKE_APPLE_DEVICE_ARCHS = arm64
    QMAKE_INFO_PLIST = ios/Info.plist
}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
