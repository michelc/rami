# encoding: UTF-8

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "carte"
require "combinaison"

# Classe Analyse
# Permet d'analyser une main au jeu de Rami
# (totalement lié au jeu de Rami)

class Analyse

  attr_accessor :cartes

  def initialize une_main
    # Elimine les cartes en double
    self.cartes = une_main.sort.uniq { |c| c.carte_id }
    @combinaisons = nil
# File.open("rami.log", "a") { |w| w.puts self.to_s }
  end

  def to_s
    text = (self.cartes.map { |c| c.to_s }).join " "
    "[ #{text} ]"
  end

  # Analyse les combinaisons possibles dans une main
  def combinaisons
    unless @combinaisons
      # Quelles sont les suites (tierces...) dans la main du joueur ?
      @combinaisons = combiner_par_couleur
      # Quelles sont les séries (brelans...) dans la main du joueur ?
      @combinaisons += combiner_par_valeur
    end

    # Renvoie les combinaisons possibles
    @combinaisons
  end

  # Vérifie si les cartes constituent une série
  def est_une_serie? serie
    # Une série contient 3 ou 4 cartes
    return false unless (3..4).include? serie.size
    # Une série ne contient qu'une valeur de carte
    valeurs = serie.map { |c| c.valeur }.uniq
    valeurs -= [ :J ]   # (hors joker)
    return false if valeurs.size != 1
    # Une série ne peut pas contenir plus de 1 Joker
    return false if serie.count { |c| c.est_joker? } > 1
    # Une série ne peut pas contenir de doublon
    couleurs = serie.uniq { |c| c.carte_id }
    return false if couleurs.size < serie.size
    # Ok alors
    true
  end

  # Vérifie si les cartes constituent une suite
  def est_une_suite? suite
    # Une suite contient au moins 3 cartes
    return false unless suite.size >= 3
    # Une suite ne contient qu'une couleur de carte
    couleurs = suite.map { |c| c.couleur }.uniq
    couleurs.compact!   # (hors joker)
    return false if couleurs.size != 1
    # Une suite ne peut pas contenir plus de 1 Joker
    return false if suite.count { |c| c.est_joker? } > 1
    # Une suite ne peut pas contenir de doublon
    valeurs = suite.uniq { |c| c.carte_id }
    return false if valeurs.size < suite.size
    # Une suite doit avoir des cartes qui se suivent
    id_carte_attendue = suite[0].carte_id
    suite.each_with_index do |carte, index|
      # Vérifie que la carte correspond à celle qu'on attendait
      if carte.carte_id != id_carte_attendue
        return false unless carte.est_joker?
        return false if id_carte_attendue == -1
      end
      # Détermine quelle devra être la carte suivante
      if carte.est_joker?
        # Lorsque la carte en cours est un joker
        if index == 0
          # - s'il se trouve en 1° position, la carte attendue est la 2° carte
          id_carte_attendue = suite[index + 1].carte_id
        else
          # - sinon, la carte attendue est 2 cartes après la carte avant le joker
          id_carte_attendue = suite[index - 1].carte_apres.carte_apres.carte_id
        end
      else
        # La carte attendue est directement après la carte en cours
        id_carte_attendue = carte.carte_apres.carte_id
        # Dans le cas où la carte en cours est un As
        if carte.est_as?
          # L'As peut être utilisé à 2 endroits
          # - en première position (As, 2, 3...) => sera suivi d'un 2
          # - en dernière position (Dame, Roi, As) => doit être le dernier
          id_carte_attendue = -1 if index > 0
        end
      end
    end
    # Ok alors
    true
  end

  private

  # Retrouve les suites de 3 cartes (ou plus) consécutives de même couleur
  # (suite = séquence <=> tierce, cinquante... )
  def combiner_par_couleur
    # Par défaut, on n'a aucune suite
    suites = []
    # Si la main contient un  joker, une suite de 2 cartes + le joker fera une tierce
    un_joker = self.cartes.find { |c| c.est_joker? }
    nb_cartes = un_joker ? 2 : 3
    # Boucle sur toutes les cartes de la main (couleur par couleur) pour voir s'il existe des suites
    COULEURS.each do |couleur|
      # Retrouve toutes les cartes de la couleur en cours dans la main
      suite = self.cartes.select { |c| c.couleur == couleur }
      # Vérifie qu'il y a un minimum de cartes pour espérer faire une suite
      # (sinon, passe aux cartes de la couleur suivante)
      next if suite.size < nb_cartes
      # Ajoute l'As en dernière carte s'il est présent en 1° carte
      suite << suite.first if suite.first.est_as?
      # Complète éventuellement les "trous" avec un joker
      # - 2, 3, V, D, R => 2, 3, J, V, D, R, J
      # - 2, 3, 6, D, R => 2, 3, J, 6, J, D, R, J
      # - A, R, A => A, J, R, A
      if un_joker
        temp = []
        id_carte_attendue = suite[0].carte_id
        suite.each do |carte|
          temp << un_joker if carte.carte_id != id_carte_attendue
          temp << carte
          id_carte_attendue = carte.carte_apres.carte_id
        end
        temp << un_joker unless temp.last.est_as?
        suite = temp
      end
      # Re-vérifie qu'il y a un minimum de cartes pour espérer une suite
      next if suite.size < 3
      # Groupe les cartes par combinaisons consécutives de 3 cartes minimum.
      # Puis teste chaque combinaison pour savoir s'il s'agit d'une suite.
      # - 1° passage en évitant les suites qui commencent par un Joker
      #   (car rapporte moins de points qu'avec le Joker placé à la fin)
      nb_avant = suites.size
      declinaison = false
      suite.size.downto(3) do |nombre|
        suite.each_cons(nombre) do |groupe|
          if est_une_suite? groupe
            unless groupe.first.est_joker?
              suites << Combinaison.new(:suite, groupe)
              suites.last.declinaison = declinaison
              declinaison = true
            end
          end
        end
      end
      # - 2° passage en acceptant le Joker devant (si pas d'autres solution)
      if nb_avant == suites.size
        suite.size.downto(3) do |nombre|
          suite.each_cons(nombre) do |groupe|
            if est_une_suite? groupe
              suites << Combinaison.new(:suite, groupe)
              suites.last.declinaison = false
            end
          end
        end
      end
    end
    # Renvoie toutes les suites possibles
    suites
  end

  # Retrouve les séries de 3 ou 4 cartes de même valeur dans la main du joueur
  def combiner_par_valeur
    # Par défaut, on n'a aucune série
    series = []
    # Si la main contient un  joker, une paire + le joker fera un brelan
    un_joker = self.cartes.find { |c| c.est_joker? }
    # Boucle sur toutes les cartes de la main (valeur par valeur) pour voir s'il existe des séries
    VALEURS.each do |valeur|
      # Retrouve toutes les cartes de la valeur en cours dans la main
      serie = self.cartes.select { |c| c.valeur == valeur }
      # Complète éventuellement la paire avec un joker
      if serie.size == 2
        serie << un_joker if un_joker
      end
      # S'il y a assez de cartes pour faire une série
      if est_une_serie? serie
        # Ajoute la série au tableau des séries possibles
        series << Combinaison.new(:serie, serie)
        series.last.declinaison = false
      end
    end

    # Renvoie toutes les séries possibles
    series
  end

end
