# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "analyse"


class Optimisation

  def garder_cartes_necessaires main
    # Retrouve toutes les combinaisons possibles avec la main
    combinaisons = combinaisons(main)
    # Boucle sur chaque carte de la main pour ne conserver
    # que celles utilisées dans une combinaison
    nouvelle_main = main.clone
    combinaisons.each do |combinaison|
      nouvelle_main = enlever_cartes_utilisees nouvelle_main, combinaison
    end
    # Renvoie la main avec uniquement les cartes nécessaires aux combinaisons
    main.clone - nouvelle_main
  end

  def enlever_cartes_utilisees main, combinaison
    # Enlève de la main les cartes qui sont nécessaires à la combinaison
    nouvelle_main = main.clone
    combinaison.cartes.each do |carte|
      index = nouvelle_main.find_index { |c| c == carte }
      nouvelle_main.delete_at(index) if index
    end
    # Renvoie la main sans les cartes utilisées par la combinaison
    nouvelle_main
  end

  def combinaisons main
    # Retrouve toutes les combinaisons possibles avec la main
    analyse = Analyse.new main
    combinaisons = analyse.combinaisons
    # Renvoie les combinaisons trouvées
    combinaisons
  end

  def pose_tierce une_main
    # Evalue tous les enchainements possibles pour poser les combinaisons
    chemins = loop une_main, 0
    # On ne prend que les enchainements qui commencent par une tierce franche
    chemins.keep_if { |c| c.franche }
    # Et qui apportent un total de 51 points
    chemins.keep_if { |c| c.nb_points >= 51 }
    # Et qui laissent une carte pour la défausse
    chemins.keep_if { |c| c.nb_cartes < une_main.size }
    # Et qui utilisent un maximum de cartes
    if chemins.size > 0
      nb_cartes = chemins.max_by { |c| c.nb_cartes }.nb_cartes
      chemins.keep_if { |c| c.nb_cartes >= nb_cartes }
      # En privilégiant ceux qui font un maximum de points
      chemins.sort_by! { |c| c.nb_points }
      # Et le gagnant est...
      chemins.last.combinaison
    else
      # Ca sera pour la prochaine fois...
      nil
    end
  end

  def pose_points une_main, deja_fait
    # Evalue tous les enchainements possibles pour poser les combinaisons
    chemins = loop une_main, 0
    # On ne prend que les enchainements qui permettent de finir les 51 points
    chemins.keep_if { |c| c.nb_points >= 51 - deja_fait }
    # Et qui laissent une carte pour la défausse
    chemins.keep_if { |c| c.nb_cartes < une_main.size }
    # Et qui utilisent un maximum de cartes
    nb_cartes = chemins.max_by { |c| c.nb_cartes }.nb_cartes
    chemins.keep_if { |c| c.nb_cartes >= nb_cartes }
    # En privilégiant ceux qui font un maximum de points
    chemins.sort_by! { |c| c.nb_points }
    # Et le gagnant est...
    chemins.last.combinaison
  end

  def pose_restes une_main
    # Evalue tous les enchainements possibles pour poser les combinaisons
    chemins = loop une_main, 0
    # Cas où il n'y a plus de combinaison possible
    if chemins.size == 0
      return nil
    end
    # On prend ceux qui utilisent un maximum de cartes
    nb_cartes = chemins.max_by { |c| c.nb_cartes }.nb_cartes
    chemins.keep_if { |c| c.nb_cartes >= nb_cartes }
    # En privilégiant ceux qui font un maximum de points
    chemins.sort_by! { |c| c.nb_points }
    # Et le gagnant est...
    chemins.last.combinaison
  end

  # Evalue tous les enchainements possibles pour poser les combinaisons d'une main
  def loop une_main, level = 0
    main = garder_cartes_necessaires(une_main.clone)
    # Pour totaliser l'apport de chaque combinaison
    chemins = []
    # Retrouve toutes les combinaisons possibles avec la main
    combinaisons = combinaisons(main)
    #
    combinaisons.each do |combinaison|
      # Valeurs apportées par la combinaison
      chemin = Chemin.new
      chemin.visuel = combinaison.to_s
      chemin.combinaison = combinaison.clone
      chemin.franche = if combinaison.type != :suite
                         false
                       elsif combinaison.avec_joker?
                         false
                       elsif combinaison.cartes.size != 3
                         false
                       else
                         true # suite sans joker de 3 cartes
                       end
      chemin.nb_points = combinaison.points
      chemin.nb_cartes = combinaison.cartes.size
      # Enlève les cartes utilisées par la combinaison de la main
      nouvelle_main = enlever_cartes_utilisees main, combinaison
      #
      nouvelles_combinaisons = combinaisons(nouvelle_main)
      #
      if nouvelles_combinaisons.size > 0
        sous_chemins = loop(nouvelle_main, level + 1)
        sous_chemins.each do |nb|
          c = chemin.clone
          c.visuel += " " + nb.visuel
          c.nb_points += nb.nb_points
          c.nb_cartes += nb.nb_cartes
          chemins << c
        end
      else
        chemins << chemin
      end

    end

    chemins
  end

  def to_s main
    text = (main.map { |c| c.to_s }).join " "
    "[ #{text} ]"
  end

end

class Chemin
  # Décrit un enchainement de poses des combinaisons
  attr_accessor :visuel       # Représentation visuelle des combinaisons
  attr_accessor :combinaison  # Objet correspondant à la combinaison de 1° niveau
  attr_accessor :franche      # Vrai si le 1° niveau est une "vraie" tierce franche
  attr_accessor :nb_points    # Total des points selon le chemin
  attr_accessor :nb_cartes    # Total des cartes selon le chemin
end
