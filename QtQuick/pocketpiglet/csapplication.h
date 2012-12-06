#ifndef CSAPPLICATION_H
#define CSAPPLICATION_H

#include <QApplication>

#ifdef SYMBIAN_TARGET
#include <QSymbianEvent>
#endif

class CSApplication : public QApplication
{
    Q_OBJECT

public:
    explicit CSApplication(int &argc, char **argv);
    virtual ~CSApplication();

#ifdef SYMBIAN_TARGET
    virtual bool symbianEventFilter (const QSymbianEvent *event);
#endif

signals:
    void appInBackground();
    void appInForeground();
};

#endif // CSAPPLICATION_H
