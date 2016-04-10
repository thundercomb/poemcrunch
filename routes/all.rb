require 'sinatra'

class Web < Sinatra::Base

  get '/' do
    erb :index
  end

  get '/about' do
    erb :about
  end

  get '/style/shakespeare_sonnet_18' do
    poem = create_poem('William Shakespeare','Shall I Compare Thee to a Summers Day')
    title = poem[0].gsub(/<br>/,'')

    erb :poem_layout, :locals => { 
	:poem  => "#{poem.join("\n")}",
	:title => "#{title}",
	:url   => "/style/shakespeare_sonnet_18"
    }
  end

  get '/style/shakespeare_sonnet_18_brands' do
    poem = create_poem('William Shakespeare','Shall I Compare Thee to a BRAND')
    title = poem[0].gsub(/<br>/,'')

    erb :poem_layout, :locals => { 
	:poem  => "#{poem.join("\n")}",
	:title => "#{title}",
	:url   => "/style/shakespeare_sonnet_18_brands"
    }
	end

  get '/style/shelley_ozymandias' do
    poem = create_poem('Percy Bysshe Shelley','Ozymandias')
    title = poem[9].split[3].gsub(/,$/,'')

    erb :poem_layout, :locals => { 
	:poem  => "#{poem.join("\n")}",
	:title => "#{title}",
	:url   => "/style/shelley_ozymandias"
    }
  end

  get '/style/william_blake_the_tyger' do
    poem = create_poem('William Blake','The Tyger')
    title = "The " + poem[0].split[0]

    erb :poem_layout, :locals => { 
	:poem  => "#{poem.join("\n")}",
	:title => "#{title}",
	:url   => "/style/william_blake_the_tyger"
    }
  end 

  get '/style/yeats_an_irish_airman_foresees' do
    poem = create_poem('William Butler Yeats','An Irish Airman Foresees His Death')
    title = poem[0].capitalize

    erb :poem_layout, :locals => { 
	:poem  => "#{poem.join("\n")}",
	:title => "#{title}",
	:url   => "/style/yeats_an_irish_airman_foresees"
    }
  end 

  get '/style/dylan_thomas_do_not_go_gentle' do
    poem = create_poem('Dylan Thomas','Do Not Go Gentle Into That Good Night')
    title = poem[0].gsub(/,\s$/,'')

    erb :poem_layout, :locals => { 
	:poem  => "#{poem.join("\n")}",
	:title => "#{title}",
	:url   => "/style/dylan_thomas_do_not_go_gentle"
    }
  end 

  get '/style/williams_this_is_just_to_say' do
    poem = create_poem('William Carlos Williams','This Is Just To Say')
    title = poem[0].gsub(/,\s$/,'')

    erb :poem_layout, :locals => { 
	:poem  => "#{poem.join("\n")}",
	:title => "#{title}",
	:url   => "/style/williams_this_is_just_to_say"
    }
  end 
end
