# encoding: UTF-8

require "sinatra"
require "sinatra/reloader" if development?

use Rack::Session::Pool

require "./analyse"
require "./carte"
require "./combinaison"
require "./joueur"
require "./paquet"
require "./partie"
require "./niveau3"
require "./niveau4"

# ---------- Helpers ----------

helpers do

  # Code HTML pour afficher une carte
  def img_carte carte, derniere
    id = carte.carte_id.to_s
    id = "0" + id if id.size < 2
    css = "card " + carte.to_css
    css << " repere" if carte.repere
    tooltip = @debug ? " title='#{carte.tooltip}'" : ""
    "<div id='carte#{id}' class='#{css}'#{tooltip}></div>"
  end

  # Code HTML pour afficher le dos d'une carte
  def img_dos carte
    carte = if @fin_partie
              carte
            elsif @debug
              carte
            else
              nil
            end
    if carte.nil?
      "<div class='card X BK'></div>"
    else
      img_carte carte, nil
    end
  end

  # Code HTML pour afficher la pile des cartes rejetées
  def img_rebut carte
    if carte
      img_carte carte, nil
    else
      " " #<img src='/#{@cards_theme}/pile-vide.png' />"
    end
  end

  def tooltip text
    @debug ? " title='#{text}'" : ""
  end

end


# ---------- Routes ----------

MOI = 0
RUBY = 1

before do
  @cards_theme = "cards1"
end

# Page d'accueil
get "/" do
  @partie = session[:partie]
  redirect to('/demarrer') unless @partie

  @debug = session[:debug] ? true : false
  @fin_partie = @partie.fin_partie?
  @is_local = request.ip == "127.0.0.1"

  @conseil = get_conseil

  erb :table
end

def get_conseil
  joueur = @partie.joueurs[0]
  conseil = ""

  # Est-ce qu'il existe un tas en cours de remplissage ?
  tas_en_cours = @partie.ta12s.any? { |t| [1,2].include? t.cartes.size }

  if @partie.joueurs[1].cartes.size == 0

    # L'adversaire n'a plus de carte => il a gagné !
    conseil = "Dommage ! Vous avez perdu la partie :("

  elsif joueur.cartes.size == 0

    # Le joueur n'a plus de carte => il a gagné !
    conseil = "Félicitation ! Vous avez gagné la partie :)"

  elsif @partie.piocher

    # Le joueur doit piocher une carte

    if @partie.compte_tour == 1
      # C'est le 1° tour du jeu => on l'aide au maximum
      conseil = "Pour commencer la partie, vous pouvez prendre une carte dans la
                 pioche ci-dessus (face invisible) ou prendre la carte de la
                 défausse (face visible)"
    elsif joueur.peut_prendre? == false
      # Le joueur ne peut pas prendre de carte dans la défausse
      if @partie.compte_tour < 4
        # On est au début du jeu => on l'aide au maximum
        conseil = "Vous devez tirer une carte dans la pioche (car vous n'avez pas
                   de tierce franche dans votre main)"
      else
        # Ca fait un moment qu'on joue => on le laisse tranquille
        conseil = "Tirez une carte dans la pioche"
      end
    elsif joueur.a_pose_51?
      # Le joueur a déjà posé ses 51 points
      # => il peut prendre la défausse à condition de la jouer
      conseil = "Tirez une carte dans la pioche ou prenez la carte de la défausse
                 (à condition de la poser dans le tour)"
    else
      # Le joueur a déjà une tierce franche en main
      # => il peut prendre la défausse à condition de poser 51 points
      conseil = "Tirez une carte dans la pioche ou prenez la carte de la défausse
                 (à condition de poser 51 points dans le tour)"
    end

  elsif tas_en_cours

    # Le joueur a commencé à remplir un tas
    # => Il doit continuer ce qu'il a commencé
    if joueur.a_pose_tierce? == false
      conseil = "Continuez à poser votre tierce franche"
    elsif joueur.a_pose_51? == false
      conseil = "Continuez à poser votre combinaison pour atteindre 51 points"
    else
      conseil = "Continuez à poser votre combinaison"
    end

  else

    # Le joueur doit jouer une carte

    # Cas où le joueur a pris la carte de la défausse
    defausse_a_poser = false
    if @partie.carte_prise_nb == 1
      # Il faut qu'il la pose si ce n'est pas encore fait
      nb = joueur.cartes.count { |c| c == @partie.carte_prise }
      if nb == @partie.carte_prise_nb
        defausse_a_poser = true
      end
    end

    if joueur.cartes.size == 1
      # Le joueur n'a plus qu'une carte => il va gagner !
      conseil = "Ecartez votre dernière carte à la défausse !"
    elsif @partie.compte_tour == 1
      # Le joueur ne peut que défausser lors du 1° tour
      conseil = "Posez une de vos cartes dans la défausse"
    elsif joueur.tierce_franche?
      # Il dispose d'une tierce franche et ne l'a pas encore posée
      if defausse_a_poser
        conseil = "Posez votre tierce franche à condition d'atteindre 51 points
                   avec d'autres combinaisons"
      else
        conseil = "Posez votre tierce franche à condition d'atteindre 51 points
                   avec d'autres combinaisons ou écartez une carte à la défausse"
      end
    elsif @partie.compte_tour > 10
      # Ca fait un moment qu'on joue => on laisse le joueur assez tranquille
      if defausse_a_poser
        conseil = "Posez une combinaison sur la table"
      else
        conseil = "Posez une combinaison sur la table ou écartez une carte à la
                   défausse"
      end
    elsif joueur.a_pose_51?
      # Le joueur a posé 51 points
      # => Il peut jouer assez librement
      if joueur.cartes.size <= 3
        if defausse_a_poser
          conseil = "Complétez une des combinaisons déjà posées"
        else
          conseil = "Complétez une des combinaisons déjà posées ou écartez une
                     carte à la défausse"
        end
      elsif defausse_a_poser
        conseil = "Posez une nouvelle combinaison ou complétez une des combinaisons
                   déjà posées"
      else
        conseil = "Posez une nouvelle combinaison, complétez une des combinaisons
                   déjà posées ou écartez une carte à la défausse"
      end
    elsif joueur.a_pose_tierce?
      # Il a déjà posé sa tierce franche mais n'a pas encore ses 51 points
      conseil = "Posez d'autres combinaisons pour atteindre 51 points"
    elsif @partie.compte_tour < 10
      conseil = "Vous devez poser une carte dans la défausse (car vous n'avez pas
                 de tierce franche dans votre main)"
    elsif defausse_a_poser
      # Le joueur a pris la carte à la défausse et ne l'a pas encore posée
      conseil = "Posez une combinaison sur la table"
    else
      conseil = "Ecartez une carte à la défausse"
    end

  end

end

# Mode debug
get "/debug" do
  @debug = session[:debug] ? true : false

  @debug = !@debug

  session[:debug] = @debug
  redirect to("/")
end

# Nouvelle partie
get "/demarrer" do
  @partie = Partie.new "Moi", "Ruby"
  @partie.joueurs[RUBY].niveau = Niveau4.new @partie.joueurs[RUBY]
  @partie.joueurs[MOI].niveau = Niveau4.new @partie.joueurs[MOI]

  @partie.distribuer_les_cartes

if 1 == 2
  # Avantage le joueur RUBY en lui distribuant quelques cartes en plus
  avantage = 4
  (avantage - 1).times do
    # évite la ré-analyse
    @partie.joueurs[RUBY].cartes << @partie.paquet.pioche.pop
  end
  @partie.joueurs[RUBY].ajouter_une_carte @partie.paquet.pioche.pop
  avantage.times do
    carte = @partie.joueurs[RUBY].meilleure_defausse(@partie.ta12s)
    @partie.joueurs[RUBY].enlever_une_carte carte
    @partie.paquet.pioche.unshift carte
  end

end

  # Une fois sur 2, faire jouer RUBY en premier
  # => ...
  @partie.piocher = true
  # @partie.message = "A votre tour de piocher une carte"

  session[:partie] = @partie
  redirect to("/")
end

# Joueur prend une carte dans la pioche
get "/piocher" do
  @partie = session[:partie]

  # On ne peut piocher que si c'est le moment de piocher
  redirect to('/') unless @partie.piocher

  # On supprime le repérage des cartes
  @partie.enlever_les_reperes

  # MOI tire une carte dans la pioche
  @partie.prendre_dans_pioche MOI

  # C'est encore à MOI de jouer
  # => rien à faire
  @partie.piocher = false

  session[:partie] = @partie
  redirect to("/")
end

# Joueur prend une carte dans la défausse
get "/prendre" do
  @partie = session[:partie]

  # On ne peut prendre dans la défausse que si c'est le moment de piocher
  redirect to('/') unless @partie.piocher

  # On supprime le repérage des cartes
  @partie.enlever_les_reperes

  # MOI prend la carte de la défausse
  @partie.prendre_dans_defausse MOI

  # C'est encore à MOI de jouer
  # => rien à faire
  @partie.piocher = false

  session[:partie] = @partie
  redirect to("/")
end

# Joueur met une carte dans la défausse
get "/ecarter/:carte_id" do
  @partie = session[:partie]

  # On ne peut pas jeter si c'est le moment de piocher
  redirect to('/') if @partie.piocher

  # On ne peut pas défausser s'il existe un temps entamé
  unless @partie.accepter_defausse MOI
    session[:partie] = @partie
    redirect to("/")
  end

  # On supprime le repérage des cartes
  @partie.enlever_les_reperes

  # MOI écarte une carte dans la défausse
  carte = Carte.new params[:carte_id].to_i
  @partie.poser_dans_defausse MOI, carte

  # Vérifie si la partie est terminée après MOI
  if @partie.joueurs[MOI].cartes.size == 0
    session[:partie] = @partie
    redirect to("/")
  end

  # C'est à RUBY de jouer
  @partie.faire_jouer RUBY

  # Puis c'est au tour de MOI de jouer
  # (sauf si la partie est terminée)
  @partie.piocher = @partie.joueurs[RUBY].cartes.size > 0

  session[:partie] = @partie
  redirect to("/")
end

# Joueur dépose une carte dans un des tas prévu à cet effet
get "/poser/:carte_id/sur/:tas_id" do
  @partie = session[:partie]

  # On ne peut pas poser si c'est le moment de piocher
  redirect to('/') if @partie.piocher

  # Si un tas est déjà entamé, il faut continuer à poser dessus
  tas = @partie.ta12s.find { |t| [1,2].include? t.cartes.size }
  tas = @partie.ta12s[params[:tas_id].to_i] unless tas

  # MOI place une carte sur un des tas
  joueur = @partie.joueurs[MOI]
  carte = Carte.new params[:carte_id].to_i
  @partie.poser_sur_tas joueur, tas, carte

  # C'est toujours à MOI de jouer
  # => rien à faire

  session[:partie] = @partie
  redirect to("/")
end

# Joueur valide les cartes de sa 1° pose
get "/valider" do
  @partie = session[:partie]

  # On ne peut pas valider si c'est le moment de piocher
  redirect to("/") if @partie.piocher

  # Il faut faire les vérifications suivantes :
  # - les combinaisons réalisées sont correctes
  # - il y a bien une tierce franche
  # - il y a bien 51 points
  # - la carte prise à la défausse ne sert pas pour la tierce franche
  # - la carte prise à la défausse a été utilisée

  # C'est toujours à MOI de jouer
  # => rien à faire

  session[:partie] = @partie
  redirect to("/")
end

# Affiche la règle du jeu
get "/regle-du-jeu" do
  erb :regle
end
