# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "joueur"
require "optimisation"

class Niveau4

  attr_accessor :joueur       # Le joueur
  attr_accessor :trace

  def initialize joueur
    self.joueur = joueur
  end

  # Détermine quelle est la meilleure carte à défausser
  def meilleure_defausse les_tas, la_defausse
    # La main du joueur
    main = self.joueur.cartes.clone

    # Une carte en double dans la main du joueur
    doublons = main
              .each_with_object(Hash.new(0)) { |o, h| h[o] += 1 }
              .map { |k, v| k if v >= 2}
              .compact
    doublons.delete_if { |c| c.est_joker? }
    if doublons.size > 0
      nb_points = if self.joueur.phase_du_jeu == :finir_partie
                  doublons.max_by { |c| c.points }.points
                else
                  doublons.min_by { |c| c.points }.points
                end
      doublons.keep_if { |c| c.points == nb_points }
      return doublons.sample
    end

    # Une carte inutilisée dans les combinaisons possibles
    combinaisons = []
    if main.size > 3
      a_un_joker = main.any? { |c| c.est_joker? }
      main << Carte.new(52) unless a_un_joker
      optimisation = Optimisation.new
      combinaisons = optimisation.combinaisons main
      inutiles = main.clone
      combinaisons.each do |combinaison|
        inutiles = optimisation.enlever_cartes_utilisees inutiles.clone, combinaison
      end
      inutiles.delete_if { |c| c.est_joker? }
      if inutiles.size > 0
        nb_points = if self.joueur.phase_du_jeu == :finir_partie
                    inutiles.max_by { |c| c.points }.points
                  else
                    inutiles.min_by { |c| c.points }.points
                  end
        inutiles.keep_if { |c| c.points == nb_points }
        return inutiles.sample
      end
    end

    # Une carte pas indispensable dans les combinaisons possibles
    combinaisons.shuffle.each do |combinaison|
      next if combinaison.type != :suite
      next if combinaison.cartes.size != 4
      if combinaison.cartes[1].est_joker?
        # Suite 6 J 8 9 => le 6 n'apporte pas grand chose
        return combinaison.cartes[0]
      elsif combinaison.cartes[2].est_joker?
        # Suite 6 7 J 9 => le 9 n'apporte pas grand chose
        return combinaison.cartes[3]
      end
    end

    # Une carte d'une série avec Joker tant que pas de tierce franche
    # OK, MAIS COMMENT FAIRE CA ???

    # Calcule le score de chaque carte dans la main du joueur
    # A REVOIR...
    scores = score_cartes(nil, les_tas, la_defausse)
    # Détermine le score le plus bas
    minimum = scores.min_by { |s| s.valorisation }.valorisation
    # Retrouve toutes les cartes concernées par le score le plus bas
    defaussables = scores.select { |s| s.valorisation == minimum }
    # Repose une des cartes faiblichonnes
    self.joueur.cartes[defaussables.sample.index]

  end

  # Détermine quelle est la meilleure combinaison à poser
  # en fonction de la phase de jeu
  def meilleure_combinaison
    # Calcule tous les enchainements de combinaisons et sélectionne :
    optimisation = Optimisation.new
    case self.joueur.phase_du_jeu
    when :faire_tierce
      # - celui qui commence par une tierce franche
      # - qui permet d'atteindre 51 points
      # - et qui utilise un maximum de cartes
      optimisation.pose_tierce joueur.cartes
    when :faire_points
      # - celui qui permet de finir la pose des 51 points
      # - et qui utilise un maximum de cartes
      optimisation.pose_points joueur.cartes, joueur.a_pose_combien
    else
      # - celui qui utilise un maximum de cartes
      optimisation.pose_restes joueur.cartes
    end
  end

  # Détermine s'il vaut mieux prendre la défausse que piocher
  def mieux_vaut_prendre? carte, les_tas, la_defausse

    # Non si le joueur n'a pas le droit de prendre la carte à la défausse
    return false if self.joueur.peut_prendre? == false

    # Si c'est le 1° tour
    if self.joueur.compte_tour == 0

      # Oui si c'est un Joker
      return true if carte.est_joker?

      # Oui si cela permet d'avoir un meilleur enchainement de combinaisons
      main = self.joueur.cartes.clone
      optimisation = Optimisation.new
      chemins = optimisation.loop main, 0
      nb_points_sans = chemins.size == 0 ? 0 : chemins.max_by { |c| c.nb_points }.nb_points
      main << carte
      chemins = optimisation.loop main, 0
      nb_points_avec = chemins.size == 0 ? 0 : chemins.max_by { |c| c.nb_points }.nb_points
      if nb_points_avec > nb_points_sans
        return true
      end

      # Non si le joueur a déjà cette carte dans sa main
      if self.joueur.cartes.any? { |c| c == carte }
        # ESSAYER D'ETRE PLUS SUBTIL
        return false
      end

      # Oui si le joueur n'a pas encore de tierce franche
      # et que la carte augmente le nombre de suites possibles
      # (voire permet de réaliser une tierce franche)
      if self.joueur.combinaisons.none? { |c| c.tierce_franche? }
        nb_suites_sans = self.joueur.combinaisons.count { |c| c.type == :suite }
        main = self.joueur.cartes.clone
        main << carte
        analyse = Analyse.new main.clone
        combinaisons = analyse.combinaisons
        nb_suites_avec = combinaisons.count { |c| c.type == :suite }
        if nb_suites_avec > nb_suites_sans
          return true
        elsif self.joueur.combinaisons.none? { |c| c.tierce_franche? }
          return true
        else
          return false
        end
      end

      # Oui si le joueur a déjà sa tierce franche
      # et que la carte augmente le nombre de combinaisons possibles
      nb_combinaisons_sans = self.joueur.combinaisons.size
      main = self.joueur.cartes.clone
      main << carte
      analyse = Analyse.new main.clone
      combinaisons = analyse.combinaisons
      nb_combinaisons_avec = combinaisons.size
      if nb_combinaisons_avec > nb_combinaisons_sans
        return true
      else
        return false
      end

      # Non dans les autres cas (pour le 1° tour)
      return false

    end

    # Si le joueur a déjà posé ses 51 points
    if self.joueur.a_pose_51?

      # Oui si c'est un Joker
      return true if carte.est_joker?

      # Non si le joueur a déjà cette carte dans sa main
      if self.joueur.cartes.any? { |c| c == carte }
        # ESSAYER D'ETRE PLUS SUBTIL
        return false
      end

      # Oui si la carte permet de faire une combinaison
      nb_combinaisons_sans = self.joueur.combinaisons.size # 0 normalement ?
      main = self.joueur.cartes.clone
      main << carte
      if main.size > 3
        analyse = Analyse.new main.clone
        combinaisons = analyse.combinaisons
        nb_combinaisons_avec = combinaisons.size
        return true if nb_combinaisons_avec > nb_combinaisons_sans
      end

      # Oui si la carte est posable sur un tas
      les_tas.each do |tas|
        if tas.remplace_le_joker? carte
          return true
        elsif tas.complete_le_tas? carte
          return true
        end
      end
# ESSAYER DE GERER SI CARTE PEUT ETRE POSABLE SUR UN TAS APRES QUE
#  DES CARTES DELA MAIN AURONT ETE POSEES SUR DES TAS

      # Non dans les autres cas (après 51 points)
      return false

    end

    # Le joueur n'a pas encore 51 points, mais possède déjà une tierce franche
    # (sans quoi il ne pourrait pas prendre la défausse)
    # On regarde donc si la prise de la carte permet d'atteindre les 51 points
    main = self.joueur.cartes.clone
    main << carte
    optimisation = Optimisation.new
    combinaison = optimisation.pose_tierce main
    if combinaison
      return true
    else
      return false
    end

  end

  # Analyse la main du joueur
  # pour déterminer l'intérêt de chacune de ses cartes
  def score_cartes autre_carte, les_tas, la_defausse

    # La main du joueur
    main = self.joueur.cartes.clone
    # - plus la carte à examiner
    main << autre_carte if autre_carte
    # - plus un joker s'il n'en a pas (et qu'il a plus de 3 cartes)
    a_un_joker = main.any? { |c| c.est_joker? }
    if main.size > 3
      main << Carte.new(52) unless a_un_joker
    end

    # Les combinaisons du joueur (à condition d'avoir plus de 3 cartes en main)
    combinaisons = []
    if main.size > 3
      analyse = Analyse.new main.clone
      combinaisons = analyse.combinaisons
    end

    # On examine maintenant toutes les cartes du joueur
    scores = []
    main.each_with_index do |carte, i|

      score = Score.new carte, i

      # Nombre de fois où cette carte apparait dans la main du joueur
      score.nombre = main.count { |c| c == carte }

      # Examine chaque combinaison dans la main du joueur
      combinaisons.each do |combinaison|

        # Rien à faire si la carte ne sert pas dans la combinaison
        est_utilisee = combinaison.cartes.any? { |c| c == carte }
        next unless est_utilisee

        score.infos += combinaison.to_s + " " unless carte.est_joker?

        # Si c'est une combinaison où le Joker est indispensable
        # et que le joueur n'a pas de joker dans sa main
        nb_esperance = 10
        unless combinaison.joker_facultatif?
          # Cherche les cartes pour finir la combinaison sans avoir besoin du Joker
          besoins = combinaison.possibilites
          # Chaque carte est présente 2 fois dans le jeu et il y a 4 Jokers
          # => on a donc le nombre de chance suivant de tomber sur la carte espérée :
          nb_esperance = (besoins.size * 2) + 4
          # Moins le nombre de fois où une des cartes espérées a déjà été jouée
          besoins.each do |besoin|
            nb_esperance -= la_defausse.count { |c| c == besoin }
            les_tas.each do |tas|
              nb_esperance -= tas.cartes.count { |c| c == besoin }
            end
          end
          # Moins le nombre de Jokers déjà joués
          # (sauf si on en a déjà un)
          unless a_un_joker
            nb_esperance -= la_defausse.count { |c| c.est_joker? } # au cas où
            les_tas.each do |tas|
              nb_esperance -= tas.cartes.count { |c| c.est_joker? }
            end
          end
          # Rien à faire s'il ne reste pas de carte pour compléter la combinaison
          next if nb_esperance == 0
        end

        score.nb_utilisation += 1
        score.nb_point += combinaison.points
        score.nb_sans_joker += 1 if combinaison.joker_facultatif?
        score.nb_tierce_franche += 1 if combinaison.tierce_franche?
        score.nb_suite += 1 if combinaison.type == :suite
        score.nb_esperance += nb_esperance

      end

      # Si le joueur a déjà posé ses 51 points
      if self.joueur.a_pose_51?
        # On regarde si la carte n'est pas posable sur un tas
        les_tas.each do |tas|
          if tas.remplace_le_joker? carte
            score.nb_utilisation += 1
            score.nb_tas_joker += 1
          elsif tas.complete_le_tas? carte
            score.nb_utilisation += 1
            score.nb_tas_pose += 1
          end
        end
      end

      scores << score

    end

    # On valorise la carte en fonction des éléments qu'on a retrouvé à son sujet
    # et en fonction de la phase du jeu...
    but = self.joueur.phase_du_jeu
    id_avant = -1
    scores.each do |score|
      valorisation = case but
                     when :faire_tierce
                       valoriser_pour_tierce score
                     when :faire_points
                       valoriser_pour_points score, 26
                     else
                       valoriser_pour_finir score
                     end
      # Si la carte ne sert qu'une fois
      # Et qu'elle est en double
      # => un des 2 cartes est totalement inutile
      if score.nombre > 1
        if id_avant == score.carte_id
          if valorisation <= 100
            valorisation = -1
          elsif score.nb_utilisation < 2
            valorisation = -1
          end
        end
      end
      score.valorisation = valorisation
      id_avant = score.carte_id
    end
    scores
  end

  def valoriser_pour_tierce score
    points = 0
    # Une carte est indispensable quand elle fait parti d'une suite
    # qui a de bonne chance d'être réalisée (et donc de faire une
    # tierce franche)
    points += score.nb_esperance * 10_000 if score.nb_suite > 0
    # Une carte est importante quand elle fait parti d'une combinaison
    # déjà complète (sans qu'il y ait besoin d'un Joker) car elle
    # donne des points utiles pour atteindre les 51 points
    points += score.nb_sans_joker * 1_000 if score.nb_sans_joker > 0
    # Une carte est valable quand elle fait parti d'une combinaison
    points += score.nb_esperance * score.nb_utilisation * 10
    # Et dans tous les cas, un Joker est inestimable
    score.est_joker ? 1_000_000 : points
  end

  def valoriser_pour_points score, points_manquants
    points = 0
    # Une carte est indispensable quand elle fait parti d'une tierce
    # franche car sans elle on régresserait d'une étape
    points += score.nb_tierce_franche * 10_000 if score.nb_tierce_franche > 0
    # Une carte est importante quand elle fait parti d'une combinaison
    # déjà complète (sans qu'il y ait besoin d'un Joker) car elle
    # donne des points utiles pour atteindre les 51 points
    points += score.nb_sans_joker * 1_000 if score.nb_sans_joker > 0
    # Une carte est intéressante quand elle apporte des points
    points += if score.nb_point >= points_manquants
                2_000
              elsif score.nb_point >= 21
                1_000
              elsif score.nb_point >= 21
                1_000
              elsif score.nb_point >= 15
                500
              else
                0
              end
    # Une carte est valable quand elle fait parti d'une combinaison
    points += score.nb_esperance * score.nb_utilisation * 10
    # Et dans tous les cas, un Joker est inestimable
    score.est_joker ? 1_000_000 : points
  end

  def valoriser_pour_finir score
    points = 0
    # Une carte est importante quand elle permet de récupérer un Joker
    # déjà posé
    points += 10_000 if score.nb_tas_joker > 0
    # Une carte est importante quand elle fait parti d'une combinaison
    # déjà complète (sans qu'il y ait besoin d'un Joker) car va pouvoir
    # être posée derechef
    points += score.nb_sans_joker * 1_000 if score.nb_sans_joker > 0
    # Une carte est importante quand elle peut être posée pour compléter
    # un des tas
    points += score.nb_tas_pose * 100 if score.nb_tas_pose > 0
    # Une carte est valable quand elle fait parti d'une combinaison
    points += score.nb_esperance * score.nb_utilisation * 10
    # Et dans tous les cas, un Joker est inestimable
    score.est_joker ? 1_000_000 : points
  end

end


class Score

  attr_accessor :carte_id           # Identifiant de la carte
  attr_accessor :carte_text         # Identifiant de la carte
  attr_accessor :index              # Index de la carte dans la main du joueur
  attr_accessor :valorisation       # Valorisation de la carte

  attr_accessor :est_joker          # Vrai si la carte est un joker
  attr_accessor :nombre             # Nombre de fois où cette carte apparait dans la main

  attr_accessor :nb_utilisation     # Nb de combinaisons où la carte est utilisée
  attr_accessor :nb_point           # Nb de points apportés par la combinaison
  attr_accessor :nb_sans_joker      # Nb de combinaisons sans joker où la carte est utilisée
  attr_accessor :nb_tierce_franche  # Nb de tierces franches où la carte est utilisée
  attr_accessor :nb_suite           # Nb de suites où la carte est utilisée
  attr_accessor :nb_esperance       # Nb de cartes disponibles pour terminer la combinaison

  attr_accessor :nb_tas_joker       # Nb de tas où la carte peut remplacer le Joker
  attr_accessor :nb_tas_pose        # nb de tas où la carte peut être posée

  attr_accessor :infos

  def initialize carte, index
    self.carte_id = carte.carte_id
    self.carte_text = carte.to_s
    self.index = index
    self.est_joker = carte.est_joker?
    self.nombre = 0
    self.nb_utilisation = 0
    self.nb_point = 0
    self.nb_sans_joker = 0
    self.nb_tierce_franche = 0
    self.nb_suite = 0
    self.nb_esperance = 0
    self.nb_tas_joker = 0
    self.nb_tas_pose = 0
    self.infos = ""
  end

end
