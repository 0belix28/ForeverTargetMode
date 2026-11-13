<p align="center">
  <img src="Media/Logo_source.png" alt="ForeverTargetMode" width="160">
</p>

<h1 align="center">ForeverTargetMode</h1>

<p align="center">
  <b>Single target or multi target? Know it at a glance as soon as you enter combat.</b><br>
  <i>Mono-cible ou multi-cibles ? Tu le sais d'un coup d'œil dès que tu entres en combat.</i>
</p>

<p align="center">
  World of Warcraft: Forever (interface 16001) · Version 0.2.0
</p>

<p align="center">
  <a href="#-français">🇫🇷 Français</a> · <a href="#-english">🇬🇧 English</a>
</p>

---

## 🇫🇷 Français

### Présentation

**ForeverTargetMode** affiche un texte clair au milieu de l'écran pendant tes combats :

- 🟢 **SINGLE TARGET** : tu combats un seul ennemi, utilise ta rotation mono-cible ;
- 🔴 **MULTI TARGET (3)** : plusieurs ennemis sont sur toi ou ton groupe, passe à ta rotation de zone.

Le texte apparaît quand tu entres en combat et disparaît quand tu en sors. Il se met à jour 4 fois par seconde.

### Fonctionnalités

- Détection automatique du nombre d'ennemis engagés contre toi **ou ton groupe**.
- Seuil réglable : à partir de combien d'ennemis tu passes en « MULTI » (2 par défaut).
- Nombre d'ennemis affiché à côté de MULTI TARGET (peut être masqué).
- Texte déplaçable à la souris et taille réglable (de 0.5 à 3).
- Panneau d'options complet dans **Échap > Options > AddOns > ForeverTargetMode**, avec un aperçu en direct.
- Accès rapide depuis le compartiment d'addons (à côté de la minicarte).
- Léger : aucune dépendance, aucune bibliothèque externe.
- Compatible avec les « valeurs secrètes » du client WoW Forever.

### Comment ça marche ?

L'addon regarde les **barres d'info** (nameplates) des ennemis visibles. Il compte ceux qui se battent contre toi ou ton groupe : tu as de la menace sur eux, ou ils ciblent un membre du groupe.

> ⚠️ **Active les barres d'info ennemies** (touche **V** par défaut). Sans elles, seule ta cible actuelle est comptée.

### Installation

1. Télécharge la dernière version.
2. Place le dossier `ForeverTargetMode` dans :
   `World of Warcraft\_forever_\Interface\AddOns\`
3. Relance le jeu (ou tape `/reload`).

### Commandes

| Commande | Effet |
|---|---|
| `/ftm` | Ouvrir le panneau d'options |
| `/ftm unlock` / `/ftm lock` | Déverrouiller / verrouiller la position du texte |
| `/ftm seuil <n>` | Nombre d'ennemis nécessaires pour MULTI |
| `/ftm scale <0.5-3>` | Taille du texte |
| `/ftm count` | Afficher / masquer le nombre d'ennemis |
| `/ftm toggle` | Activer / désactiver l'addon |
| `/ftm reset` | Remettre la position par défaut |
| `/ftm help` | Afficher l'aide dans le tchat |

### Historique

Voir [CHANGELOG.md](CHANGELOG.md).

---

## 🇬🇧 English

### Overview

**ForeverTargetMode** shows a clear on-screen text during combat:

- 🟢 **SINGLE TARGET**: you are fighting one enemy, use your single-target rotation;
- 🔴 **MULTI TARGET (3)**: several enemies are on you or your group, switch to your AoE rotation.

The text appears when you enter combat and hides when you leave it. It updates 4 times per second.

### Features

- Automatically counts the enemies engaged with you **or your group**.
- Adjustable threshold: how many enemies trigger "MULTI" (2 by default).
- Enemy count shown next to MULTI TARGET (can be hidden).
- Movable text (drag with the mouse) and adjustable size (0.5 to 3).
- Full options panel in **Esc > Options > AddOns > ForeverTargetMode**, with a live preview.
- Quick access from the AddOn compartment (next to the minimap).
- Lightweight: no dependencies, no external libraries.
- Works with the WoW Forever client's "secret values".

### How does it work?

The addon reads the **nameplates** of visible enemies. It counts the ones fighting you or your group: you have threat on them, or they are targeting a group member.

> ⚠️ **Enable enemy nameplates** (default key **V**). Without them, only your current target is counted.

> ℹ️ The in-game interface is currently in French.

### Installation

1. Download the latest release.
2. Put the `ForeverTargetMode` folder in:
   `World of Warcraft\_forever_\Interface\AddOns\`
3. Restart the game (or type `/reload`).

### Commands

| Command | Effect |
|---|---|
| `/ftm` | Open the options panel |
| `/ftm unlock` / `/ftm lock` | Unlock / lock the text position |
| `/ftm seuil <n>` (or `/ftm threshold <n>`) | Number of enemies needed for MULTI |
| `/ftm scale <0.5-3>` | Text size |
| `/ftm count` | Show / hide the enemy count |
| `/ftm toggle` | Enable / disable the addon |
| `/ftm reset` | Reset the position |
| `/ftm help` | Print help in the chat |

### Changelog

See [CHANGELOG.md](CHANGELOG.md) (in French).
