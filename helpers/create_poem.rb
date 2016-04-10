require 'ruby_rhymes'
require 'gingerice'
require 'moby'
require 'verbs'
require 'english/inflect'
require 'sinatra'

class Web < Sinatra::Base

#  def create_poem(poet, poem) 
#    r = Random.new
#    random_file_name = Dir.glob("poems/#{poet.gsub(/ /,'_')}__#{poem.gsub(/ /,'_')}*.poem").sample(random: r)
#    created_poem = Array.new
#    File.open("#{random_file_name}", 'r') do |infile|
#      while (line = infile.gets)
#        created_poem.push(line + '<br>')
#      end
#    end
#    created_poem.push('<br>')
#
#    created_poem
#  end

  def read_vocab(vocab_file)
    local_vocab_hash = Hash.new
    File.open("#{vocab_file}", 'r') do |infile|
      while (line = infile.gets)
        next if line =~ /^#/
        line_array = line.split('=')
        line_array[0] = line_array[0].gsub(/[^aclA-Z]/,'')
        local_vocab_hash[line_array[0]] = line_array[1].split('|')
      end
    end
    # We create a hash for each alternative list (lists that start with 'a')
    local_vocab_hash.keys.select{ |k| k[/^a/] }.each do |alt_list_key|
      working_array = local_vocab_hash[alt_list_key]
      local_vocab_hash[alt_list_key] = Hash.new
      working_array.each do |value|
        local_vocab_hash[alt_list_key][value.split(',')[0]] = value.split(',')[1]
      end
    end
    local_vocab_hash
  end
  
  def read_poem_structure(poem_structure_file)
    local_tagged_hash = Hash.new
    local_tagged_hash['poem'] = Array.new
    local_tagged_hash['syllables'] = Array.new
    local_tagged_hash['correction'] = Array.new
    local_tagged_hash['rhyme'] = Array.new
    local_tagged_hash['wholeline'] = Array.new
    line_index = 0
    File.open("#{poem_structure_file}", 'r') do |infile|
      while (line = infile.gets)
        local_tagged_hash['poem'][line_index] = line.split('@@')[0].split
        local_tagged_hash['syllables'][line_index] = line.split('@@')[1].split(',')[0].split('|')
        local_tagged_hash['correction'][line_index] = line.split('@@')[1].split(',')[1]
        local_tagged_hash['rhyme'][line_index] = line.split('@@')[1].split(',')[2]
        local_tagged_hash['wholeline'][line_index] = line.split('@@')[1].split(',')[3].strip
        line_index += 1
      end
    end
    local_tagged_hash
  end
  
  def correct_grammar(text)
    parser = Gingerice::Parser.new
    parser.parse(text)
    parser.result
  end
  
  def create_poem(poet_name, poem_name)

    #
    # Set main variables
    #
    
    new_poem = Array.new
    memory = Hash.new
    
    word_tree_prp = {'i' => 'my', 'you' => 'your', 'he' => 'his', 'she' => 'her', 'they' => 'their', 'we' => 'our', 'it' => 'its' } 
    word_tree_pro = {'i' => 'me', 'you' => 'you', 'he' => 'him', 'she' => 'her', 'they' => 'them', 'we' => 'us', 'it' => 'it' } 
    
    poem_file_name = "#{poet_name.gsub(/ /,'_')}__#{poem_name.gsub(/ /,'_')}"
    poem_structure = read_poem_structure("./poems/input/structure/#{poem_file_name}.bnfs")
    vocab = read_vocab("./poems/input/vocab/#{poem_file_name}.bnfv")
    
    thes = Moby::Thesaurus.new
    
    #
    # Process poem structure
    # 
    
    count = 0
    match = 2
    
    poem_structure['poem'].each_with_index do |line, index|
      line.each do |word| 
        r = Random.new
        # Memory tag plus POS tag for plural nouns (creates memory tag)
        # eg. <3><NNsNG>
        if word[/<[0-9]+>/] and word[/<NNs[A-Z]*>/]
          stem_word = vocab[word.
            gsub(/<[0-9]+>/,'').
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          sub_word = "#{stem_word}".en.plural
          memory[word[/<([0-9]+)>/m, 1]] = sub_word
          sub_text = word.
            gsub(/<[0-9]+>/,'').
            gsub(/<NNs[A-Z]*>/, sub_word)
          (new_poem[index] ||= "").
            concat(sub_text + " ")
        # Memory tag plus POS tag for past tense verbs (creates memory tag)
        # eg. <3><VBdPOS>
        elsif word[/<[0-9]+>/] and word[/<VBd[A-Z]*>/]
          stem_word = vocab[word.
            gsub(/<[0-9]+>/,'').
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          sub_word = Verbs::Conjugator.conjugate :"#{stem_word}", :tense => :past, :aspect => :perfective
          memory[word[/<([0-9]+)>/m, 1]] = sub_word
          sub_text = word.
            gsub(/<[0-9]+>/,'').
            gsub(/<VBd[A-Z]*>/, sub_word)
          (new_poem[index] ||= "").
            concat(sub_text + " ")
        # Memory tag plus POS tag for continuous tense verbs (creates memory tag)
        # eg. <3><VBgPOS>
        elsif word[/<[0-9]+>/] and word[/<VBg[A-Z]*>/]
          stem_word = vocab[word.
            gsub(/<[0-9]+>/,'').
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          sub_word = ( Verbs::Conjugator.conjugate :"#{stem_word}", :tense => :past, :aspect => :progressive ).split.last
          memory[word[/<([0-9]+)>/m, 1]] = sub_word
          sub_text = word.
            gsub(/<[0-9]+>/,'').
            gsub(/<VBg[A-Z]*>/, sub_word)
          (new_poem[index] ||= "").
            concat(sub_text + " ")
        # Memory tag plus POS tag for present perfect tense verbs (creates memory tag)
        # eg. <3><VBpPOS>
        elsif word[/<[0-9]+>/] and word[/<VBp[A-Z]*>/]
          stem_word = vocab[word.
            gsub(/<[0-9]+>/,'').
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          sub_word = ( Verbs::Conjugator.conjugate :"#{stem_word}", :tense => :present, :aspect => :perfect ).split.last
            memory[word[/<([0-9]+)>/m, 1]] = sub_word
          sub_text = word.
            gsub(/<[0-9]+>/,'').
            gsub(/<VBp[A-Z]*>/, sub_word)
          (new_poem[index] ||= "").
            concat(sub_text + " ")
        # Memory tag plus POS tag (creates memory tag)
        # eg. <1><PRS>
        elsif word[/<[0-9]+>/] and word[/<[A-Z]+>/]
          sub_word = vocab[word.
            gsub(/<[0-9]+>/,'').
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          memory[word[/<([0-9]+)>/m, 1]] = sub_word
          sub_text = word.
            gsub(/<[0-9]+>/,'').
            gsub(/<[A-Z]+>/, sub_word)
          (new_poem[index] ||= "").
            concat(sub_text + " ")
        # Memory tag to find POS
        # eg. <1>
        elsif word[/<[0-9]+>/]
          sub_word = memory[word[/<([0-9]+)>/m, 1]]
          sub_text = word.
            gsub(/<([0-9]+)>/, sub_word)
         ( new_poem[index] ||= "" ).
           concat(sub_text + " ")
        # Memory tag referencing pronoun of place
        # eg. [1]
        elsif word[/\[[0-9]+\]/]
          ref = memory[word[/\[([0-9]+)\]/m, 1]].
            downcase
          sub_text = word.
            gsub(/\[[0-9]+\]/, word_tree_prp[ref])
          ( new_poem[index] ||= "" ).
            concat(sub_text + " ")
        # Memory tag referencing pronoun of place
        # eg. (1)
        elsif word[/\([0-9]+\)/]
          ref = memory[word[/\(([0-9]+)\)/m, 1]].
            downcase
        sub_text = word.
          gsub(/\([0-9]+\)/, word_tree_pro[ref])
        ( new_poem[index] ||= "" ).
          concat(sub_text + " ")
        # Memory tag used to find synonym
        # eg. {1}
        elsif word[/\{[0-9]+\}/]
          sub_word = thes.
            syns(memory[word[/\{([0-9]+)\}/m, 1]].
            downcase).
          sample(random: r)
          sub_text = word.
            gsub(/\{[0-9]+\}/, sub_word)
          ( new_poem[index] ||= "" ).
            concat(sub_text + " ")
        # Memory tag with positional metadata plus Collection POS tag 
        # eg. <c1><cNNSMITHY>
        elsif word[/<c[0-9]+>/] and word[/<c[A-Z]+>/]
          collection_words = vocab[word.
            gsub(/<c[0-9]+>/,'').
            gsub(/[^cA-Z]/,'')].
            sample(random: r)
          sub_word = collection_words.
            split(',')[0].
            strip
          memory_word = collection_words
          collection_words.split(',').each_with_index do |w,i|
          next if i == 0
            memory[word[/<(c[0-9]+)>/m, 1] + ",#{i+1}"] = w.strip
          end
         sub_text = word.
          gsub(/<c[0-9]+>/,'').
          gsub(/<c[A-Z]+>/, sub_word)
            ( new_poem[index] ||= "" ).
          concat(sub_text + " ")
        # Memory tag plus Linked POS tag (note lower case 'l', not number '1')
        # eg. <l6><lNNCNFN>
        elsif word[/<l[0-9]+>/] and word[/<l[A-Z]+>/]
          linked_words = vocab[word.
            gsub(/<l[0-9]+>/,'').
            gsub(/[^lA-Z]/,'')].
            sample(random: r)
          sub_word = linked_words.
            split(',')[0].
            strip
          memory_word = linked_words.
            split(',')[1].
            strip
          memory[word[/<(l[0-9]+)>/m, 1]] = memory_word
          sub_text = word.
            gsub(/<l[0-9]+>/,'').
            gsub(/<l[A-Z]+>/, sub_word)
          ( new_poem[index] ||= "" ).
            concat(sub_text + " ")
        # Memory tag to find Linked POS (note lower case 'l', not number '1')
        # eg. <l6>
        elsif word[/<l[0-9]+>/]
          sub_word = memory[word[/<(l[0-9]+)>/m, 1]]
          sub_text = word.
            gsub(/<(l[0-9]+)>/, sub_word)
          ( new_poem[index] ||= "" ).
            concat(sub_text + " ")
        # Memory tag to find Collection POS at position
        # eg. <c1,2>
        elsif word[/<c[0-9]+,[0-9]+>/]
          sub_word = memory[word[/<(c[0-9]+,[0-9]+)>/m, 1]]
          sub_text = word.
            gsub(/<(c[0-9]+,[0-9]+)>/, sub_word)
          ( new_poem[index] ||= "" ).
            concat(sub_text + " ")
        # POS tag with desired rhyme
        # eg. <VB>[thee]
        elsif word[/<[A-Z]+>/] and word[/\[[a-z]+\]/]
          # insert rhyme key into poem structure metadata
          desired_rhyme_key = word[/\[([a-z]+)\]/, 1].
            to_phrase.
            rhyme_key
          poem_structure[poem_structure['rhyme'][index]] = desired_rhyme_key
          # substitute word 
          sub_word = vocab[word.
            gsub(/\[[a-z]+\]/,'').
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          sub_text = word.
            gsub(/\[[a-z]+\]/,'').
            gsub(/<[A-Z]+>/, sub_word)
          ( new_poem[index] ||= "" ).
            concat(sub_text + " ")
        # POS tag for plural nouns
        # eg. <NNsNG>
        elsif word[/<NNs[A-Z]*>/]
          stem_word = vocab[word.
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          sub_word = "#{stem_word}".en.plural
          sub_text = word.
            gsub(/<NNs[A-Z]*>/, sub_word)
          ( new_poem[index] ||= "" ).
            concat(sub_text + " ")
        # POS tag for past tense verbs
        # eg. <VBdPOS>
        elsif word[/<VBd[A-Z]*>/]
          stem_word = vocab[word.
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          sub_word = Verbs::Conjugator.
            conjugate :"#{stem_word}", :tense => :past, :aspect => :perfective
          sub_text = word.
            gsub(/<VBd[A-Z]*>/, sub_word)
          ( new_poem[index] ||= "" ).
            concat(sub_text + " ")
        # POS tag for continuous tense verbs
        # eg. <VBgPOS>
        elsif word[/<VBg[A-Z]*>/]
          stem_word = vocab[word.
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          sub_word = ( Verbs::Conjugator.
            conjugate :"#{stem_word}", :tense => :past, :aspect => :progressive ).
            split.
            last
          sub_text = word.
            gsub(/<VBg[A-Z]*>/, sub_word)
          ( new_poem[index] ||= "" ).
            concat(sub_text + " ")
        # POS tag for present perfect tense verbs
        # eg. <VBpPOS>
        elsif word[/<VBp[A-Z]*>/]
          stem_word = vocab[word.
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          sub_word = ( Verbs::Conjugator.
            conjugate :"#{stem_word}", :tense => :present, :aspect => :perfect ).
            split.
            last
          sub_text = word.
            gsub(/<VBp[A-Z]*>/, sub_word)
          ( new_poem[index] ||= "").
            concat(sub_text + " ")
        # POS tag only
        # eg. <PRS>
        elsif word[/<[A-Z]+>/]
          sub_word = vocab[word.
            gsub(/[^A-Z]/,'')].
            sample(random: r).
            strip
          sub_text = word.
            gsub(/<[A-Z]+>/, sub_word)
          ( new_poem[index] ||= "" ).
            concat(sub_text + " ")
        # No tags, use original word
        else
          ( new_poem[index] ||= "").
            concat(word.
            strip + " ")
        end
      end
    
      #
      # Operate on the whole line
      #
    
      # Try to correct grammar if poem structure metadata requests it
      #rhyme_key = ""
      #if poem_structure['correction'][index] == 'Y'
      #  new_poem[index] = correct_grammar(new_poem[index])
      #end
     
      # 
      # Use ruby_rhymes to operate on syllables and rhyme keys
      #
      # To do this we don't actually operate on the line, we create a ruby_rhymes Phrase
      # based on a pre_phrase string which may be a slight modification of the line
      #
      # At the end we will revert back to using the line to create the poem, 
      # but for the sake of rhymes and syllables we use the phrase object with
      # ruby_rhymes
      #
     
      # Create pre_phrase and phrase
    
      pre_phrase = ""
      pre_phrase = new_poem[index]
      # To cater to phrases like "dimm'd" and "grow'st" that are not in the
      # dictionary we chop the ends so we can find rhymes on the 'stem'
      [ "\s$", "[^a-z]$", "'st$", "'d$", "'d" ].each do |substring|
        pre_phrase = pre_phrase.gsub(/[^a-z]$/,'').gsub(/#{substring}/,'')
      end
      # 
      # TODO: This is very inefficient
      # An alternative might be to maintain the pre_phrase string in parallel
      # with the poem line during line creation. The alt words can then be inserted 
      # when the original word is added.
      # ... or maybe it's time to consider creating complex data structures 
      # that can express the relations between poem elements in multiple dimensions
      #
      vocab.keys.select{ |k| k[/^a/] }.each do |alt_list_key|
        vocab[alt_list_key].keys.each do |key_word|
          if pre_phrase =~ /#{key_word}$/
            pre_phrase = pre_phrase.gsub(/#{key_word}$/,"#{vocab[alt_list_key][key_word]}")
          end
        end
      end
      phrase = pre_phrase.to_phrase
     
      # Occasionally the number of syllables is dynamically determined during poem
      # creation
      if poem_structure['syllables'][index] == 'X'
        true
      # In all other cases line should conform to stipulated syllable count
      elsif !poem_structure['syllables'][index].include?(phrase.syllables.to_s)
        new_poem[index] = ""
        redo
      end
     
      # Ignore rhyme if scheme is marked X
      if poem_structure['rhyme'][index] == 'X'
        true
      # Sometimes we want to use an old line in toto
      # If the line exists already, use it
      elsif poem_structure['wholeline'][index] != 'X' and poem_structure[poem_structure['wholeline'][index]] != nil
        new_poem[index] = poem_structure[poem_structure['wholeline'][index]]
      # Make match less strenuous if 100 failures
      elsif count > 100 and match == 2
        count = 0
        match = 1
        redo
      # After the next 100, accept that we've tried and need to move on
      elsif count > 100 and match == 1
        true
      # Now try to find a matching rhyme
      # Note: We rely heavily on the phrase POSs being in the dictionary
      #       Words that are not can be added to custom vocab as alternative
      #       vocab lists (see earlier above}
      #       
      elsif phrase.dict?
        scheme_rhyme_key = poem_structure[poem_structure['rhyme'][index]]
        if scheme_rhyme_key != nil and scheme_rhyme_key != ""
          count += 1
          # match counter should be at least length of the rhyming key
          # to avoid matching 'nil'
          match = scheme_rhyme_key.length if scheme_rhyme_key.length < match
          unless phrase.rhyme_key[-match,match] == scheme_rhyme_key[-match,match]
            new_poem[index] = ""
            redo
          end
        else
          rhyme_key = phrase.rhyme_key
        end
      # No luck, create the line anew
      else
        new_poem[index] = ""
        redo
      end
     
      # Try to correct grammar if poem structure metadata requests it
      # PS: It is not ideal to do it this late, but because of the impact on
      # performance, this should suffice once we have relative confidence
      # in the line already - i.e. to fix cases like "a apple" -> "an apple"
      rhyme_key = ""
      if poem_structure['correction'][index] == 'Y'
        new_poem[index] = correct_grammar(new_poem[index])
      end
     
      # Sometimes, like in a villanelle, we use an old line in toto
      # At this here point the line is encountered for the 1st time
      if poem_structure['wholeline'][index] != 'X' and poem_structure[poem_structure['wholeline'][index]] == nil
        poem_structure[poem_structure['wholeline'][index]] = new_poem[index]
      end
     
      # If we got here it means the current line has been accepted
      # Now prepare for the next line in the poem structure
      # 
      poem_structure[poem_structure['rhyme'][index]] = rhyme_key
      match = 2
      count = 0
     
      File.open('/tmp/test2', 'w') { |file| file.write("#{new_poem[index]}") }
      new_poem[index] = new_poem[index] + '<br>'
    end

    new_poem.push('<br>')
    new_poem
  end

end
