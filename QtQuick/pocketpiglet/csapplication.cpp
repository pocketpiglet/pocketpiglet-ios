#ifdef SYMBIAN_TARGET
#include <w32std.h>
#endif

#include "csapplication.h"

CSApplication::CSApplication(int &argc, char **argv) : QApplication(argc, argv)
{
}

CSApplication::~CSApplication()
{
}

#ifdef SYMBIAN_TARGET
bool CSApplication::symbianEventFilter(const QSymbianEvent *event)
{
    if (event != NULL && event->windowServerEvent() != NULL) {
        if (event->windowServerEvent()->Type() == EEventFocusLost) {
            emit appInBackground();
        } else if (event->windowServerEvent()->Type() == EEventFocusGained) {
            emit appInForeground();
        }
    }

    return false;
}
#endif
