# ovos

ovos est un projet qui consiste en la création d'un os personnalisé utilisant une nouvelle vision revisité des os actuels

Actuellement :
- le mode réel a été configuré et permet à l'os d'avoir accès à 16 bits de tailles de registres et 1 Mo de ram.

- Sur le mode protégé on passe à 4go de ram de la segmentation sur la protection mémoire ainsi que de la pagination sur MMU. Egalement accès au multitaches, aux anneeaux de privilège et aux interuption protégées.

- passage en mode long pas encore fait.


Utilisation :
`make` pour lancer en mode normal dans une fenêtre l'os afin de le tester.
`make debug` pour tester avec gdb et analyser la mémoire en direct.
`make stat` pour analyser le bootloader et voir si la taille de 512 octet est respecté.
`make signature` si la signature de 55aa est respecté.
`make clean` nettoi les fichiers poubelles.

Utilise nasm pour la compilation et qemu pour la virtualisation.