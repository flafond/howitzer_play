# howitzer_play
A learning exercise for the StrongQA Howitzer gem

This is a learning exercise to gain a bit of familiarity with
the [strongqa/howitzer](https://github.com/strongqa/howitzer) gem.
It uses a few features of the gem to exercise the
[Albuquerque Craigslist page](https://albuquerque.craigslist.org),
so please don't use it in any way that would make Craigslist mad. :-)

Most of this repository was generated with the command:
```
 howitzer new howitzer_play --rspec
 ```
 The code I'm largely responsible for is:

 * pages/...
 * spec/search_spec.rb
 * spec/spec_helper.rb (last few methods)

The tests are run in Selenium/FireFox; update *config/custom.yml* to
run them differently.
