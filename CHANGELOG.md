# ForeverTargetMode - Historique des versions

Format des versions : **0.X.Y**
- **X** : mise à jour majeure (nouvelle fonctionnalité importante)
- **Y** : mise à jour mineure (correction, petit ajout)
- Passage en **1.0.0** quand l'addon sera terminé et stable.

Le numéro de version se change à un seul endroit : la ligne `## Version:` de `ForeverTargetMode.toc`.

---

## 0.2.0 - Panneau d'options

- Panneau dans Échap > Options > AddOns > ForeverTargetMode, au style ForeverTchatBell / ForeverEgo :
  logo, grand titre doré, version, gros bouton activer / désactiver, encadrés sombres à bord doré.
- Encadré « Réglages » : déverrouiller pour déplacer, afficher le nombre d'ennemis, seuil multi-cibles (- / +),
  taille du texte (- / +), bouton « Position par défaut ».
- Encadré « Aperçu » : SINGLE TARGET / MULTI TARGET avec les réglages actuels.
- Encadré « Commandes ».
- `/ftm` sans argument et le compartiment d'addons ouvrent le panneau ; `/ftm help` affiche l'aide.
- Nouveau logo : cible et flèches sur fond transparent (Media\Logo.tga, 128×128), aussi icône dans la liste des AddOns.
  Media\Logo_source.png : la même image détourée en grande taille (pour retouches).

## 0.1.0 - Première version

- En combat, affiche à l'écran **SINGLE TARGET** (vert) ou **MULTI TARGET (n)** (rouge). Caché hors combat.
- Comptage toutes les 0,25 s des ennemis visibles (barres d'info ennemies) en combat contre toi ou ton groupe
  (sur ta table de menace, ou ciblant un membre du groupe).
- Sans barres d'info visibles, la cible actuelle compte pour 1.
- Commandes `/ftm` : unlock / lock (déplacer), seuil, scale, count, toggle, reset.
- Clic dans le compartiment d'addons : déverrouille / verrouille (remplacé en 0.2.0 par l'ouverture du panneau).
