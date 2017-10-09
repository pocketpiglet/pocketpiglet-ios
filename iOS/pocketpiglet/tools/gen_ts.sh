#!/bin/sh

PATH=$PATH:~/Qt/5.9.1/ios/bin

lupdate ../pocketpiglet.pro -ts ../translations/pocketpiglet_ru.src.ts
lupdate ../qml              -ts ../translations/pocketpiglet_ru.qml.ts

lconvert ../translations/pocketpiglet_ru.src.ts ../translations/pocketpiglet_ru.qml.ts -o ../translations/pocketpiglet_ru.ts
