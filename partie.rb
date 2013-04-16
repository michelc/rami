# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "paquet"
require "joueur"
require "tas"


# Classe Partie
# Représente une partie de Rami
# (totalement lié au jeu de Rami)

class Partie
  NB_JEUX = 2

  attr_accessor :paquet           # Paquet de cartes utilisées pour la partie
  attr_accessor :joueurs          # Tableau des joueurs participamnst à la partie

  attr_accessor :carte_tiree      # Dernière carte tirée par le joueur en cours
  attr_accessor :carte_defausse   # Carte disponible dans le tas de défausse

  attr_accessor :piocher          # Indique si MOI doit piocher (quick & dirty)

  attr_accessor :compte_tour      # Numéro du tour en cours

  attr_accessor :ta12s            # Tableau des tas de cartes posés
                                  # C'EST UN NOM POURRI

  attr_accessor :messages         # Tableau des messages d'information
  attr_accessor :traces           # Tableau des messages d'information

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

    self.messages = []
    self.traces = []
  end

  def distribuer_les_cartes
    # Distribue 14 cartes à chaque joueur
    # (les cartes étant mélangées => on ne distribue pas 2 par 2)
    self.joueurs.each do |joueur|
      joueur.ramasser_cartes self.paquet.distribuer_une_main(Joueur::TAILLE_MAIN)
    end
    # Crée le tas de défausse en y plaçant la 1° carte de la pioche
    self.carte_defausse = self.paquet.piocher_une_carte
    self.paquet.defausser_une_carte self.carte_defausse
    # Puis on commence le 1° tour de jeu
    self.compte_tour = 1
    self.messages = [ "Cartes distribuées" ]
    self.traces = []
    # Et il n'y a plus de carte en cours
    self.carte_tiree = nil
  end

  def msg nom, action, quoi, ou = nil, resultat = nil
    if action == "pose"
      # Joueur vient de finir de poser une combinaison de 3 cartes
      # => on efface les 2 messages précédants qui indiquaient que
      #    le joueur plaçait la 1° et la 2° carte de la combinaison
      #    sur la table
      self.messages.pop
      self.messages.pop
    end
    m = nom[0]
    m << ": #{action} "
    m << quoi.to_s
    if ou
      m << " "
      m << ou
    end
    if resultat
      m << " => "
      m << resultat
    end
# File.open("rami.log", "a") { |w| w.puts m }
    self.messages << m
  end

  def msg_libre texte
    self.messages << texte
  end

  def prendre_dans_pioche joueur_id
    # Prend une carte dans la pioche
    self.carte_tiree = self.paquet.piocher_une_carte
    # Pour l'ajouter à la main du joueur
    self.joueurs[joueur_id].ajouter_une_carte self.carte_tiree
    msg self.joueurs[joueur_id].nom, "pioche", self.carte_tiree
  end

  def prendre_dans_defausse joueur_id
    # Prend une carte dans la défausse
    self.carte_tiree = self.paquet.prendre_la_defausse
    # Pour l'ajouter à la main du joueur
    self.joueurs[joueur_id].ajouter_une_carte self.carte_tiree
    # Mémorise la nouvelle carte disponible à la défausse
    self.carte_defausse = self.paquet.carte_defausse
    msg self.joueurs[joueur_id].nom, "prend", self.carte_tiree
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
    # Passe au tour suivant lorsque tous les joueurs ont fini le tour
    self.compte_tour += 1 if self.joueurs.all? { |j| j.compte_tour == self.compte_tour }
    msg self.joueurs[joueur_id].nom, "défausse", carte
  end

  def poser_sur_tas joueur, tas, carte

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
    if joueur.cartes.size > 0
      # SIZE = 0 NE DEVRAIT PAS ARRIVER => A TRAITER
      poser_dans_defausse joueur_id, joueur.meilleure_defausse(self.ta12s)
self.traces << "defausse <= [ #{self.carte_defausse.to_s} ]"
    end

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

    # Cas où le joueur n'a pas encore posé ses 51 points
    if (joueur.a_pose_51? == false)
      # - Le joueur s'approprie le tas dès lors qu'il est vide
      tas.nom_joueur = joueur.nom if avant_points == 0
      # - Le joueur ne peut pas poser sur un tas adverse pour l'instant
      if tas.nom_joueur != joueur.nom
        msg_libre "Tas #{tas.tas_id} interdit car seulement #{joueur.a_pose_combien} sur 51 points"
        return
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
      # - Informe le joueur qu'il a récupéré le joker
      msg joueur.nom, "remplace", carte, "dans #{avant_cartes}"
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
      # - Informe le joueur qu'il a complété le tas
      resultat = donner_score ? "#{joueur.a_pose_combien} pts" : nil
      msg joueur.nom, "ajoute", carte, "à #{avant_cartes}", resultat
      return
    end

    # Cas où la carte du joueur ne lui permet pas de compléter le tas
    # alors que le tas contient déjà une combinaison valide
    if tas.cartes.size >= 3
      # - Informe le joueur qu'il y a un problème
      msg joueur.nom, "KO", carte, "sur <span title='tas n°#{tas.tas_id}'>table</span>"
      return
    end

    # Cas où le joueur place sa carte sur un tas en constructiuon (moins de 3 cartes)
    # - Retire une carte de la main du joueur
    joueur.enlever_une_carte carte
    # - Pour la placer sur un tas
    tas.ajouter_une_carte carte
    # - Rien d'autre à faire tant que le tas ne contient pas 3 cartes
    if tas.cartes.size < 3
      msg joueur.nom, "place", carte, "sur <span title='tas n°#{tas.tas_id}'>table</span>"
      return
    end

    # Cas où le tas contient désormais 3 cartes
    # => On analyse si cela correspond à une combinaison valide
    combinaison = tas.combinaison

    # Cas où le tas constitue à présent une combinaison valide
    if combinaison.type != :tas
      # - Met à jour le score du joueur
      joueur.a_pose_combien -= avant_points
      joueur.a_pose_combien += tas.combinaison.points
      # - Informe l'utilisateur qu'il a posé une combinaison valide
      resultat = donner_score ? "#{joueur.a_pose_combien} pts" : nil
      msg joueur.nom, "pose", combinaison, "sur <span title='tas n°#{tas.tas_id}'>table</span>", resultat
      # - Rien d'autre à faire
      return
    end

    # Cas où les 3 cartes ne constituent pas une combinaison valide !!!
    # - Remet les cartes du tas dans la main du joueur
    tas.cartes.each { |c| joueur.ajouter_une_carte c }
    # - Vide le tas
    tas.clear
    # - Informe le joueur qu'il y a un problème
    msg joueur.nom, "KO", carte, "sur <span title='tas n°#{tas.tas_id}'>table</span>", "#{combinaison.to_s} pas valide"
  end

  # Cas où le joueur est en train de constituer sa tierce franche
  def poser_tierce_franche joueur, tas, carte

    # Vérifie que le joueur pose sa tierce franche au bon endroit
    case joueur.cartes.size
    when 15
      # Si le joueur a 15 cartes
      # Alors, il est en train de poser sa 1° carte,
      # donc forcément sur un tas vide
      if tas.cartes.size != 0
        msg joueur.nom, "KO", carte, "sur <span title='tas n°#{tas.tas_id}'>table</span>", "pas un tas vide #{tas.cartes.size}"
        return if joueur.nom == "Moi"
      end
    when 14
      # Si le joueur a 14 cartes
      # Alors, il est en train de poser sa 2° carte,
      # donc forcément sur un tas de 1 carte
      if tas.cartes.size != 1
        msg joueur.nom, "KO", carte, "sur <span title='tas n°#{tas.tas_id}'>table</span>", "pas le tas commencé #{tas.cartes.size}"
        return if joueur.nom == "Moi"
      end
    when 13
      # Si le joueur a 13 cartes
      # Alors, il est en train de poser sa 3° carte
      # donc forcément sur un tas de 2 cartes
      if tas.cartes.size != 2
        msg joueur.nom, "KO", carte, "sur <span title='tas n°#{tas.tas_id}'>table</span>", "pas le tas commencé #{tas.cartes.size}"
        return if joueur.nom == "Moi"
      end
    else
      # Sinon on est dans un cas inattendu
      msg joueur.nom, "KO", carte, "sur <span title='tas n°#{tas.tas_id}'>table</span>", "hors tierce franche #{joueur.cartes.size}"
      return if joueur.nom == "Moi"
    end

    # Place la carte du joueur sur le tas destiné à sa tierce franche
    # - retire une carte de la main du joueur
    joueur.enlever_une_carte carte
    # - pour la placer sur un tas
    tas.ajouter_une_carte carte
    # - rien d'autre à faire tant que le tas ne contient pas 3 cartes
    if tas.cartes.size < 3
      msg joueur.nom, "place", carte, "sur <span title='tas n°#{tas.tas_id}'>table</span>"
      return
    end

    # On analyse ce que contient le tas
    combinaison = tas.combinaison
    # Cas où c'est une tierce franche
    if combinaison.tierce_franche?
      # Mémorise le nombre de points que représente la tierce franche
      joueur.a_pose_combien = combinaison.points
      # Informe l'utilisateur qu'il a posé sa tierce franche
      # msg joueur.nom, "place", carte, "sur <span title='tas n°#{tas.tas_id}'>table</span>", "#{combinaison.to_s} (tierce franche)"
      msg joueur.nom, "pose", combinaison, "sur <span title='tas n°#{tas.tas_id}'>table</span>", "#{joueur.a_pose_combien} pts"
      # Rien d'autre à faire
      return
    end

    # Cas où les 3 cartes ne constituent pas une tierce franche !!!
    # - Remet les cartes du tas dans la main du joueur
    tas.cartes.each { |c| joueur.ajouter_une_carte c }
    # - Vide le tas
    tas.clear
    # - Informe le joueur qu'il y a un problème
    msg joueur.nom, "KO", carte, "sur <span title='tas n°#{tas.tas_id}'>table</span>", "#{combinaison.to_s} pas une tierce franche"
  end

end
