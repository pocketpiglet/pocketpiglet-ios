#!/bin/sh

PATH=$PATH:~/Qt/5.13.0/ios/bin

lupdate -locations absolute ../pocketpiglet.pro -ts ../translations/pocketpiglet_de.src.ts
lupdate -locations absolute ../qml              -ts ../translations/pocketpiglet_de.qml.ts

lupdate -locations absolute ../pocketpiglet.pro -ts ../translations/pocketpiglet_fr.src.ts
lupdate -locations absolute ../qml              -ts ../translations/pocketpiglet_fr.qml.ts

lupdate -locations absolute ../pocketpiglet.pro -ts ../translations/pocketpiglet_ru.src.ts
lupdate -locations absolute ../qml              -ts ../translations/pocketpiglet_ru.qml.ts

lupdate -locations absolute ../pocketpiglet.pro -ts ../translations/pocketpiglet_zh.src.ts
lupdate -locations absolute ../qml              -ts ../translations/pocketpiglet_zh.qml.ts

lconvert ../translations/pocketpiglet_de.src.ts ../translations/pocketpiglet_de.qml.ts -o ../translations/pocketpiglet_de.ts
lconvert ../translations/pocketpiglet_fr.src.ts ../translations/pocketpiglet_fr.qml.ts -o ../translations/pocketpiglet_fr.ts
lconvert ../translations/pocketpiglet_ru.src.ts ../translations/pocketpiglet_ru.qml.ts -o ../translations/pocketpiglet_ru.ts
lconvert ../translations/pocketpiglet_zh.src.ts ../translations/pocketpiglet_zh.qml.ts -o ../translations/pocketpiglet_zh.ts
