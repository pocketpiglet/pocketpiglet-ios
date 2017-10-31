#!/bin/sh

PATH=$PATH:~/Qt/5.9.1/ios/bin

lupdate ../pocketpiglet.pro -ts ../translations/pocketpiglet_ru.src.ts
lupdate ../qml              -ts ../translations/pocketpiglet_ru.qml.ts

lupdate ../pocketpiglet.pro -ts ../translations/pocketpiglet_de.src.ts
lupdate ../qml              -ts ../translations/pocketpiglet_de.qml.ts

lupdate ../pocketpiglet.pro -ts ../translations/pocketpiglet_fr.src.ts
lupdate ../qml              -ts ../translations/pocketpiglet_fr.qml.ts

lconvert ../translations/pocketpiglet_ru.src.ts ../translations/pocketpiglet_ru.qml.ts -o ../translations/pocketpiglet_ru.ts
lconvert ../translations/pocketpiglet_de.src.ts ../translations/pocketpiglet_de.qml.ts -o ../translations/pocketpiglet_de.ts
lconvert ../translations/pocketpiglet_fr.src.ts ../translations/pocketpiglet_fr.qml.ts -o ../translations/pocketpiglet_fr.ts
