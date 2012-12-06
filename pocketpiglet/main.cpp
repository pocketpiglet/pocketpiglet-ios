#include <QDeclarativeContext>

#ifdef MEEGO_TARGET
# include <QtOpenGL/QGLWidget>
#endif

#include "csapplication.h"
#include "qmlapplicationviewer.h"

int main(int argc, char *argv[])
{
    CSApplication app(argc, argv);
    QmlApplicationViewer viewer;

    viewer.rootContext()->setContextProperty("CSApplication", &app);

#ifdef MEEGO_TARGET
    viewer.setViewport(new QGLWidget());
#endif

    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
#ifdef MEEGO_TARGET
    viewer.setMainQmlFile(QLatin1String("qml/pocketpiglet/Meego/main.qml"));
#else
    viewer.setMainQmlFile(QLatin1String("qml/pocketpiglet/Symbian/main.qml"));
#endif
    viewer.showFullScreen();

    return app.exec();
}
