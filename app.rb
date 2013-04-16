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

# ---------- Helpers ----------

helpers do

  # Code HTML pour afficher une carte
  def img_carte carte, derniere
    id = carte.carte_id.to_s
    id = "0" + id if id.size < 2
    css = "card"
    css << " derniere" if carte == derniere
    "<img id='carte#{id}' class='#{css}' src='/#{@cards_theme}/carte-#{id}.png' title='#{carte.tooltip}' />"
  end

  # Code HTML pour afficher le dos d'une carte
  def img_dos
    "<img class='card' src='/#{@cards_theme}/carte-dos.png' />"
  end

  # Code HTML pour afficher la pile des cartes rejetées
  def img_rebut carte
    if carte
      img_carte carte, nil
    else
      " " #<img src='/#{@cards_theme}/pile-vide.png' />"
    end
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

  erb :table
end

# Nouvelle partie
get "/demarrer" do
  @partie = Partie.new "Moi", "Ruby"
  @partie.joueurs[RUBY].niveau = Niveau3.new @partie.joueurs[RUBY]

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

  # MOI écarte une carte dans la défausse
  carte = Carte.new params[:carte_id].to_i
  @partie.poser_dans_defausse MOI, carte

  # C'est à RUBY de jouer
  @partie.faire_jouer RUBY

  # Puis c'est au tour de MOI de jouer
  @partie.piocher = true
  # @partie.message = "A votre tour de piocher une carte"

  session[:partie] = @partie
  redirect to("/")
end

# Joueur dépose une carte dans un des "slots" prévu à cet effet
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
