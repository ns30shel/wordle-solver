# Packages --------------------------------------------------------------------


# Functions -------------------------------------------------------------------
include("simple_stringr.jl")

# The same as R's seq_len(), but probably not as safe.
function seq_len(num::Integer)
    collect(1:1:num)
end

# Similar to R's which(), but definitely not as safe.
function which(logical)
    seq_len(length(logical))[logical .== 1]
end


# Data Import -----------------------------------------------------------------
# The list of possible answers
open("data/wordle_list.txt") do file
    global words = read(file, String)
end
words = string.(str_split(words, "\r\n"))
num_words = length(words)


# Additional Data -------------------------------------------------------------
alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
# Color combinations
colors = ["green", "yellow", "grey"]
# All potential match patterns that could be found. There are 243 of them
# (3^5)--an option for each color and five letters in the word.
#
# You can assign an undefined string matrix, but you'll have to assign
# values to each index before you will be allowed to subset it.
color_combos = Array{String}(undef, 243, 5)
num_colors = seq_len(length(colors))
rowindex = 1
for i in num_colors, j in num_colors, k in num_colors, l in num_colors, m in num_colors
    color_combos[rowindex, seq_len(5)] = [colors[i], colors[j], colors[k], colors[l], colors[m]] 
    rowindex += 1
end


# Wordle Functions ------------------------------------------------------------
# Takes the user's guess and filters down to the remaining possible words
# based on the input word and color combo
function guess_filter(string, current_combo, word_list = words)
    if(length(string) != 5) error("You must use a five letter word!") end
    rgx = build_regex(string, current_combo)
    str_subset(word_list, Regex(rgx))
end

# Creates a regular expression to filter the word list
function build_regex(str, combo, all_letters = alphabet)
    # Grey letters are removed from the list entirely
    grey_letters = str[which(combo .== "grey")]
    non_grey_letters = remove_letters(all_letters, grey_letters)
    
    # The letters to use in the regex.
    possible_letters = Vector{String}(undef, 5)
        
    # Green letters are set.
    for i in which(combo .== "green") possible_letters[i] = string(str[i]) end
    # Grey letters are set to the non-grey letters
    for i in which(combo .== "grey") possible_letters[i] = str_c(non_grey_letters) end
    # Yellow letters are removed from the index in which they appear
    for i in which(combo .== "yellow") possible_letters[i] = str_c(remove_letters(non_grey_letters, string(str[i]))) end
    
    # Each element of the array will be surrounded by brackets []
    # to send to the regex.
    str_c("[" .* possible_letters .* "]")
end

# Creates a new array containing only the letters
# not in to_remove by identifying the letter
# to remove's position in the array
# and creates a new array that excludes the letter.
function remove_letters(letters, to_remove)
    remove_letter_indexes = zeros(Int64, 5)
    for i in seq_len(length(to_remove))
        letter = string(to_remove[i])
        # This which() call is guaranteed to be of length one
        ind = which(letters .== letter)[1]
        if(length(ind) != 0)
            global remove_letter_indexes[i] = ind
        else
            global remove_letter_indexes[i] = 0
        end
    end
    remove_letter_indexes = remove_letter_indexes[remove_letter_indexes .!= 0]
    letters[setdiff(1:end, remove_letter_indexes)]
end


# Trials ----------------------------------------------------------------------
guess_filter("while", combo)
