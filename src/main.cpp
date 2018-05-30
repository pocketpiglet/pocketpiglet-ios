#include <QtCore/QLocale>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>

#include "admobhelper.h"
#include "storehelper.h"
#include "speechrecorder.h"

int main(int argc, char *argv[])
{
    QTranslator     translator;
    QGuiApplication app(argc, argv);

    if (translator.load(QString(":/tr/pocketpiglet_%1").arg(QLocale::system().name()))) {
        app.installTranslator(&translator);
    }

    qmlRegisterType<SpeechRecorder>("SpeechRecorder", 1, 0, "SpeechRecorder");

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(QStringLiteral("AdMobHelper"), new AdMobHelper(&app));
    engine.rootContext()->setContextProperty(QStringLiteral("StoreHelper"), new StoreHelper(&app));

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
