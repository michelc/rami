# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "paquet"
require "joueur"
require "tas"
require "coup"


# Classe Partie
# Représente une partie de Rami
# (totalement lié au jeu de Rami)

class Partie
  NB_JEUX = 2

  attr_accessor :paquet           # Paquet de cartes utilisées pour la partie
  attr_accessor :joueurs          # Tableau des joueurs participamnst à la partie

  attr_accessor :carte_tiree      # Dernière carte tirée par le joueur en cours
  attr_accessor :carte_prise      # Carte prise à la défausse le cas échéant
  attr_accessor :carte_defausse   # Carte disponible dans le tas de défausse

  attr_accessor :piocher          # Indique si MOI doit piocher (quick & dirty)

  attr_accessor :compte_tour      # Numéro du tour en cours

  attr_accessor :ta12s            # Tableau des tas de cartes posés
                                  # C'EST UN NOM POURRI

  attr_accessor :traces           # Tableau des messages de trace
  attr_accessor :coups            # Tableau des coups joués

  # OU BIEN, GERER PIOCHE ET DEFAUSSE AU NIVEAU DE LA PARTIE
  # attr_accessor :pioche
  # attr_accessor :defausse
  # attr_accessor :joueurs

  def initialize *les_joueurs
    # Partie se joue avec 2 jeux de cartes
    self.paquet = Paquet.new NB_JEUX
    # Partie se joue entre les joueurs passés en paramètre
    self.joueurs = []
    les_joueurs.each do |nom|
      self.joueurs << Joueur.new(nom)
    end
    # La partie n'a pas encore démarrée
    self.compte_tour = 0

    self.ta12s = []
    12.times { |i| self.ta12s << Tas.new(i) }

    self.traces = []
    self.coups = Coups.new
  end

  def distribuer_les_cartes
    # Distribue 14 cartes à chaque joueur
    # (les cartes étant mélangées => on ne distribue pas 2 par 2)
    self.coups.alerter -1, "Distribution des cartes"
    self.joueurs.each do |joueur|
      joueur.ramasser_cartes self.paquet.distribuer_une_main(Joueur::TAILLE_MAIN)
      # Mémorise les cartes ramassées
      joueur_id = joueur.nom == "Moi" ? 0 : 1
      self.coups.ramasser joueur_id, joueur.cartes
    end
    # Crée le tas de défausse en y plaçant la 1° carte de la pioche
    self.carte_defausse = self.paquet.piocher_une_carte
    self.paquet.defausser_une_carte self.carte_defausse
    self.coups.defausser -1, self.carte_defausse.carte_id
    # Puis on commence le 1° tour de jeu
    self.compte_tour = 1
    self.traces = []
    # Et il n'y a plus de carte en cours
    self.carte_tiree = nil
    self.carte_prise = nil
  end

  def prendre_dans_pioche joueur_id
    # Prend une carte dans la pioche
    self.carte_tiree = self.paquet.piocher_une_carte
    self.carte_prise = nil
    # Pour l'ajouter à la main du joueur
    self.joueurs[joueur_id].ajouter_une_carte self.carte_tiree
    # Mémorise le coup joué
    self.coups.piocher joueur_id, self.carte_tiree.carte_id
  end

  def prendre_dans_defausse joueur_id
    # Prend une carte dans la défausse
    self.carte_tiree = self.paquet.prendre_la_defausse
    self.carte_prise = self.carte_tiree
    # Pour l'ajouter à la main du joueur
    self.joueurs[joueur_id].ajouter_une_carte self.carte_tiree
    # Mémorise la nouvelle carte disponible à la défausse
    self.carte_defausse = self.paquet.carte_defausse
    # Mémorise le coup joué
    self.coups.prendre joueur_id, self.carte_tiree.carte_id
  end

  def accepter_defausse joueur_id
    # Vérifie s'il existe un tas entamé (ie avec 1 ou 2 cartes)
    a_finir = self.ta12s.find { |t| (1..2) === t.cartes.size }
    if a_finir != nil
      self.coups.alerter joueur_id, "défausse interdite car tas entamé"
      return false
    end
    # Si le joueur a posé sa tierce franche,
    # => il faut qu'il ait posé 51 points
    if self.joueurs[joueur_id].a_pose_tierce?
      unless self.joueurs[joueur_id].a_pose_51?
        self.coups.alerter joueur_id, "défausse interdite car pas 51 points"
        return false
      end
    end
    # Si le joueur a pris la carte à la défausse,
    # => il faut qu'il ait posé cette carte
    # => TODO
    # Si le joueur a pris la carte à la défausse,
    # => il ne faut pas qu'il l'ait utilisée pour sa tierce franche
    # => TODO
    # Défausse est OK sinon
    true
  end

  def poser_dans_defausse joueur_id, carte
    # Retire une carte de la main du joueur
    self.joueurs[joueur_id].enlever_une_carte carte
    # Et la pose dans la défausse
    self.paquet.defausser_une_carte carte
    # Et il n'y a plus de carte en cours
    self.carte_tiree = nil
    # Mémorise la nouvelle carte disponible à la défausse
    self.carte_defausse = self.paquet.carte_defausse

    # Le joueur a fini son tour => met à jour son compte-tour
    self.joueurs[joueur_id].compte_tour += 1
    # Le joueur a fini son tour => met à jour ses points à la fin du tour
    self.joueurs[joueur_id].compte_points = self.joueurs[joueur_id].a_pose_combien
    # Passe au tour suivant lorsque tous les joueurs ont fini le tour
    self.compte_tour += 1 if self.joueurs.all? { |j| j.compte_tour == self.compte_tour }
    # Mémorise le coup joué
    self.coups.defausser joueur_id, carte.carte_id
  end

  def fin_partie?
    # Teste s'il y a un gagnant
    gagnant_id = self.joueurs.find_index { |j| j.cartes.size == 0 }
    if gagnant_id
      # Oui => défini le résultat de la partie en fonction du joueur humain
      if gagnant_id == 0
        self.coups.alerter 0, "Gagné !!!"
      else
        self.coups.alerter 0, "Perdu..."
      end
      # Indique que la partie est terminée
      true
    else
      # Indique que la partie n'est pas terminée
      false
    end
  end

  def poser_sur_tas joueur, tas, carte

    # Le joueur ne peut pas poser lors du 1° tour
    if self.compte_tour == 1
      joueur_id = joueur.nom == "Moi" ? 0 : 1
      self.coups.alerter joueur_id, "pose interdite lors du 1° tour"
      return
    end

    # Le joueur ne peut pas poser sa dernière carte !
    # (il doit la mettre à la défausse)
    if joueur.cartes.size == 1
      joueur_id = joueur.nom == "Moi" ? 0 : 1
      self.coups.alerter joueur_id, "dernière carte va à la défausse !"
      return
    end

    # Cas où le joueur n'a pas encore posé sa tierce franche
    unless joueur.a_pose_tierce?
      # => il est en train de constituer sa tierce franche
      poser_tierce_franche joueur, tas, carte
      return
    end

    # Cas où le joueur n'a pas encore posé ses 51 points
    unless joueur.a_pose_51?
      # => il est en train de poser ses 51 points
      poser_autre_carte joueur, tas, carte
      return
    end

    poser_autre_carte joueur, tas, carte

  end

  def faire_jouer joueur_id
    self.traces = []

    # C'est le joueur RUBY qui joue
    joueur = self.joueurs[joueur_id]

    # Tire une carte (dans la pioche ou la défausse)
    if joueur.mieux_vaut_prendre? self.carte_defausse, self.ta12s
self.traces << "defausse => [ #{self.carte_defausse.to_s} ]"
      prendre_dans_defausse joueur_id
    else
      prendre_dans_pioche joueur_id
self.traces << "  pioche => [ #{self.carte_tiree.to_s} ] (#{joueur.niveau.trace} = #{self.carte_defausse.to_s})"
    end

    # Joue ses cartes (s'il est en mesure de poser)
    if joueur.peut_poser?
        nb_possibilites = joueur.combinaisons.size
        while nb_possibilites > 0
          combinaison = joueur.meilleure_combinaison
          tas_libre = self.ta12s.find { |t| t.cartes.empty? == true }
          combinaison.cartes.each do |carte|
            poser_sur_tas joueur, tas_libre, carte
          end
          self.traces << " plateau <= #{combinaison.to_s} (#{combinaison.to_text} / #{joueur.a_pose_combien})"
          nb_possibilites = joueur.combinaisons.size
      end

      # Récupère éventuellement un joker
      # (s'il a le droit de compléter les autres tas)
      if (joueur.a_pose_51? == true)
        # Examine tous les tas déjà posés un par un
        ok = joueur.cartes.size > 1
        while ok
          ok = false
          self.ta12s.each do |tas|
            # regarde si on peut remplacer le joker du tas
            joueur.cartes.each do |carte|
              if tas.remplace_le_joker? carte
                self.traces << "     tas <= #{tas.to_s} <--> [ #{carte.to_s} ]"
                poser_sur_tas joueur, tas, carte
                break if joueur.cartes.size == 1
                ok = true # On re-teste tout chaque fois qu'on a posé une carte
              end
            end
          end
        end
      end

      # Complète les combinaisons existantes (s'il a le droit de le faire)
      if (joueur.a_pose_51? == true)
        # Examine tous les tas déjà posés un par un
        ok = joueur.cartes.size > 1
        while ok
          ok = false
          self.ta12s.each do |tas|
            # regarde si on peut ajouter une carte au tas
            joueur.cartes.each do |carte|
              if tas.complete_le_tas? carte
                self.traces << "     tas <= #{tas.to_s} + [ #{carte.to_s} ]"
                poser_sur_tas joueur, tas, carte
                break if joueur.cartes.size == 1
                ok = true # On re-teste tout chaque fois qu'on a posé une carte
              end
            end
          end
        end
      end

    end

    # Ecarte une carte à la défausse
    poser_dans_defausse joueur_id, joueur.meilleure_defausse(self.ta12s)
self.traces << "defausse <= [ #{self.carte_defausse.to_s} ]"

  end

  private

  # Gère la pose d'une carte sur un tas
  # en fonction des différents cas qui peuvent se présenter
  def poser_autre_carte joueur, tas, carte
    # Mémorise la combinaison actuelle dans le tas
    avant_cartes = tas.combinaison.to_s
    avant_points = tas.combinaison.points
    # Détermine s'il est encore nécessaire de donner le score du joueur
    donner_score = joueur.a_pose_51? ? false : true
    # Détermine l'identifiant du joueur en cours
    joueur_id = joueur.nom == "Moi" ? 0 : 1

    # Cas où le joueur n'a pas encore posé ses 51 points
    if joueur.a_pose_51? == false
      # - Le joueur s'approprie le tas dès lors qu'il est vide
      tas.nom_joueur = joueur.nom if avant_points == 0
      # - Le joueur ne peut pas poser sur un tas adverse pour l'instant
      if tas.nom_joueur != joueur.nom
        self.coups.alerter joueur_id, "il faut 51 pour compléter les tas"
        return
      end
    end

    # Cas où le joueur n'a pas posé ses 51 points avant le tour en cours
    if joueur.avait_pose_51? == false
      # - Le joueur ne peut pas encore compléter sa tierce franche
      if tas.nom_joueur == joueur.nom + "_tf"
        self.coups.alerter joueur_id, "attendre 1 tour pour compléter la tierce franche"
        return if joueur_id == 0 # TODO: Pas encore géré pour le joueur Ruby
      end
    end

    # Cas où la carte du joueur lui permet de récupérer le joker
    if tas.remplace_le_joker? carte
      # - Retire la carte de la main du joueur
      joueur.enlever_une_carte carte
      # - Pour remplacer le joker dans le tas
      joker = tas.echanger_le_joker carte
      # - Et récupérer le joker dans la main du joueur
      joueur.cartes << joker
      # - Mémorise le coup joué
      self.coups.poser joueur_id, carte.carte_id, tas.tas_id
      return
    end

    # Cas où la carte du joueur lui permet de compléter le tas
    if tas.complete_le_tas? carte
      # - Retire la carte de la main du joueur
      joueur.enlever_une_carte carte
      # - Pour la placer sur le tas
      tas.ajouter_une_carte carte
      # - Met à jour le score du joueur
      joueur.a_pose_combien -= avant_points
      joueur.a_pose_combien += tas.combinaison.points
      # - Mémorise le coup joué
      self.coups.poser joueur_id, carte.carte_id, tas.tas_id
      # - Informe le joueur qu'il a complété une combinaison valide
      self.coups.marquer joueur_id, tas.combinaison.points, joueur.a_pose_combien
      return
    end

    # Cas où la carte du joueur ne lui permet pas de compléter le tas
    # alors que le tas contient déjà une combinaison valide
    if tas.cartes.size >= 3
      # - Informe le joueur qu'il y a un problème
      type = tas.combinaison.type == :serie ? "série" : "suite"
      self.coups.alerter joueur_id, "#{carte} ne complète pas la #{type}"
      return
    end

    # Cas où le joueur place sa carte sur un tas en constructiuon (moins de 3 cartes)
    # - Retire une carte de la main du joueur
    joueur.enlever_une_carte carte
    # - Pour la placer sur un tas
    tas.ajouter_une_carte carte
    # - Mémorise le coup joué
    self.coups.poser joueur_id, carte.carte_id, tas.tas_id
    # - Rien d'autre à faire tant que le tas ne contient pas 3 cartes
    return if tas.cartes.size < 3

    # Cas où le tas contient désormais 3 cartes
    # => On analyse si cela correspond à une combinaison valide
    combinaison = tas.combinaison

    # Cas où le tas constitue à présent une combinaison valide
    if combinaison.type != :tas
      # - Met à jour le score du joueur
      joueur.a_pose_combien -= avant_points
      joueur.a_pose_combien += tas.combinaison.points
      # - Informe le joueur qu'il a posé une combinaison valide
      self.coups.marquer joueur_id, tas.combinaison.points, joueur.a_pose_combien
      # - Rien d'autre à faire
      return
    end

    # Cas où les 3 cartes ne constituent pas une combinaison valide !!!
    # - Remet les cartes du tas dans la main du joueur
    tas.cartes.each do |c|
      joueur.ajouter_une_carte c
      self.coups.annuler
    end
    # - Vide le tas
    tas.clear
    # - Informe le joueur qu'il y a un problème
    self.coups.alerter joueur_id, "#{combinaison.to_s} pas une combinaison"
  end

  # Cas où le joueur est en train de constituer sa tierce franche
  def poser_tierce_franche joueur, tas, carte
    # Détermine l'identifiant du joueur en cours
    joueur_id = joueur.nom == "Moi" ? 0 : 1
    tas.nom_joueur = joueur.nom + "_tf"

    # Vérifie que le joueur pose sa tierce franche au bon endroit
    if joueur.cartes.size == 15
      # Si le joueur a 15 cartes
      # Alors, il est en train de poser sa 1° carte,
      # donc forcément sur un tas vide
      if tas.cartes.size != 0
        self.coups.alerter joueur_id, "tierce franche doit aller sur un tas vide"
        return
      end
    end

    # Place la carte du joueur sur le tas destiné à sa tierce franche
    # - Retire une carte de la main du joueur
    joueur.enlever_une_carte carte
    # - Pour la placer sur un tas
    tas.ajouter_une_carte carte
    # - Mémorise le coup joué
    self.coups.poser joueur_id, carte.carte_id, tas.tas_id
    # - Rien d'autre à faire tant que le tas ne contient pas 3 cartes
    return if tas.cartes.size < 3

    # On analyse ce que contient le tas
    combinaison = tas.combinaison
    # Cas où c'est une tierce franche
    if combinaison.tierce_franche?
      # Mémorise le nombre de points que représente la tierce franche
      joueur.a_pose_combien = combinaison.points
      # Informe le joueur qu'il a posé sa tierce franche
      self.coups.marquer joueur_id, tas.combinaison.points, joueur.a_pose_combien
      # Rien d'autre à faire
      return
    end

    # Cas où les 3 cartes ne constituent pas une tierce franche !!!
    # - Remet les cartes du tas dans la main du joueur
    tas.cartes.each do |c|
      joueur.ajouter_une_carte c
      self.coups.annuler
    end
    # - Vide le tas
    tas.clear
    # - Informe le joueur qu'il y a un problème
    self.coups.alerter joueur_id, "#{combinaison.to_s} pas une tierce franche"
  end

end
