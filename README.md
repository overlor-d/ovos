# ovos

ovos est un projet qui consiste en la création d'un os personnalisé utilisant une nouvelle vision revisité des os actuels

Actuellement :
- le mode réel a été configuré et permet à l'os d'avoir accès à 16 bits de tailles de registres et 1 Mo de ram.

- Sur le mode protégé on passe à 4go de ram de la segmentation sur la protection mémoire ainsi que de la pagination sur MMU. Egalement accès au multitaches, aux anneeaux de privilège et aux interuption protégées.

- prise en charge du passage en mode long via un bootloader en deux parties.

Utilisation :
`make` pour lancer en mode normal dans une fenêtre l'os afin de le tester.
`make debug` pour tester avec gdb et analyser la mémoire en direct.
`make stat` pour analyser le bootloader et voir si la taille de 512 octet est respecté.
`make signature` si la signature de 55aa est respecté.
`make clean` nettoi les fichiers poubelles.

Utilise nasm pour la compilation et qemu pour la virtualisation.

Qemu options :
| Option              | Effet                                                             |
| ------------------- | ----------------------------------------------------------------- |
| `-cdrom output.iso` | Démarre ton OS ISO                                                |
| `-m 64M`            | Alloue 64 Mio de RAM (modifie si besoin)                          |
| `-cpu max`          | Donne toutes les fonctionnalités CPU sans rien d’autre            |
| `-nodefaults`       | **Supprime tous les périphériques par défaut** (USB, écran, etc.) |
| `-nographic`        | Pas d’interface graphique QEMU (utile pour script ou serveur)     |
| `-serial stdio`     | Redirige la **sortie série (COM1)** vers le terminal              |
| `-no-reboot`        | Ne redémarre pas automatiquement en cas d’erreur                  |
| `-no-acpi`          | Désactive ACPI (gestion d’alimentation et périphériques)          |
| `-usb off`          | Pas de contrôleur USB                                             |
| `-soundhw none`     | Pas de carte son                                                  |
| `-net none`         | Pas de carte réseau                                               |

Plage mémoire mappé sur 16 MiB de 0x00000000 à 0x0001FFFF

Mémoire réservée sur 32 secteurs de 512 octets ce qui fait 162384 octets de réservé pour les deux stages appel bios 13h.