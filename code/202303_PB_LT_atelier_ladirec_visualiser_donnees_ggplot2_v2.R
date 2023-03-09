#' ---
#' title: "Visualiser les données textuelles avec ggplot2"
#' author: "Pascal Brissette"
#' date: 2023-03-09
#' format: 
#'   html:
#'     toc: true
#'     theme: yete
#'     fontsize: 1.1em
#'     linestretch: 1.7
#' editor: visual
#' ---
#' 
## ----------------------------------------------------------------------------------------------
options(repos=c(CRAN="https://mirror.csclub.uwaterloo.ca/CRAN/"))
if(!"ggplot2" %in% rownames(installed.packages())) {install.packages("ggplot2")}
if(!"gugenbergr" %in% rownames(installed.packages())) {install.packages("gutenbergr")}
if(!"stringr" %in% rownames(installed.packages())) {install.packages("stringr")}

library(ggplot2)
library(gutenbergr)
library(stringr)

#' 
#' # Introduction
#' 
#' Une image vaut mille mots, dit la sagesse populaire. En science des données, les graphiques sont les images qu'on met à contribution pour faire voir les points saillants de jeux de données ou pour montrer des corrélations entre certaines de leurs dimensions.
#' 
#' On peut admirer ci-dessous le graphiques produit en 1869 par l'ingénieur Charles Joseph Mignard qui illustre les pertes colossales subies par la Grande Armée (450 000 hommes) de Napoléon au cours de la Campagne de Russie (1812). L'épaisseur du trait indique la quantité d'hommes; l'échelle, la distance parcourue; la couleur, la direction de la marche; la partie du bas, les variations de température. Y sont ajoutés les noms de villes traversées par l'armée française. Bien que fondé sur de solides statistiques, ce graphique donne à voir un phénomène qui ne requiert aucune connaissance des statistiques. En quelques traits, il intègre en un système cohérent une multitude de données de divers types et il raconte toute une histoire. C'est un modèle de *data storytelling*.
#' 
#' [![Charles Joseph Minard, "Carte figurative des pertes successives en hommes de l\'armée française dans la campagne de Russie 1812-1813", 1869](images/minard_campagne_russie.png){fig-align="center"}](https://fr.wikipedia.org/wiki/Charles_Joseph_Minard)
#' 
#' # Programme de l'atelier
#' 
#' Comment fabrique-t-on un graphique à partir de données textuelles? Cette question est au coeur de l'atelier et nous allons la traiter de manière pratique. Un nombre très limité de concepts seront abordés avant de plonger dans le code :
#' 
#' -   Les principaux **type** de données;
#' 
#' -   Les **vecteurs** et les **tableaux de données** dans R;
#' 
#' -   Les variables **discrètes** et **continues**;
#' 
#' -   La **grammaire** des graphiques.
#' 
#' # Types et structures de données
#' 
#' ## Principaux types de données:
#' 
#' 1.  les **nombres** (*numeric*);
#' 
#' 2.  les **chaînes de caractères** (*character*);
#' 
#' 3.  les **booléens** (*logical*).
#' 
#' Deux de ces types de données se déclinent en sous-types dans R. Les données numériques seront des **nombres entiers** (*integer*) ou des **nombres à décimales** (*double*) selon le contexte, et les chaines de caractères peuvent correspondre à des données catégorielles lorsque leur variété est limitée (exemple: les douzes mois de l'année). Voici un résumé des types de variables avec des exemples concrets:
#' 
## ----------------------------------------------------------------------------------------------
library(tibble)

tribble(
  ~ "Variable R",
  ~ "Type",
  ~ "Exemple",
  "integer",
  "nombre entier",
  "1, 15, 100",
  "double",
  "nombre à fraction",
  "1.15, -0.45009",
  "character",
  "chaîne de caractères",
  '"Abigaëlle", "Je suis curieux"',
  "logical",
  "booléen",
  "TRUE ou FALSE",
  "factor",
  "catégorielle",
  '"janvier", "février", "mars"',
  "NA",
  "sans objet",
  "NA",
  "NULL",
  "valeur nulle",
  "NULL"
)

#' 
#' Le graphique de Minard présenté en introduction contient à la fois des chaines de caractères (noms de villes et de cours d'eau), des nombres entiers (quantité de soldats) et des nombres à décimales (la température).
#' 
#' ## Les vecteurs et les tableaux de données dans R
#' 
#' Pour manipuler les données, il faut les emmagasiner dans des variables, c'est-à-dire des conteneurs dont le contenu est appelé à changer au fil des opérations (d'où le nom "variable" attribué aux conteneurs). Les structures de données varient selon le **nombre de dimensions** qu'elles comportent (1, 2 ou plusieurs dimensions) et selon que leurs données sont **homogènes** (1 seul type) ou **hétérogènes** (plusieurs types).
#' 
#' Le **vecteur** et la **matrice**, par exemple, sont des structures dites "atomiques", c'est-à-dire qu'on ne peut y mettre qu'un seul type de données. Le vecteur possède une seule dimension tandis que la matrice en possède deux. Le **tableau de données**, très utilisé en science des données, est très polyvalent: il accepte des données de plusieurs types (un seul type par colonne, cependant) et possède deux dimensions.
#' 
#' [![Structures de données dans R](images/fig1.png){fig-align="center"}](https://bookdown.org/introrbook/intro2r/data-types-and-structures.html)
#' 
#' Si on devait reconstituer le modèle de données à l'origine de la carte de Mignard sous la forme d'un tableau, on pourrait suggérer les variables suivantes (avec deux observations en guise d'exemple):
#' 
## ----------------------------------------------------------------------------------------------
tribble(
  ~ id,
  ~ ville,
  ~ longitude,
  ~ latitude,
  ~ direction_marche,
  ~ nbre_soldats,
  ~ temperature,
  1,
  "kowno",
  23.903597,
  54.898521,
  "est",
  422000,
  NA,
  2,
  "Wilna",
  25.279800,
  54.6891600,
  "est",
  400000,
  NA
)

#' 
#' ## Variables discrètes et variables continues
#' 
#' On appelle variables discrètes celles dont les valeurs correspondent et ne peuvent correspondre qu'à des nombres **entiers** et **finis**. La quantité de soldats formant l'armée ne peut prendre aucune valeur entre 0 et 1 ou entre 10 000 et 10 001. Ces données sont dites discrètes. À l'opposé, la distance ou le temps fournissent des variables continues, dont le défilement est continu et qu'on peut toujours découper plus finement.
#' 
#' Quelles sont les variables discrètes et continues dans le graphique de Minard? Pouvez-vous établir un lien entre ces types de variables et les aspects esthétiques du tableau, c'est-à-dire les éléments visuels chargés de représenter ces variables?
#' 
#' [![Types de variables et de graphiques](images/f-d_5aa7215bc54b5dd010878d9afd7d2f9964490ecd745cd9f8a523763c+IMAGE+IMAGE.1){fig-align="center"}](https://www.ck12.org/book/ck-12-basic-probability-and-statistics-concepts---a-full-course/section/8.0/)
#' 
#' ## La grammaire des graphiques (GG)
#' 
#' L'extension de base `graphics`, activée dès qu'on lance RStudio, permet de créer rapidement des graphiques avec la fonction `plot()`. Les utilisateurs de R utilisent plutôt l'extension `ggplot2`, qui permet de créer des graphiques de plus grande qualité et de mieux contrôler les paramètres de chaque élément. Cette extension implémente dans R la grammaire des graphiques proposée par [Wilkinson en 2005](https://link.springer.com/book/10.1007/0-387-28695-0).
#' 
#' Les graphiques sont composés de plusieurs éléments: des mesures, des formes, des titres, des ensembles de couleurs, des coordonnées, des axes et, bien entendu, des données. Il s'agit donc d'objets complexes que la grammaire des graphiques permet de décomposer et de régler séparément. Outre l'ouvrage de Wilkinson, vous lirez avec profit l'article et l'ouvrage de Hadley Wickham, auteur des extensions ggplot et [ggplot2](https://cran.r-project.org/web/packages/ggplot2/index.html), indiqués dans la bibliographie.
#' 
#' Dans la grammaire des graphiques, une couche est composée des éléments suivants:
#' 
#' 1.  Des **données**;
#' 2.  Des composantes **esthétiques**;
#' 3.  Une opération **statistique**;
#' 4.  Un **objet géométrique** (points, lignes, rectanges, cercles, carte, etc.);
#' 5.  Des **ajustements** pour permettre, par exemple, la superposition de points sans nuire à la lisibilité du graphique.
#' 
#' Le graphique est le résultat de la superposition de ces couches. Certaines sont facultatives ou sont pourvues de valeurs par défaut, d'autres sont nécessaires et doivent être précisées par l'utilisateur:
#' 
#' [![Capture de l\'antisèche ggplot2, RStudio](images/ggplot_min.jpg){fig-align="center"}](https://www.rstudio.com/resources/cheatsheets/)
#' 
## ----------------------------------------------------------------------------------------------
# Exemple proposé dans l'antisèche ggplot2

# Jeu de données mpg
mpg

ggplot(data = mpg, aes(x = cty, y = hwy)) +
  geom_jitter() +
  geom_smooth()



#' 
#' Le tableau ci-dessous fournit quelques précisions supplémentaires. Il ne faut pas essayer de mémoriser ces informations. Il est plus intéressant et productif de procéder par essai et erreur, puis de se référer au tableau et à l'abondante documentation sur la grammaire des graphiques pour approfondir la compréhension du processus.
#' 
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' | Élément                   | Fonction                                  | Explications                                                                                                                                                                |
#' +===========================+===========================================+=============================================================================================================================================================================+
#' | **Données**               | `ggplot()`                                | Fonction d'initialisation du graphique. On y insère généralement le **tableau de données** dont les variables serviront à définir les éléments esthétiques.                 |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' | **Éléments esthétiques**  | `aes()`                                   | Éléments esthétiques.                                                                                                                                                       |
#' |                           |                                           |                                                                                                                                                                             |
#' |                           |                                           | Parmi ces éléments, on trouve:                                                                                                                                              |
#' |                           |                                           |                                                                                                                                                                             |
#' |                           |                                           | -   `x` et `y` ==\> variables qui définissent respectivement les axes x et y du graphique;                                                                                  |
#' |                           |                                           |                                                                                                                                                                             |
#' |                           |                                           | -   `fill` ==\> variable qui définit la couleur de remplissage des formes géométriques;                                                                                     |
#' |                           |                                           |                                                                                                                                                                             |
#' |                           |                                           | -   `colour` ==\> variable qui définit la couleur des contours des formes géométriques;                                                                                     |
#' |                           |                                           |                                                                                                                                                                             |
#' |                           |                                           | -   `size` ==\> variable qui définit la taille des points ou des lignes;                                                                                                    |
#' |                           |                                           |                                                                                                                                                                             |
#' |                           |                                           | -   `alpha` ==\> le degré de transparence des formes géométriques (entre 0 et 1);                                                                                           |
#' |                           |                                           |                                                                                                                                                                             |
#' |                           |                                           | -   `shape` ==\> variable qui définit des formes géométriques en complément des points dans un graphique à points.                                                          |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' | **Éléments géométriques** | `geom_point()`                            | diagramme de dispersion (à points)                                                                                                                                          |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' |                           | `geom_bar()`                              | diagramme à barres. Prend une variable catégorielle en x. Par défaut, la fonction compte le nombre de valeurs par catégorie (x).                                            |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' |                           | `geom_col()`                              | diagramme à barres. Prend une variable catégorielle en x et une variable numérique en y. Équivalent de geom_bar(stat="identity") avec définition d'une variable continue y. |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' |                           | `geom_histogram()`                        | diagramme à barres. Prend des variables continues en x et en y. Par défaut, bins=30.                                                                                        |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' | **Facettes**              | `facet_wrap()` ou `facet_grid()`          | distribue les modalités d'une variable catégorielle en plusieurs graphiques de formats réduits.                                                                             |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' | **Statistiques**          | `stat_identity()`, `stat_summary()`, etc. | Précise les opérations statistiques faites sur les données avant de les afficher dans le graphique.                                                                         |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' | **Coordonnées**           | `coord_cartesian()`                       | Permet de fixer des limites aux axes x et y, ce qui a pour effet d'aggrandir une portions du graqphique.                                                                    |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' |                           | `coord_map()`                             | Projette une portion de la géographie terrestre sur une carte en 2 dimensions.                                                                                              |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' | **Thèmes**                | `theme_grey()`, `theme_light()`, etc.     | Série de fonctions permettant de préciser les éléments esthétiques du graphique qui ne concernent pas les données (couleur et opacité du fond, police de caractères, etc.)  |
#' +---------------------------+-------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
#' 
#' Ces quelques éléments donnent une faible idée de la richesse de l'extension `ggplot2`, dont le développement est assuré par une équipe de programmeurs. À peu près toutes les composantes d'un graphique peuvent être contrôlés.
#' 
#' On notera également que plusieurs extensions prennent appui sur `ggplot2` pour projeter l'art du graphique à un tout autre niveau. Par exemple, l'extension [`plotly`](https://cran.r-project.org/web/packages/plotly/index.html) permet d'interagir avec le graphique à l'aide d'un menu directement accessible avec la souris. D'autres extensions améliorent le rendu de graphiques spéciaux (cartes thermiques, cartes géographiques, réseaux, etc.).
#' 
#' # **Les graphiques**
#' 
#' ## Le diagramme à barres
#' 
#' Revenons aux bases et voyons comment se combinent concrètement les éléments d'un graphique. Nous allons utiliser un jeu de données construit à partir du **roman *Maria Chapdelaine***, de Louis Hémon, un roman français devenu un classique de la littérature québécoise (eh oui!). Dans le bloc d'instructions ci-dessous, le texte de Louis Hémon est importé depuis le [Projet Gutenberg](https://www.gutenberg.org/), puis traité pour forger une table comprenant, pour chacun des chapitres, le nombre de mots. N'importe quel autre texte du Projet Gutemberg pourrait faire l'objet d'un traitement similaire.
#' 
## ----------------------------------------------------------------------------------------------
# Importation sous forme de tableau de données du texte de Maria Chapdelaine avec son identifiant unique
maria <-
  gutenberg_download(13525, mirror = "http://mirror.csclub.uwaterloo.ca/gutenberg/")

# Transformation de l'encodage des chaînes de caractères du vecteur `text`
maria$text <- iconv(maria$text, from = "latin1", "utf8")

# Élimination des lignes blanches
maria <- maria[maria$text != "",]

# Élimination du péritexte
maria <- maria[grep("CHAPITRE I\\b", maria$text):nrow(maria),]

# Repérage de la ligne correspondant à chaque début de chapitre
debut_chapitres_v <- which(grepl("CHAPITRE", maria$text))

# Utilisation du vecteur précédent pour indiquer la ligne correspondant à la fin de chaque chapitre
fin_chapitres_v <-
  append((debut_chapitres_v[-1] - 1), length(maria$text))

# Création d'une petite fonction permettant la séparation des mots d'une chaîne de caractères (tokénisation)
tokenisation_fun <- 
  function(texte, debut_chapitre, fin_chapitre) {
  texte_v <- texte[as.integer(debut_chapitre):as.integer(fin_chapitre)]
  mots_l <- strsplit(texte_v, "\\W")    # séparation de tous les mots
  mots_v <- unlist(mots_l)              # transformation de l'objet liste en vecteur
  mots_v <- tolower(mots_v)             # Bas de casse
  mots_pleins_v <- which(mots_v != "")  # Identificatioon des éléments vides
  mots_v <- mots_v[mots_pleins_v]       # Élimination des éléments vides
  mots_v <- mots_v[-c(1:2)]             # Élimination des noms de chapitre
  return(mots_v)                        # Renvoi explicite de l'objet vecteur
}

# Création d'une liste vide dans laquelle on emmagasinera les mots de chacun des chapitres
mots_chapitres <-
  vector(mode = "list", length = length(debut_chapitres_v))

# On remplit notre objet liste avec les mots de chacun des chapitre (à l'aide d'une structure de contrôle appelée "boucle for")
for (i in seq_along(debut_chapitres_v)) {
  mots_chapitres[[i]] <- tokenisation_fun(
    texte = maria$text,
    debut_chapitre = (debut_chapitres_v[i]),
    fin_chapitre = fin_chapitres_v[i]
  )
}

# On crée un nouveau tableau de données comprenant une colonne pour les numéros de chapitres:
mots_chapitres_df <-
  data.frame(
    chapitre = c(
      "I",
      "II",
      "III",
      "IV",
      "V",
      "VI",
      "VII",
      "VIII",
      "IX",
      "X",
      "XI",
      "XII",
      "XIII",
      "XIV",
      "XV",
      "XVI"
    )
  )

# ... une colonne où seront rassemblés tous les mots sous forme de liste:
mots_chapitres_df$mots <- sapply(mots_chapitres, "[")

# Et une colonne indiquant le nombre de mots de chaque chapitre
mots_chapitres_df$longueur_chap <- sapply(mots_chapitres, length)

# Création d'une colonne avec tous les mots de chaque chapitre distinct joints en une seule chaine de caractères
mots_chapitres_df$texte <-
  sapply(mots_chapitres_df$mots, paste, collapse = " ")


# On crée trois colonnes, une pour chacun des prénoms des prétendants de Maria. La valeur correspond au nombre d'occurrences de chaque prénom dans chaque chapitre. La fonction utilisée, `str_count()`, est prise à l'extension stringr.

mots_chapitres_df$francois <-
  str_count(mots_chapitres_df$texte, pattern = "fran[cç]ois")

mots_chapitres_df$lorenzo <-
  str_count(mots_chapitres_df$texte, pattern = "lorenzo")

mots_chapitres_df$eutrope <-
  str_count(mots_chapitres_df$texte, pattern = "eutrope")


#' 
## ----------------------------------------------------------------------------------------------


# On peut visualiser le tableau
# head(mots_chapitres_df, 2)

# Ainsi que le nombre total d'occurrences pour chacun des noms dans tout le roman
colSums(mots_chapitres_df[, c("francois", "lorenzo", "eutrope")])


#' 
#' Nous allons récupérer le résultat de la fonction `colSums()` et créer avec ce résultat un tableau dont les données serviront à construire notre premier graphique.
#' 
## ----------------------------------------------------------------------------------------------

# Création du nouveau tableau
pretendants_total <-
  data.frame(
    pretendant = names(colSums(mots_chapitres_df[, c("francois", "lorenzo", "eutrope")])),
    freq_brute = unclass(colSums(mots_chapitres_df[, c("francois", "lorenzo", "eutrope")])),
    row.names = NULL
  )

# On crée une première couche contenant les données et leur projection en composantes esthétiques.
p <- ggplot(pretendants_total, aes(x = pretendant, y = freq_brute))

# On ajoute à cette première couche (avec l'opérateur + ) les formes géométriques.
p2 <- p + geom_bar(stat = "identity")

p2


#' 
#' Modifions les titres d'axes et ajoutons un titre général au diagramme:
#' 
## ----------------------------------------------------------------------------------------------

p3 <- p2 +
  ggtitle("Les prétendants de Maria Chapdelaine",
          subtitle = "Fréquence brute des prénoms") +
  xlab("Prénom du prétendant") +
  ylab("Fréquence brute")

p3

#' 
#' On notera l'utilisation de l'opérateur `+` pour l'ajout des éléments aux couches.
#' 
#' La hauteur de chaque colonne est déterminée par la fréquence (valeur numérique) associée à chaque prénom. On peut indiquer ces valeurs directement sur les colonnes respectives. Profitons-en pour alléger le thème en utilisant l'une des fonctions commençant par `theme_` :
#' 
## ----------------------------------------------------------------------------------------------

p3 +  geom_text(aes(label=freq_brute), vjust=1.6, color="white") +
  theme_classic()

# Exercice: explorez les autres thèmes


#' 
#' Le diagramme à barres est très efficace pour représenter des jeux de données où les modalités des **variables discrètes** sont en nombre relativement limité. Lorsque ces modalités sont très nombreuses, le graphique peut devenir confus, à moins de mettre à profit un élément esthétique supplémentaire, comme des formes ou des couleurs, pour représenter une dimension des données.
#' 
#' ### Ajout de couleurs au diagramme à barre
#' 
#' Regardons à nouveau la structure du tableau avec les données non agrégées, `mots_chapitres_df`.
#' 
## ----------------------------------------------------------------------------------------------

head(mots_chapitres_df, n = 3)

# Exercice: modifiez l'argument n ci-dessus pour observez


#' 
#' Supposons que nous souhaitions observer les occurrences des prénoms des prétendants dans tous les chapitres du roman Maria Chapdelaine. Le tableau de données fournit ces informations: chaque ligne correspond à un chapitre et on a, pour chacun des prénoms, les valeurs correspondant aux occurrences. Le problème est qu'il n'y a que deux axes dans le graphique à barres (x et y) et que nous avons trois informations: chapitre, prénom, occurrences. Les occurrences sont des valeurs numériques discrètes qui peuvent être projetés sur l'axe y. Normalement, pour observer une progression naturelle en fonction des chapitres, on voudrait placer ceux-ci sur l'axe des x. Pour intégrer au graphique l'information catégorielle "prénom", on peut recourir à un élément esthétique comme des couleurs.
#' 
#' Dans sa forme actuelle, cependant, le tableau ne convient pas. Les prénoms correspondent à trois colonnes distinctes. Voyez:
#' 
## ----------------------------------------------------------------------------------------------

head(mots_chapitres_df[, c("chapitre", "francois", "lorenzo", "eutrope")], 3)

#' 
#' Il est impossible de fournir ce tableau de données en entrée à la fonction `ggplot()`. Pour utiliser les informations qu'il contient, il faudra rassembler les trois prénoms dans une variable catégorielle. Au lieu de les utiliser comme nom de colonne, il faut faire de ces prénoms les valeurs d'une colonne que nous allons justement appeler `prenom`.
#' 
#' La fonction `reshape()` de base R permet de transformer la structure des tableaux.
#' 
## ----------------------------------------------------------------------------------------------

pretendants_empiles_df <- reshape(
  data = mots_chapitres_df[, c("chapitre", "francois", "lorenzo", "eutrope")],
  idvar = "chapitre",
  varying = list(c("francois", "lorenzo", "eutrope")),
  v.names = "frequence",
  times = c("francois", "lorenzo", "eutrope"),
  timevar = "prenom",
  direction = "long"
)

pretendants_empiles_df


#' 
#' Il reste une petite opération à faire avant de créer le graphique. Les valeurs de la variable "chapitre" sont de simples chaînes de caractères. Si nous les projetons telles quelles dans un graphique, R ordonnera ces chaînes selon l'ordre alphabétique de la première lettre et il placera donc côte-à-côte les chapitres I, II, III, IV et IX. Pour imposer un ordre particulier à ces titres de chapitre, il faut les emmagasiner dans un vecteur de type catégoriel. Nous faisons cela avec la fonction `factor()`, qui comporte un argument, `level=`, permettant de déterminer l'ordre des catégories.
#' 
## ----------------------------------------------------------------------------------------------

# On fait des numéros romains de chapitre des données catégorielles
pretendants_empiles_df$chapitre <-
  factor(
    pretendants_empiles_df$chapitre,
    levels = c(
      "I",
      "II",
      "III",
      "IV",
      "V",
      "VI",
      "VII",
      "VIII",
      "IX",
      "X",
      "XI",
      "XII",
      "XIII",
      "XIV",
      "XV",
      "XVI"
    )
  )

head(pretendants_empiles_df)


#' 
#' Nous sommes maintenant prêts à projeter les données dans un diagramme à barres!
#' 
## ----------------------------------------------------------------------------------------------

# La première couche constituée des données et des éléments esthétiques sera la même pour les deux types de diagrammes
p <- ggplot(pretendants_empiles_df,
         aes(x = chapitre, y = frequence, fill = prenom))

# Le diagramme utilise les couleurs pour indiquer la distribution des valeurs selon la variable `prénom`.
p2 <- p + geom_bar(stat = "identity", position = "stack") +
  xlab("Chapitre") +
  ylab("Fréquence")

p2

p2 + scale_fill_brewer(palette = 1)

# Exercice: explorez les différentes palettes de couleurs

#' 
#' Chaque type de graphique a ses forces et ses faiblesses. Celui-ci fait bien ressortir le fait que le chapitre V marque un moment clé dans la relation entre les trois prétendants. Le prénom de François y est dominant, mais les deux autres le suivent de près. Les chapitres IV, VII et VIII sont au contraire tournés vers d'autres enjeux.
#' 
#' Le graphique est par ailleurs un peu confus et on pourrait souhaiter séparer les catégories (prénoms) en trois facettes distinctes. On ferait alors comme ceci:
#' 
## ----------------------------------------------------------------------------------------------

# Option 2: le diagramme distribue les données dans trois facettes
p2 <- p + geom_bar(stat = "identity") +
  facet_wrap( ~ prenom) +
  theme(axis.text = element_text(size = 6),
        #On diminue la taille des titres d'axes pour éviter
        axis.title = element_text(size = 12)) +  #les chevauchements
  xlab("Chapitre") +
  ylab("Fréquence")

p2

p3 <- p2 +
  scale_fill_brewer(palette = 15)

p3

p3 +
  theme_dark()

# Exercice: explorez d'autres combinaisons de couleurs de remplissage et de thèmes

#' 
#' Comme aucune valeur n'est associée aux chapitres IV, VII et VIII, nous pouvons éliminer toutes les lignes associées à ces chapitres dans le tableau de données `pretendants_empiles_df` :
#' 
## ----------------------------------------------------------------------------------------------

# Élimination des lignes associées à des valeurs nulles
pretendants_empiles_df <- pretendants_empiles_df[!pretendants_empiles_df$frequence == 0, ]

head(pretendants_empiles_df)


#' 
#' Cet élagage permet de donner plus d'espace aux autres chapitres.
#' 
## ----------------------------------------------------------------------------------------------
p <- ggplot(pretendants_empiles_df, aes(x=chapitre, y=frequence, fill=prenom))
p + geom_bar(stat = "identity") +
  facet_wrap(~ prenom) +
  theme(axis.text=element_text(size=6),     #On diminue la taille des titres d'axes pour éviter
        axis.title=element_text(size=12))+  #les chevauchements
  xlab("Chapitre")+
  ylab("Fréquence")+
  theme_dark() +
  scale_fill_brewer(palette = 8)


#' 
#' ## Le diagramme de dispersion
#' 
#' Le diagramme de dispersion, ou nuage de points, transpose chaque valeur d'une distribution en un point. Il est souvent utilisé pour vérifier la corrélation, positive ou négative, entre deux variables (généralement continues) projetées sur l'axe des `x` et des `y`. Prenons le jeu de données `diamonds` proposé par l'extension `ggplot2`. Celui-ci contient une multitude d'informations sur 53 940 diamants. Si on voulait vérifier avec un diagramme de dispersion la corrélation entre les variables `carats` et `price`, deux variables continues, on donnerait à R les instructions suivantes:
#' 
## ----------------------------------------------------------------------------------------------

ggplot(diamonds, aes(x=carat, y=price))+
  geom_point()


#' 
#' Chaque point de ce graphique représente un diamant défini par sa qualité, exprimée en carats, et son prix, exprimé en dollars. On voit clairement que la variable dépendante, `price`, est corrélée à la variable indépendante, `carat`.
#' 
#' ### Ajout de formes au diagramme de dispersion
#' 
#' Reprenons maintenant le jeu de données créé à partir du roman *Maria Chapdelaine*. Nous allons utiliser le diagramme de dispersion pour simplement observer, comme on l'a fait avec le diagramme à barres, les mentions de prénoms des prétendants de Maria. Rappelons que nous avons trois variables à projeter sur la surface en deux dimensions du graphique: les noms de chapitres, les prénoms et la fréquence de leurs mentions. Comme nous n'avons que deux axes (`x` et `y`), nous devrons utiliser un troisième élément esthétique pour représenter l'une des trois variables. En `x`, on mettra la variable indépendante, `chapitre`, en y, `frequence`, et on donnera à chaque point du graphique une forme correspondant à la variable catégorielle, `prenom`. Il n'y a que trois prénoms, donc trois formes distinctes. On utilise, dans les esthétiques, l'argument `shape=` pour indiquer la variable qui doit servir à créer les formes. `ggplot2` créera automatiquement une légende qu'il placera, par défaut, à droite du diagramme.
#' 
## ----------------------------------------------------------------------------------------------

p <- ggplot(pretendants_empiles_df, aes(x=chapitre, y=frequence, shape = prenom))

p + geom_point()


#' 
#' Pour accentuer le contraste entre les points, on peut attribuer une couleur unique aux formes. Cela se fait aisément en utilisant l'argument `colour=` (ou `color=`) dans les esthétiques. On peut donc associer ceux éléments esthétiques à une variable:
#' 
## ----------------------------------------------------------------------------------------------

p <- ggplot(pretendants_empiles_df, aes(x=chapitre, y=frequence, shape = prenom, colour = prenom))

p + geom_point()


#' 
#' Puisque les formes et les couleurs s'appliquent directement aux points, créés avec la fonction `geom_point()`, on pourrait déplacer les précisions esthétiques dans la parenthèse de cette fonction sans modifier le diagramme. On a l'habitude de définir les éléments esthétiques qui s'appliqueront à chacun des éléments géométriques dans l'instruction initiale introduite par `ggplot()`, et à indiquer dans les arguments des fonctions `geom_***()` ceux qui s'appliquent uniquement à l'élément géométrique défini par la fonction. Par exemple, on pourrait superposer des points (formes) de différentes tailles de manière à faciliter leur repérage dans le diagramme. La forme la plus grande sera d'une couleur donnée, déterminée par la modalité spécifique de `prenom`, et la plus petite sera définie par une couleur unique, le blanc. On aura ainsi deux appels de la fonction `geom_point()` qui définiront, chacune, la couleur et la taille des points:
#' 
## ----------------------------------------------------------------------------------------------

p <- ggplot(pretendants_empiles_df, aes(x=chapitre, y=frequence, shape = prenom))

p + geom_point(aes(colour = prenom), size = 4) +
  geom_point(colour = "white", size = 1.5) +
  xlab("Chapitre") +
  ylab("Fréquence relative")



#' 
#' Le diagramme gagne en lisibilité, mais il est encore difficile d'en tirer une information pertinente, mis à part que "françois" atteint des sommets en fait de mentions, ce qui traduit l'importance qu'il prend dans les chapitres centraux du roman. Comme ici, il est parfois souhaitable de subdiviser le diagramme en autant de facettes qu'il y a de modalités dans la variable catégorielle d'intérêt. On peut faire une telle chose en utilisant la fonction `facet_wrap()` et en lui donnant, comme argument, la variable qui doit déterminer, par le nombre de ses modalités, le nombre de diagrammes à créer. On utilise l'opérateur `~` pour indiquer cette variable déterminante.
#' 
## ----------------------------------------------------------------------------------------------

# Ajout d'une couche geom_line()
p <- ggplot(pretendants_empiles_df, aes(x=chapitre, y=frequence, shape = prenom))

p + geom_point(aes(colour = prenom), size = 4)+
  geom_point(colour = "white", size = 1.5)+
  facet_wrap(~ prenom)+
  theme(axis.text=element_text(size=6),  # La fonction theme() permet de réduire la taille
        axis.title=element_text(size=12))+ # des caractères d'axes
  xlab("Chapitre")+
  ylab("Fréquence relative")


#' 
#' De mieux en mieux, non? On pourrait ajouter une autre couche géométrique au graphique, soit une ligne qui relie chacun des points de chaque graphique. Cette ligne sera noire si on ne définit aucune couleur, ou prendra la couleur des modalités de nom si on le précise dans ses éléments esthétiques:
#' 
## ----------------------------------------------------------------------------------------------

# Division du graphique en facettes

p + geom_point(aes(colour = prenom), size = 4)+
  geom_point(colour = "white", size = 1.5)+
  geom_line(aes(group = prenom, colour = prenom))+
  facet_wrap(~ prenom)+
  theme(axis.text=element_text(size=6),
        axis.title=element_text(size=12))+
  xlab("Chapitre")+
  ylab("Fréquence relative")


#' 
#' Trois facettes, trois prétendants. Pour aller plus loin, il faudrait travailler les données en amont, vérifier que les personnages ne sont pas mentionnés par des surnoms ou leur patronyme, se demander si on doit également prendre en compte leur évocation ou ce qu'ils représentent (*l'amour* pour François, *la vie facile* pour Lorenzo, *le devoir et la famille* pour Eutrope). En l'état, le graphique raconte une histoire qui colle pour ainsi dire aux faits narratifs: François est le prétendant dont le nom est le plus souvent convoqué dans le roman, ce qui traduit la focalisation dont il fait l'objet. Il apparaît tôt dans le roman, mais disparaît dans les bois et s'efface donc comme possible futur mari. Ne restent plus que Lorenzo et Eutrope. Ce dernier n'est jamais le "gagnant" en fait de mentions, mais il est celui qui reste là jusqu'à la fin et qui aura la main de Maria. Quant au chatoyant Lorenzo, il suscite un temps un grand intérêt, mais son étoile palit à la fin du roman, jusqu'à disparaître.
#' 
#' ## 
#' 
#' # Pour aller plus loin
#' 
#' Centre de la science de la biodiversité du Québec, Série d'ateliers R du CSBQ. [Atelier 3: introduction à la visualisation des données avec ggplot2](https://r.qcbs.ca/fr/workshops/r-workshop-03/)
#' 
#' Hadley Wickham et Garrett Grolemund, *R for Data Science. Import, Tidy, Transform, Visualize, and Model Data*, Sebastopol, O'Reilly.
#' 
#' Hadley Wickham, "A Layered Grammar of Graphics", *Journal of Computational and Graphical Statistics*, vol. 19, no 1, p. 3-28, 2010. DOI: 10.1198/jcgs.2009.07098
#' 
#' Winston Chang, *R Graphics Cookbook: Practical Recipes for Visualizing Data*, Second Edition, Sebastopol (CA), O'Reilly, 2018.
