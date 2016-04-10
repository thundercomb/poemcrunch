# PoemCrunch

## Introduction

PoemCrunch is software that generates new poems in the style of the classics.  It uses a type of context free grammar called Backus-Naur Format, extended with various Natural Language Processing tools in Ruby.

PoemCrunch can be seen in action at [poemcrunch.com](http://poemcrunch.com).

## Getting started

It's easy to get started. PoemCrunch runs as a Sinatra app that you can spin up locally. Make sure you have Ruby, RubyGems, and Bundler installed.

The Gemfile specifies Ruby 2.2.4, but you can comment it out and run safely on any Ruby >= 2.0.0.

```
bundle
bundle exec unicorn -p 5000 -c unicorn.rb
```

Now point your browser to [http://localhost:5000](http://localhost:5000).

## Contact

Feel free to raise issues or create pull requests. You can also reach out to me on Twitter [@thundercomb](https://twitter.com/thundercomb). 

## License

The software is licensed under the terms of the [GNU Public License v2](http://github.com/thundercomb/poetrydb/LICENSE.txt). It basically means you can reuse and modify this software as you please, as long as the resulting program(s) remain open and licensed in the same way.
