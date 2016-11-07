class LongestWordController < ApplicationController

  def game
    @start_time = DateTime.now
    @grid = generate_grid(9)
  end

  def score
    # calculer le temps de réponse
    timetoanswer = (DateTime.now - Date.parse(params["start_time"])).to_f.round(2)
    # enregistrer la réponse
    @answer = params["answer"]
    # vérifier si on est bien dans la grid
    ingrid = in_grid?(@answer, params["initial_grid"])
    # get translation
    @translation = get_translation(@answer)
    # calculate score
    @score = get_score(ingrid, @answer, @translation, timetoanswer)
    # chercher le message à afficher
    @message = get_message(ingrid, @translation)
    # fail
  end

  private

  def generate_grid(grid_size)
    grid = []
    (0...grid_size).each { || grid << [*('A'..'Z')].sample }
    grid
  end

  def get_translation(attempt)
    api = 'https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key='
    key = 'cdf01b7c-89ee-48fe-a21f-14133d773540'
    url = "#{api}#{key}&input=#{attempt}"
    translation = JSON.parse(open(url).read) #url_to_hash(url)
    if translation["outputs"][0]["output"] == attempt
      return nil
    else
      return translation["outputs"][0]["output"]
    end
  end

  def array_to_hash(array)
    array.each_with_object({}) do |word, accu|
      accu.key?(word) ? accu[word] += 1 : accu[word] = 1
    end
  end

  def in_grid?(attempt, grid)
    hashgrid = array_to_hash(grid.upcase.chars)
    hashatt = array_to_hash(attempt.upcase.gsub(/\W/, '').chars)
    hashatt.keys.each { |letter| return false if hashgrid[letter].nil? || hashatt[letter] > hashgrid[letter] }
    true
  end

  def get_score(ingrid, attempt, translation, timetoanswer)
    ingrid == false || translation.nil? ? 0 : attempt.size - timetoanswer
  end

  def get_message(ingrid, translation)
    if ingrid == false
      "not in the grid"
    elsif translation.nil?
      "not an english word"
    else
      "well done"
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    ingrid = in_grid?(attempt, grid)
    translation = get_translation(attempt)
    timetoanswer = end_time - start_time
    score = get_score(ingrid, attempt, translation, timetoanswer)
    message = get_message(ingrid, translation)
    { time: timetoanswer, translation: translation, score: score, message: message }
  end
end
