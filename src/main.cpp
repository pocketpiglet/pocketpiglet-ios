#include <QtCore/QString>
#include <QtCore/QLocale>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuickControls2/QQuickStyle>

#include "speechrecorder.h"
#include "storehelper.h"

int main(int argc, char *argv[])
{
    QTranslator     translator;
    QGuiApplication app(argc, argv);

    if (translator.load(QStringLiteral(":/tr/pocketpiglet_%1").arg(QLocale::system().name()))) {
        QGuiApplication::installTranslator(&translator);
    }

    qmlRegisterType<SpeechRecorder>("SpeechRecorder", 1, 0, "SpeechRecorder");

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty(QStringLiteral("StoreHelper"), &StoreHelper::GetInstance());

    QQuickStyle::setStyle(QStringLiteral("Default"));

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    } else {
        return QGuiApplication::exec();
    }
}
