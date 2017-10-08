#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>

#include "speechrecorder.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<SpeechRecorder>("SpeechRecorder", 1, 0, "SpeechRecorder");

    QQmlApplicationEngine engine;

    engine.load(QUrl(QStringLiteral("qrc:/qml/pocketpiglet/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
